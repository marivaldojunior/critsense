# CritSense — Roadmap e tarefas

Este documento compara a proposta de direção do projeto com o estado atual do repositório.
Depois, ele lista as tarefas em fases. Marque cada tarefa com `[x]` quando ela estiver pronta.

---

## 1. Análise da proposta

### 1.1 O que a proposta aproveita do app atual

| Proposta | O que já existe no app | Adaptação |
|---|---|---|
| Resumo de sessão | As notas de sessão já ficam no Drift (`SessionNote`: `title`, `content`, `createdAt`). | O app envia as notas locais para a API. A API não precisa guardar as notas no MVP. |
| Gerador de NPCs | Não existe. | Crie a feature `lib/features/ai_tools/` com as camadas `domain`, `data` e `presentation`, igual às outras features. |
| Montador de encontros | O Bestiário já lê monstros da API 5e-bits. As entidades de domínio não têm `challengeRating` nem XP. | A API Java precisa de uma base própria de monstros do SRD com CR e XP. O cálculo determinístico não pode depender de uma API externa. |
| Login | A [login_screen.dart](../app/lib/features/auth/presentation/screens/login_screen.dart) só valida campos vazios. | O rate limit "por usuário" precisa de uma identidade real. Ligue a tela de login a uma autenticação real da API. |
| Cliente HTTP | Existe um `Dio` singleton sem `baseUrl` e sem timeout. | Registre um segundo `Dio` só para a API do CritSense, com `baseUrl` por `--dart-define`, timeout e interceptor de token. |
| Offline-first | A ficha funciona offline. O compêndio não funciona. | As features de IA precisam de rede. Mostre um estado "sem conexão" claro e não bloqueie o resto do app. |

### 1.2 Pontos da proposta que precisam de ajuste

