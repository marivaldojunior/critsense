# CritSense API

API em Java do CritSense: autenticação e ferramentas de IA para mestres de D&D 5e. O app Flutter (`../app`) e o futuro front React consomem o mesmo contrato OpenAPI ([../contracts/openapi.yaml](../contracts/openapi.yaml)).

## Stack

- Java 21 e Spring Boot 4.1
- Spring AI 2.0, com o provedor escolhido por variável de ambiente (Anthropic por padrão, ou OpenAI)
- PostgreSQL 17 e Flyway
- Spring Security com JWT (HS256)
- Bucket4j para o rate limit por usuário
- springdoc-openapi para o contrato
- JUnit 5, Mockito e Testcontainers
- Spotless (palantir-java-format) como lint

## Como rodar

### Com Docker Compose (API + PostgreSQL)

1. Na raiz do repositório, copie `.env.example` para `.env`.
2. Preencha `JWT_SECRET` (no mínimo 32 caracteres) e a chave do provedor de IA (`ANTHROPIC_API_KEY` ou `OPENAI_API_KEY`).
3. Suba os serviços:

```bash
docker compose up --build
```

A API fica em `http://localhost:8080`. A documentação interativa fica em `http://localhost:8080/swagger-ui.html`.

### Só a API, com o PostgreSQL do Docker Compose

```bash
docker compose up -d postgres
```

```bash
cd api && JWT_SECRET="troque-por-uma-chave-com-32-caracteres" ./mvnw spring-boot:run
```

### Testes e lint

```bash
cd api && ./mvnw verify
```

```bash
cd api && ./mvnw spotless:apply
```

Os testes com Testcontainers (PostgreSQL real) precisam do Docker. Sem Docker, eles são pulados, e os outros testes rodam normalmente. No CI, todos rodam. Nenhum teste chama um provedor de IA real: os testes usam o `FakeChatModel`.

## Endpoints

| Método | Caminho | Autenticação | Descrição |
|---|---|---|---|
| POST | `/api/v1/auth/register` | não | Cria uma conta e devolve um token. |
| POST | `/api/v1/auth/login` | não | Troca usuário e senha por um token. |
| GET | `/api/v1/me` | sim | Devolve o usuário do token. |
| POST | `/api/v1/npcs/generate` | sim | Gera um NPC com a IA (conta no rate limit). |
| GET | `/actuator/health` | não | Health check. |

Envie o token no cabeçalho `Authorization: Bearer <token>`.

## Erros

Toda resposta de erro usa `application/problem+json` (RFC 9457), com o campo `code`:

| Status | `code` | Quando |
|---|---|---|
| 400 | `VALIDATION_FAILED`, `MALFORMED_REQUEST` | Corpo inválido. `errors` lista os campos. |
| 401 | `UNAUTHORIZED`, `INVALID_CREDENTIALS` | Token ausente ou inválido, ou login errado. |
| 409 | `USERNAME_TAKEN` | Nome de usuário em uso. |
| 422 | `AI_REFUSED` | O modelo recusou o pedido. |
| 429 | `RATE_LIMITED` | Limite de IA atingido. Veja o cabeçalho `Retry-After`. |
| 502 | `AI_INVALID_OUTPUT`, `AI_PROVIDER_ERROR` | Resposta inválida da IA ou falha do provedor. |
| 503 | `AI_UNAVAILABLE` | Nenhum provedor de IA configurado. |
| 504 | `AI_TIMEOUT` | A IA demorou mais que `AI_TIMEOUT`. |

## Como a IA é usada

1. O endpoint aplica o rate limit do usuário (`@AiRateLimited`).
2. O `StructuredAiService` monta o prompt a partir dos arquivos versionados em `src/main/resources/prompts/<nome>/v<versão>/`.
3. O prompt leva o JSON Schema da resposta, gerado da classe Java (ex: `Npc`).
4. O `AiGateway` chama o provedor com tempo máximo e traduz as falhas para os erros da API.
5. A resposta é convertida e validada com Bean Validation e com as regras do endpoint (ex: a raça pedida).
6. Se a resposta for inválida, o modelo recebe a lista de erros e tem mais uma tentativa. Se continuar inválida, a API devolve 502.

A chave do provedor fica só na API. O app nunca chama o provedor diretamente.

## Variáveis de ambiente

Veja [../.env.example](../.env.example). As principais:

| Variável | Padrão | Descrição |
|---|---|---|
| `JWT_SECRET` | (obrigatória) | Chave HS256 dos tokens, com 32 caracteres ou mais. |
| `AI_PROVIDER` | `anthropic` | `anthropic` ou `openai`. |
| `ANTHROPIC_API_KEY` | | Chave da Anthropic. |
| `ANTHROPIC_MODEL` | `claude-opus-5-5` | Modelo da Anthropic. |
| `OPENAI_API_KEY` | | Chave da OpenAI. |
| `AI_TIMEOUT` | `120s` | Tempo máximo de uma chamada de IA. |
| `AI_RATE_LIMIT_PER_MINUTE` | `10` | Chamadas de IA por usuário, por minuto. |
| `DB_URL`, `DB_USER`, `DB_PASSWORD` | PostgreSQL local | Conexão com o banco. |

## Contrato OpenAPI

O contrato fica versionado em [../contracts/openapi.yaml](../contracts/openapi.yaml). Depois de mudar um endpoint, atualize o arquivo:

```bash
cd api && ./mvnw test -Dtest=OpenApiContractTest -Dopenapi.update=true
```

O `OpenApiContractTest` falha (também no CI) quando o arquivo está diferente do contrato gerado pelo código.
