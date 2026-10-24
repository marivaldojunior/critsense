# CritSense API

API em Python do CritSense: autenticação e ferramentas de IA para mestres de D&D 5e. O app Flutter (`../app`) e o futuro front React consomem o mesmo contrato OpenAPI ([../contracts/openapi.yaml](../contracts/openapi.yaml)).

Esta API substitui a API Java, que continua em [../api-java/](../api-java/) como projeto de estudo. As duas têm os mesmos endpoints e os mesmos códigos de erro.

## Stack

- Python 3.15 e [uv](https://docs.astral.sh/uv/) (dependências, ambiente virtual e `uv.lock`)
- FastAPI e Pydantic 2, com a configuração em `pydantic-settings`
- SQLAlchemy 2 (async, com `asyncpg`), PostgreSQL 17 e Alembic
- JWT HS256 com PyJWT e senhas com Argon2 (`pwdlib`)
- SDK da Anthropic (padrão) ou SDK da OpenAI, escolhido por variável de ambiente
- pytest, Testcontainers e um modelo de chat falso
- Ruff (lint e formatação) e mypy no modo `strict`

## Estrutura

```
api/
├── src/critsense/
│   ├── main.py          # create_app(): monta a aplicação
│   ├── config.py        # Settings (variáveis de ambiente)
│   ├── errors.py        # ErrorCode, ApiError e o formato problem+json
│   ├── db.py            # engine e sessão do SQLAlchemy
│   ├── openapi.py       # contrato OpenAPI e o comando que gera o arquivo
│   ├── ratelimit.py     # token bucket por usuário
│   ├── health.py        # /health e /health/ready
│   ├── auth/            # cadastro, login, JWT e usuário atual
│   ├── ai/              # modelos de chat, gateway, prompts e saída estruturada
│   ├── npc/             # gerador de NPCs
│   ├── encounters/      # monstros do SRD e dificuldade de encontros
│   └── prompts/         # prompts versionados (<nome>/v<versão>/)
├── migrations/          # migrações do Alembic
│   └── data/            # dados importados pelas migrações (monstros do SRD 5.1)
└── tests/
```

Cada feature tem `router.py` (HTTP), `schemas.py` (corpos JSON), `service.py` (regras) e, quando precisa, `dependencies.py`. As rotas recebem as peças pelo `Depends` do FastAPI, então os testes trocam essas peças sem mocks globais.

## Como rodar

### Com Docker Compose (API + PostgreSQL)

1. Na raiz do repositório, copie `.env.example` para `.env`.
2. Preencha `JWT_SECRET` (no mínimo 32 caracteres) e a chave do provedor de IA (`ANTHROPIC_API_KEY` ou `OPENAI_API_KEY`).
3. Suba os serviços:

```bash
docker compose up --build
```

A API aplica as migrações e fica em `http://localhost:8080`. A documentação interativa fica em `http://localhost:8080/docs`.

### Só a API, com o PostgreSQL do Docker Compose

1. Instale o uv e as dependências:

```bash
cd api && uv sync
```

2. Suba o banco:

```bash
docker compose up -d postgres
```

3. Aplique as migrações:

```bash
cd api && uv run alembic upgrade head
```

4. Suba a API com recarga automática. A API lê o `.env` da raiz do repositório:

```bash
cd api && uv run uvicorn --factory critsense.main:create_app --reload --port 8080
```

### Testes, lint e tipos

```bash
cd api && uv run pytest
```

```bash
cd api && uv run ruff format . && uv run ruff check --fix .
```

```bash
cd api && uv run mypy
```

Os testes de integração (`tests/test_integration.py`) sobem um PostgreSQL real com Testcontainers e aplicam as migrações do Alembic. Sem Docker, eles são pulados, e os outros testes rodam normalmente. No CI, todos rodam. Nenhum teste chama um provedor de IA real: os testes usam o `FakeChatModel`.

### Nova migração

Depois de mudar um modelo do SQLAlchemy, gere a migração e revise o arquivo antes de aplicar:

```bash
cd api && uv run alembic revision --autogenerate -m "descreve a mudança"
```

## Endpoints

| Método | Caminho | Autenticação | Descrição |
|---|---|---|---|
| POST | `/api/v1/auth/register` | não | Cria uma conta e devolve um token. |
| POST | `/api/v1/auth/login` | não | Troca usuário e senha por um token. |
| GET | `/api/v1/me` | sim | Devolve o usuário do token. |
| POST | `/api/v1/npcs/generate` | sim | Gera um NPC com a IA (conta no rate limit). |
| GET | `/health` | não | O processo está de pé. |
| GET | `/health/ready` | não | A API consegue falar com o banco. |

Envie o token no cabeçalho `Authorization: Bearer <token>`.

## Erros

Toda resposta de erro usa `application/problem+json` (RFC 9457), com o campo `code`:

| Status | `code` | Quando |
|---|---|---|
| 400 | `VALIDATION_FAILED`, `MALFORMED_REQUEST` | Corpo inválido. `errors` lista os campos. |
| 401 | `UNAUTHORIZED`, `INVALID_CREDENTIALS` | Token ausente ou inválido, ou login errado. |
| 404, 405 | `NOT_FOUND`, `METHOD_NOT_ALLOWED` | Caminho ou método errado. |
| 409 | `USERNAME_TAKEN` | Nome de usuário em uso. |
| 422 | `AI_REFUSED` | O modelo recusou o pedido. |
| 429 | `RATE_LIMITED` | Limite de IA atingido. Veja o cabeçalho `Retry-After`. |
| 502 | `AI_INVALID_OUTPUT`, `AI_PROVIDER_ERROR` | Resposta inválida da IA ou falha do provedor. |
| 503 | `AI_UNAVAILABLE` | Nenhum provedor de IA configurado. |
| 504 | `AI_TIMEOUT` | A IA demorou mais que `AI_TIMEOUT`. |

O FastAPI devolve `422` nos erros de validação por padrão. Esta API devolve `400` com `VALIDATION_FAILED`, como a API Java.

## Como a IA é usada

1. O endpoint aplica o rate limit do usuário (dependência `AiRateLimited`).
2. O `StructuredAiService` monta o prompt a partir dos arquivos versionados em `src/critsense/prompts/<nome>/v<versão>/`.
3. O prompt leva o JSON Schema da resposta, gerado do modelo Pydantic (ex: `Npc`).
4. O `AiGateway` chama o provedor com tempo máximo e traduz as falhas para os erros da API.
5. A resposta é validada com o Pydantic e com as regras do endpoint (ex: a raça pedida).
6. Se a resposta for inválida, o modelo recebe a lista de erros e tem mais uma tentativa. Se continuar inválida, a API devolve 502.

Com a Anthropic, a API usa o `claude-opus-5-5` com `effort: medium`. Ela também pede o `fallbacks: "default"`: quando os classificadores de segurança recusam um pedido, a própria Anthropic refaz o pedido num modelo escolhido pela categoria da recusa.

A chave do provedor fica só na API. O app nunca chama o provedor diretamente.

## Variáveis de ambiente

Veja [../.env.example](../.env.example). As principais:

| Variável | Padrão | Descrição |
|---|---|---|
| `JWT_SECRET` | (obrigatória) | Chave HS256 dos tokens, com 32 caracteres ou mais. |
| `JWT_TTL` | `24h` | Validade de cada token. |
| `AI_PROVIDER` | `anthropic` | `anthropic`, `openai` ou `none`. |
| `ANTHROPIC_API_KEY` | | Chave da Anthropic. |
| `ANTHROPIC_MODEL` | `claude-opus-5-5` | Modelo da Anthropic. |
| `OPENAI_API_KEY` | | Chave da OpenAI. |
| `OPENAI_MODEL` | `gpt-5-mini` | Modelo da OpenAI. |
| `AI_TIMEOUT` | `120s` | Tempo máximo de uma chamada de IA. |
| `AI_PROVIDER_TIMEOUT` | `90s` | Tempo máximo de cada requisição HTTP ao provedor. |
| `AI_RATE_LIMIT_PER_MINUTE` | `10` | Chamadas de IA por usuário, por minuto. |
| `DATABASE_URL` | PostgreSQL local | Conexão com o banco (`postgresql+asyncpg://...`). |
| `LOG_LEVEL` | `INFO` | Nível dos logs. |

## Encontros

A tabela `monsters` tem os 334 monstros do SRD 5.1, com nome, tamanho, tipo, CR e XP. A migração `0002` importa os dados de `migrations/data/srd_5_1_monsters.csv`, gerado da API 5e-bits (`/api/2014`). A fonte tinha o XP errado em quatro monstros, e a tabela de XP por CR do SRD corrigiu esses valores. O teste `test_imported_monsters_follow_the_xp_table` confere o arquivo todo.

O cálculo de dificuldade fica em `critsense/encounters/rules.py`, sem banco e sem IA. Ele segue a regra "Combat Encounter Difficulty" do SRD 5.2.1, porque o SRD 5.1 não tem regras de dificuldade:

1. A dificuldade é `LOW`, `MODERATE` ou `HIGH`.
2. O orçamento do grupo é a soma do valor da tabela "XP Budget per Character" para o nível de cada personagem.
3. O XP dos monstros gasta o orçamento, sem multiplicador. Um encontro é da menor dificuldade cujo orçamento cobre o XP total. Acima do orçamento de `HIGH`, ele é `BEYOND_HIGH`.

O endpoint `POST /api/v1/encounters/build` (tarefa T2.4) ainda não existe.

## Contrato OpenAPI

O contrato fica versionado em [../contracts/openapi.yaml](../contracts/openapi.yaml). Depois de mudar um endpoint, atualize o arquivo:

```bash
cd api && uv run python -m critsense.openapi
```

O `tests/test_contract.py` falha (também no CI) quando o arquivo está diferente do contrato gerado pelo código.