1. **Versão do Spring Boot.** A proposta pede Spring Boot 3.x. O Spring Boot 4.0 foi lançado em novembro de 2025, e o suporte gratuito da linha 3.5 terminou em 2026. Verifique as versões atuais no [Spring Initializr](https://start.spring.io) antes de criar o projeto. A recomendação é usar o Spring Boot 4.x com a versão do Spring AI compatível com ele.
2. **Java.** O Java 21 funciona bem. O Java 25 também é LTS. Escolha um dos dois e use a mesma versão no Docker e no CI.
3. **SSE e cliente gerado.** Os geradores OpenAPI para Dart (`dart-dio`) não tratam bem respostas `text/event-stream`. Use o cliente gerado para os endpoints comuns. Escreva um cliente SSE manual para a narração, com `Dio` e `ResponseType.stream`.
4. **Conflito de dependências.** O `pubspec.yaml` força `analyzer: ^13.0.0` em `dependency_overrides`. O cliente gerado pode usar `built_value` ou `json_serializable`, que dependem do `analyzer`. Gere o cliente como um pacote separado (`app/packages/critsense_api_client`) e teste o `build_runner` antes de integrar.
5. **Autenticação.** A proposta não define a autenticação, mas o rate limit depende dela. Para o MVP, use JWT com Spring Security e um cadastro simples (usuário e senha). Não guarde a senha no app. Guarde só o token, com `flutter_secure_storage`.
6. **Licenças.** A proposta cita o SRD 5.1 (CC-BY-4.0). O SRD 5.2 também é CC-BY-4.0, mas use uma só versão para os dados de regras. Os ícones de `assets/icons/` usam CC-BY-SA 4.0, e o README atual não tem essa atribuição.
7. **Prompts.** Guarde os prompts em `api/src/main/resources/prompts/` como templates (`.st`), com uma pasta por versão (ex.: `prompts/npc-generator/v1/system.st` e `user.st`).

### 1.3 Estrutura do repositório

Cada projeto fica na sua própria pasta: o app Flutter em `app/` e a API em `api/`. O contrato OpenAPI fica no mesmo repositório.

```
crit_sense/
├── app/                          # App Flutter
│   ├── lib/, test/, android/, ios/
│   └── packages/critsense_api_client/   # Cliente Dart gerado do OpenAPI
├── api/                          # API Java (Spring Boot)
│   ├── src/main/resources/prompts/
│   └── src/main/resources/db/migration/   # Flyway
├── contracts/openapi.yaml        # Contrato exportado pela API
├── docker-compose.yml            # API + PostgreSQL
├── docs/
└── .github/workflows/            # CI separado por pasta (paths)
```

O CI usa filtros de `paths`: o workflow do Flutter roda só quando `app/` muda, e o workflow da API roda só quando `api/` ou `contracts/` mudam.

### 1.4 Fluxo de uma chamada de IA

```
App Flutter ──JWT──▶ API (Spring Security)
                      ├─ Bucket4j: verifica o limite do usuário
                      ├─ Regras determinísticas (ex.: XP/CR do encontro)
                      ├─ Spring AI ──▶ Provedor LLM (chave só no backend)
                      ├─ Converte a saída para um record Java
                      └─ Valida com Bean Validation ──▶ resposta JSON ao app
```

Se a validação falhar, a API tenta mais uma vez. Se a segunda tentativa também falhar, a API devolve um erro `502` com um código claro, e não um JSON inválido.

---

## 2. Tarefas

### Fase 0 — Correções e melhorias do app atual

#### Segurança e build
- [x] **T0.1** Revogue o token do GitHub que está na URL do `origin` em `.git/config`. Crie outro token e use o Git Credential Manager. Não coloque o token na URL.
- [x] **T0.2** Adicione `<uses-permission android:name="android.permission.INTERNET"/>` ao [AndroidManifest.xml](../app/android/app/src/main/AndroidManifest.xml) principal. Sem esta permissão, o compêndio não funciona no APK de release.
- [x] **T0.3** Crie uma chave de assinatura de release e configure o `signingConfig` sem colocar a chave no repositório.
- [x] **T0.4** Atualize a `description` do `pubspec.yaml`. Revise se os `dependency_overrides` ainda são necessários.

#### Arquitetura
- [x] **T0.5** Crie um `SessionNotesBloc` e mova para ele as chamadas de use case da [session_notes_screen.dart](../app/lib/features/character_sheet/presentation/pages/session_notes_screen.dart).
- [x] **T0.6** Crie um `InventoryBloc` e mova para ele as chamadas de use case da [inventory_spells_tab.dart](../app/lib/features/character_sheet/presentation/pages/character_sheet_tabs/inventory_spells_tab.dart).
- [x] **T0.7** Faça o shake passar pelo `ISensorDataSource` e pelo `DiceBloc`. Remova o uso direto do `HardwareBridge` na [dice_screen.dart](../app/lib/features/dice_roller/presentation/pages/dice_screen.dart).
- [x] **T0.8** Configure o `Dio` com `BaseOptions` (`baseUrl`, `connectTimeout`, `receiveTimeout`). Remova as URLs repetidas do datasource do compêndio.
- [x] **T0.9** Salve o tema escolhido pelo usuário. Corrija o botão de tema, que para de funcionar depois do logout.

#### Plataformas
- [x] **T0.10** Implemente os canais `feedback` e `sensor` no [AppDelegate.swift](../app/ios/Runner/AppDelegate.swift), ou documente que o iOS não tem vibração nem shake.
  - [ ] **T0.10a** Compile e teste o app num iPhone (precisa de um Mac). O código Swift foi escrito sem compilar.

#### Testes
- [x] **T0.11** Escreva testes para o `DiceBloc` (pool, modificador, vantagem e desvantagem).
- [x] **T0.12** Escreva testes para o `PointBuyCubit` (custo, limite de 27 pontos).
- [x] **T0.13** Escreva testes para os BLoCs do compêndio (debounce, filtros, paginação do Bestiário).
- [x] **T0.14** Escreva testes para o `CharacterRepositoryImpl` e as migrações do Drift, com banco em memória.

#### Documentação
- [x] **T0.15** Corrija o README: o compêndio não é offline, o login não autentica e o iOS não tem os canais nativos.
- [x] **T0.16** Adicione ao README a atribuição dos ícones (CC-BY-SA 4.0) e do SRD (CC-BY-4.0).

#### Bugs encontrados durante a Fase 0
- [x] **T0.17** Salve as proficiências do personagem no banco. Antes, a tabela `characters` não tinha uma coluna para elas, e as perícias e os testes de resistência marcados se perdiam ao reabrir o app.

### Fase 1 — API base e primeiro endpoint de IA (NPC)

#### Estrutura
- [x] **T1.1** Crie o projeto Spring Boot em `api/` (Web, Validation, Security, Data JPA, Flyway, PostgreSQL, Actuator, Spring AI).
- [x] **T1.2** Crie o `docker-compose.yml` na raiz com a API e o PostgreSQL.
- [x] **T1.3** Configure o provedor do LLM por variável de ambiente. Crie um `.env.example` sem valores reais e adicione `.env` ao `.gitignore`.
- [ ] **T1.4** Configure o springdoc-openapi e exporte o contrato para `contracts/openapi.yaml`.
- [x] **T1.5** Crie um formato único de erro (`ProblemDetail`, RFC 9457) para todos os endpoints.

#### Autenticação e limites
- [x] **T1.6** Crie o cadastro e o login com JWT (Spring Security). Crie a tabela de usuários com Flyway.
- [x] **T1.7** Adicione rate limit por usuário com Bucket4j nos endpoints de IA. Devolva `429` com o cabeçalho `Retry-After`.
- [x] **T1.8** Configure timeout e retry nas chamadas ao LLM. Devolva `504` quando o provedor demorar demais.

#### Gerador de NPCs
- [x] **T1.9** Crie o prompt versionado `prompts/npc-generator/v1/` (`system.st` e `user.st`).
- [x] **T1.10** Crie o endpoint `POST /api/v1/npcs/generate`. Converta a saída para um record Java e valide com Bean Validation.
- [x] **T1.11** Escreva testes com JUnit 5 e Testcontainers. Use um `ChatModel` falso nos testes, para não chamar o provedor real no CI.

#### CI
- [ ] **T1.12** Crie o workflow da API (build, testes, lint) com filtro `paths: api/**`.
- [ ] **T1.13** Crie o workflow do Flutter (`flutter analyze`, `flutter test`) com filtro de `paths`.
- [ ] **T1.14** Adicione no CI uma verificação de que o `contracts/openapi.yaml` está igual ao contrato gerado pela API.

#### Lado Flutter
- [ ] **T1.15** Gere o cliente Dart do OpenAPI em `app/packages/critsense_api_client`. Teste se ele funciona com os `dependency_overrides` atuais.
- [ ] **T1.16** Ligue a tela de login à API. Guarde o token com `flutter_secure_storage`.
- [ ] **T1.17** Crie a feature `ai_tools` com a tela do gerador de NPCs. Trate os estados de carregamento, erro, limite atingido (`429`) e sem conexão.

### Fase 2 — Encontros e resumo de sessão

#### Montador de encontros
- [ ] **T2.1** Importe os monstros do SRD (nome, CR, XP, tipo) para o PostgreSQL com uma migração Flyway.
- [ ] **T2.2** Implemente o cálculo determinístico de dificuldade (limites de XP por nível, multiplicador por número de monstros).
- [ ] **T2.3** Escreva testes unitários para o cálculo, com os exemplos das tabelas do SRD.
- [ ] **T2.4** Crie o endpoint `POST /api/v1/encounters/build`. A IA recebe os monstros já escolhidos e cria só a ambientação e a descrição.
- [ ] **T2.5** Crie a tela de encontros no app (nível do grupo, tamanho do grupo, dificuldade).

#### Resumo de sessão
- [ ] **T2.6** Crie o endpoint `POST /api/v1/sessions/summarize`. Ele recebe as notas no corpo da requisição. Defina um tamanho máximo para o texto.
- [ ] **T2.7** Adicione na tela de notas de sessão um botão "Resumir sessão" que envia as notas do Drift para a API.

### Fase 3 — Narração com streaming (SSE)

- [ ] **T3.1** Crie o endpoint `GET` ou `POST /api/v1/narration/stream` com `text/event-stream`, usando o streaming do Spring AI.
- [ ] **T3.2** Defina os eventos SSE (`token`, `done`, `error`) e documente esses eventos no contrato.
- [ ] **T3.3** Aplique o rate limit e um tempo máximo para cada stream.
- [ ] **T3.4** Escreva um cliente SSE manual no Flutter com `Dio` e `ResponseType.stream`.
- [ ] **T3.5** Crie a tela de narração. Mostre o texto em tempo real e permita cancelar o stream.

### Fase 4 — Front React (futuro)

- [ ] **T4.1** Crie o projeto React em `web-client/` e gere o cliente TypeScript do mesmo `contracts/openapi.yaml`.
- [ ] **T4.2** Configure o CORS da API só para as origens do front.

### Documentação final (contínua)

- [ ] **T5.1** Adicione ao README um diagrama de arquitetura (app, API, PostgreSQL, provedor LLM).
- [ ] **T5.2** Grave um GIF do app e adicione ao README.
- [ ] **T5.3** Escreva a seção "Como rodar localmente" com o Docker Compose e o `flutter run --dart-define`.
- [ ] **T5.4** Escreva a seção "Decisões técnicas": monorepo, cálculo determinístico mais IA, JWT, SSE manual e escolha das versões.

---

## 3. Ordem recomendada

1. Faça a T0.1 primeiro: ela é um risco de segurança.
2. Faça a T0.2: ela é um bug de release.
3. Faça as tarefas de arquitetura (T0.5 a T0.8) antes da Fase 1. A nova feature `ai_tools` vai copiar esses padrões.
4. Comece a Fase 1 pela estrutura e pela autenticação (T1.1 a T1.8), e só depois faça o NPC.
