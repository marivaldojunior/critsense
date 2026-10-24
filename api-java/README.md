# CritSense API Java (estudo)

API em Java do CritSense: autenticação e ferramentas de IA para mestres de D&D 5e.

> A API principal agora é a [API Python](../api/README.md). Este projeto continua no repositório como estudo de Java e Spring. As duas APIs têm os mesmos endpoints e os mesmos códigos de erro. O app usa só a API Python.

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

### Com Docker Compose (API Java + PostgreSQL)

1. Na raiz do repositório, copie `.env.example` para `.env`.
2. Preencha `JWT_SECRET` (no mínimo 32 caracteres) e a chave do provedor de IA (`ANTHROPIC_API_KEY` ou `OPENAI_API_KEY`).
3. Suba os serviços do perfil `java`. A API Java tem um PostgreSQL próprio:

```bash
docker compose --profile java up --build api-java
```

A API fica em `http://localhost:8081`. A documentação interativa fica em `http://localhost:8081/swagger-ui.html`.

### Só a API, com o PostgreSQL do Docker Compose

Use um banco separado. O banco `critsense` é da API Python, e o Flyway não aceita as tabelas do Alembic.

1. Suba o PostgreSQL:

```bash
docker compose up -d postgres
```

2. Crie o banco da API Java:

```bash
docker compose exec postgres createdb -U critsense critsense_java
```

3. Suba a API:

```bash
cd api-java && DB_URL="jdbc:postgresql://localhost:5432/critsense_java" JWT_SECRET="troque-por-uma-chave-com-32-caracteres" ./mvnw spring-boot:run
```

### Testes e lint

```bash
cd api-java && ./mvnw verify
```

```bash
cd api-java && ./mvnw spotless:apply
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

O contrato da API Java fica em [openapi.yaml](openapi.yaml), separado do [../contracts/openapi.yaml](../contracts/openapi.yaml) da API Python. Depois de mudar um endpoint, atualize o arquivo:

```bash
cd api-java && ./mvnw test -Dtest=OpenApiContractTest -Dopenapi.update=true
```

O `OpenApiContractTest` falha (também no CI) quando o arquivo está diferente do contrato gerado pelo código.
