# ⚔️ CritSense

**Projeto de estudo em Flutter e Java, com experimentos de IA no Android e numa API própria.** O tema é um app companheiro de D&D 5e: ficha de personagem pelas regras do SRD 5.1, compêndio (magias, equipamentos e bestiário), rastreador de iniciativa e rolador de dados. As fichas ficam no aparelho, e o compêndio funciona sem internet depois da primeira consulta.

> [!NOTE]
> O CritSense não é um produto. Ele serve para praticar arquitetura, testes e CI, e para testar recursos de IA em dois lugares: no próprio aparelho Android e numa API em Java. O [Guia de Estudo](docs/ESTUDO.md) resume a arquitetura, as decisões técnicas e um roteiro de leitura do código.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.12.1-0175C2?logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Drift-003B57?logo=sqlite&logoColor=white)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-5C2D91)
![Material 3](https://img.shields.io/badge/Design-Material%203-757575?logo=materialdesign&logoColor=white)
![Java](https://img.shields.io/badge/Java-21-ED8B00?logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.1-6DB33F?logo=springboot&logoColor=white)
![Spring AI](https://img.shields.io/badge/Spring%20AI-2.0-6DB33F?logo=spring&logoColor=white)

---

## 🎯 Objetivos de Estudo

| Área | O que o projeto pratica |
|---|---|
| **Flutter** | Clean Architecture, BLoC/Cubit, `get_it`, Drift/SQLite com migrações, cache offline com `Dio`, testes de widget e de migração. |
| **Java** | Spring Boot 4, Spring Security com JWT, Flyway, PostgreSQL, Testcontainers, contrato OpenAPI e erros RFC 9457. |
| **IA na API** | Spring AI com provedor configurável, saída em JSON validada, prompts versionados, rate limit e timeout. |
| **IA no Android** | Comandos por voz com regras fixas e Gemini Nano (ML Kit GenAI) no aparelho, canal Kotlin próprio e resumo de sessão sem enviar as notas para a nuvem. |
| **Processo** | Monorepo, CI separado por pasta no GitHub Actions e roadmap por fases em [docs/ROADMAP.md](docs/ROADMAP.md). |

---

## 📁 Estrutura do Repositório

| Pasta | Conteúdo |
|---|---|
| [app/](app/) | App Flutter (fichas, compêndio e rolador de dados). |
| [api/](api/) | API em Java (Spring Boot): autenticação e ferramentas de IA. Veja o [README da API](api/README.md). |
| [contracts/](contracts/) | Contrato OpenAPI da API, usado para gerar os clientes. |
| [docs/](docs/) | [Roadmap](docs/ROADMAP.md) e [Guia de Estudo](docs/ESTUDO.md) com a arquitetura e as decisões técnicas. |
| `docker-compose.yml` | Ambiente local: API + PostgreSQL. |

---

## 🏗️ Arquitetura do App

O projeto é estruturado sob os princípios de **Clean Architecture**, com cada feature isolada em três camadas — `domain`, `data` e `presentation` — garantindo baixo acoplamento, alta testabilidade e regras de negócio livres de dependências de framework ou infraestrutura.

* **Injeção de Dependência (`get_it`):** todo o grafo de dependências (DataSources → Repositories → Use Cases → BLoCs) é registrado centralmente em [app/lib/di/injection_container.dart](app/lib/di/injection_container.dart), com `LazySingleton` para recursos compartilhados (conexão SQLite, cliente HTTP) e `Factory` para estado de UI isolado por tela.
* **Gerenciamento de estado previsível (`flutter_bloc`):** cada feature expõe seu estado através de eventos e states imutáveis (atualizados via `copyWith`), eliminando mutação implícita e tornando toda transição de estado rastreável e testável. As telas não chamam use cases diretamente: todo acesso a dados passa por um BLoC/Cubit.
* **Persistência local com Drift/SQLite:** camada de dados com migrações versionadas (`MigrationStrategy`), transações atômicas, UPSERTs e cascade delete via foreign keys. Os dados das fichas não dependem de conexão.
* **Integração cruzada entre features:** o módulo `compendium` dispara eventos diretamente nos BLoCs de `character_sheet` (ex: `AddInventoryItemEvent`, `AddSpellToCharacterEvent`, `AddBossToCharacterEvent`), mantendo baixo acoplamento sem um mediador central — cada feature conhece apenas o contrato do evento que dispara.

---

## ✨ Principais Funcionalidades

### 📜 Ficha de Personagem
* **Criação pelas regras do SRD:** compra de pontos, matriz padrão ou rolagem 4d6; bônus e deslocamento da raça; PV pelo dado de vida da classe; testes de resistência, proficiências de equipamento e idiomas preenchidos pela classe e pela raça.
* **Combate:** CA calculada pela armadura, pelo escudo e pela Defesa sem Armadura; iniciativa e bônus de proficiência pelo atributo e pelo nível; ataques das armas equipadas (acuidade, distância, versátil).
* **Vida e descanso:** dano com PV temporário, dano massivo, salvaguardas contra a morte, dados de vida no Descanso Curto e recuperação no Descanso Longo. O PV máximo também aceita ajuste manual.
* **Recursos de classe:** usos de Fúria, Ki, Surto de Ação, Canalizar Divindade e outros recursos do SRD, com recarga no Descanso Curto ou Longo.
* **Concentração:** marca a magia em concentração; depois de dano, o app mostra a CD do teste de CON e abre a rolagem.
* **Condições e exaustão:** as 14 condições do SRD e os 6 níveis de exaustão, com efeito no deslocamento e na vantagem/desvantagem das rolagens.
* **Magia:** espaços de magia pelas tabelas do SRD (incluindo a Magia de Pacto), CD e ataque mágico, grimório com magias preparadas e limite de truques e de magias conhecidas.
* **Inventário:** quantidade, peso e limite de carga, moedas, itens equipados e sintonia (máximo de 3).
* **Evolução:** XP pela tabela do SRD, subida de nível com PV (média ou rolagem), Aumento de Valor de Atributo, subclasse do SRD e as características de classe, subclasse e raça de cada nível.
* **Edição:** nome, raça, classe, tendência e foto podem mudar depois da criação.
* **Rolar direto da ficha:** perícias, testes de resistência, iniciativa, ataques e dano, com vantagem e desvantagem sugeridas pelas condições.
* **Backup:** exportar e importar personagens em JSON.
* **Diário de Campanha:** notas de sessão por personagem com criação via formulário validado e **exclusão com sistema de Undo** — a nota some da lista imediatamente e só é removida do banco se o usuário não tocar em "Desfazer" dentro da janela do `SnackBar`.
* **Persistência local:** todos os dados da ficha (atributos, proficiências, inventário, magias, notas, chefes derrotados) ficam no aparelho, com schema versionado e migrações incrementais no Drift. Antes de cada migração, o app copia o arquivo do banco.

### 📚 Compêndio D&D 5e
* Integração com a **API 5e-bits** via `Dio`, cobrindo **Magias**, **Equipamentos** e **Bestiário**, cada um com tela de listagem e detalhe dedicadas (stat blocks completos para monstros, componentes/duração para magias, dano/CA para equipamentos).
* Busca por nome e filtros rápidos (nível, categoria, Classe de Desafio) combinados em um único fluxo reativo por feature.
* **Sem internet:** um interceptor do `Dio` guarda no banco cada resposta do compêndio. Sem conexão, o app usa a última cópia; só o que nunca foi consultado mostra o estado de erro.

### 🔗 Integração Cruzada (Compêndio → Personagem)
* Adição direta de **magias** e **itens de equipamento** ao inventário de um personagem a partir das telas de detalhe do compêndio.
* Registro de **chefes/monstros derrotados** vinculados ao personagem, direto da tela de detalhe do Bestiário.
* Toda a persistência dessas ações é gravada no banco **Drift/SQLite** do personagem, sem acoplamento direto entre os módulos de `compendium` e `character_sheet`.

### ⚔️ Rastreador de Iniciativa
* Combate com personagens da lista, monstros do bestiário (CA, PV e DES) e outras criaturas.
* Rola a iniciativa, ordena, passa o turno e conta as rodadas. O combate fica salvo ao fechar o app.

### 🎙️ Comandos por Voz (IA no aparelho)
* **Microfone na ficha:** "levei 8 de dano", "curar 5", "rolar 2d6 mais 3", "descanso curto", "concentrar em Bless" e "anotar o rei mentiu".
* **Microfone no rastreador:** "o lobo leva 8 de dano", "cura o goblin em 3" e "próximo turno".
* **Ditado e resumo:** o Diário de Campanha aceita notas ditadas e resume a sessão com o Gemini Nano.
* **Como funciona:** a fala vira texto no aparelho (pt-BR). Regras fixas entendem as frases simples em qualquer celular. O Gemini Nano só entra nas frases livres, nos aparelhos com suporte, e devolve um JSON que o app valida.
* **Segurança da ficha:** o app sempre mostra o comando entendido e só aplica depois da confirmação. As regras do SRD continuam no código: a IA nunca calcula PV nem dados.

### 🎲 Rolador de Dados
* Pool com múltiplos tipos e quantidades de dados (d4 a d100).
* Histórico das 50 rolagens mais novas, do rolador e da ficha.
* Modificador global configurável e modos de **vantagem/desvantagem** aplicados especificamente ao d20.
* **Suporte a hardware:** disparo de rolagem via sensor de movimento do dispositivo (shake), além do CTA manual fixo na tela, e vibração em acerto crítico e falha crítica. Os canais nativos estão em `MainActivity.kt` (Android) e `AppDelegate.swift` (iOS). A versão iOS ainda não foi compilada nem testada num aparelho.

### 🔐 Login
* A tela de login é só visual: ela valida os campos e abre a Home, sem autenticação real. A API já tem cadastro e login com JWT; ligar o app a ela é a tarefa T1.16 do [roadmap](docs/ROADMAP.md).

---

## 🎨 Destaques de UI/UX e Performance

* **Design System em Material Design 3:** paleta inteira derivada de uma única semente via `ColorScheme.fromSeed`, com temas claro/escuro consistentes e cores semânticas reservadas (verde/vermelho) para sucesso e falha crítica. O tema escolhido fica salvo entre aberturas do app (`ThemeCubit` + `shared_preferences`).
* **Busca reativa com `RxDart`:** transformador de eventos customizado aplica `debounceTime` + `switchMap` nos BLoCs de busca do compêndio, cancelando requisições obsoletas e evitando chamadas excessivas à API a cada tecla digitada.
* **Skeleton Loading com `shimmer`:** transições suaves entre estados de carregamento e conteúdo real, com esqueletos que imitam o layout final (listagens e telas de detalhe).
* **Paginação infinita:** Bestiário consumido sob demanda via `ScrollController`, disparando novas páginas ao atingir 90% do scroll, sem travar a renderização de listas extensas.

---

## 🧠 API e Inteligência Artificial

A IA é a parte experimental do projeto. Ela tem duas frentes:

1. **IA no Android (Fase G):** comandos por voz e resumo de sessão com o Gemini Nano pelo ML Kit GenAI Prompt API (beta), num canal Kotlin próprio (`OnDeviceAiChannel.kt`). O modelo roda no AICore do Android e só existe em alguns celulares; nos outros, as regras fixas continuam funcionando.
2. **IA na API (primeiro experimento pronto):** a pasta [api/](api/) tem a API própria do CritSense, em Java 21 com Spring Boot 4.1 e Spring AI 2.0. O app ainda não chama a API; essa ligação está pausada no [roadmap](docs/ROADMAP.md).

O que a API já tem:

* **Gerador de NPCs** (`POST /api/v1/npcs/generate`): a IA cria nome, raça, personalidade, segredo e ganchos de aventura, sempre em JSON validado contra um schema. Uma resposta inválida recebe uma nova tentativa com a lista de erros; se continuar inválida, a API devolve um erro, nunca um JSON quebrado.
* **Provedor configurável:** Anthropic (padrão, `claude-opus-5-5`) ou OpenAI, escolhido pela variável `AI_PROVIDER`. A chave fica só no backend.
* **Autenticação JWT**, **rate limit por usuário** (Bucket4j) e **timeout** em toda chamada de IA.
* **Prompts versionados** em `api/src/main/resources/prompts/`.
* **Contrato OpenAPI** em [contracts/openapi.yaml](contracts/openapi.yaml), verificado no CI.
* **Erros no formato RFC 9457** (`application/problem+json`), com um `code` estável.

Como rodar a API, os endpoints e as variáveis de ambiente estão no [README da API](api/README.md).

---

## 🚀 Como Rodar o App

**Pré-requisitos:** Flutter SDK (compatível com Dart `^3.12.1`) e um emulador/dispositivo configurado.

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd crit_sense/app

# 2. Instale as dependências
flutter pub get

# 3. Gere o código do Drift (tabelas/queries do banco local)
dart run build_runner build --delete-conflicting-outputs

# 4. Rode o app
flutter run
```

**Testes e análise estática:**

```bash
flutter test
flutter analyze
```

Os testes usam `mocktail` e cobrem os BLoCs de todas as features, as regras de rolagem do `DiceRepositoryImpl`, o `CharacterRepositoryImpl` e as migrações do Drift (com um banco SQLite em memória). O pacote `bloc_test` está no `pubspec.yaml`, mas os testes não o usam: ele conflita com os `dependency_overrides` necessários para o `drift_dev` (ver o comentário no `pubspec.yaml`).

**Build de release (Android):**

1. Crie uma chave de upload com o `keytool` (o comando está em [app/android/key.properties.example](app/android/key.properties.example)).
2. Copie `app/android/key.properties.example` para `app/android/key.properties` e preencha os dados da chave.
3. Gere o APK:

```bash
flutter build apk --release
```

Sem o `app/android/key.properties`, o release é assinado com a chave de debug. Esse APK serve para testes, mas não para publicação.

---

## 🗺️ Roadmap

O lado servidor da Fase 1 (API, autenticação, gerador de NPCs e CI) está pronto. As próximas tarefas (ligar o app à API, encontros, resumo de sessão e narração com streaming) estão em [docs/ROADMAP.md](docs/ROADMAP.md).

---

## 📄 Licenças e Atribuições

**Código do CritSense.** O código deste repositório está sob a [PolyForm Strict License 1.0.0](LICENSE).

* **O que a licença permite:** ler, estudar e rodar o código para fins pessoais e não comerciais, e também em organizações sem fins lucrativos (ensino, pesquisa, caridade, governo).
* **O que a licença não permite:** distribuir o código, publicar versões modificadas, criar obras derivadas ou usar o código para fins comerciais.
* **Outros usos:** para qualquer uso fora destes termos, peça uma licença separada ao autor.

**Versões anteriores.** A PolyForm Strict vale a partir do commit que adicionou o arquivo [LICENSE](LICENSE). Os commits anteriores não tinham licença. Sem licença, todos os direitos já eram reservados ao autor, e esses commits continuam assim. Nenhuma versão anterior deu permissão de cópia, de modificação ou de distribuição.

**Conteúdo de terceiros.** A PolyForm Strict cobre só o código do CritSense. O conteúdo do SRD 5.1, os ícones abaixo e os scripts do Maven Wrapper (`api/mvnw`, Apache-2.0) continuam sob as licenças originais deles. As dependências do app e da API também mantêm as suas licenças.

**Conteúdo de regras (SRD 5.1).** This work includes material taken from the System Reference Document 5.1 ("SRD 5.1") by Wizards of the Coast LLC and available at https://dnd.wizards.com/resources/systems-reference-document. The SRD 5.1 is licensed under the Creative Commons Attribution 4.0 International License available at https://creativecommons.org/licenses/by/4.0/legalcode.

**Dados do compêndio.** As magias, equipamentos e monstros vêm da [D&D 5e API](https://www.dnd5eapi.co) do projeto [5e-bits](https://github.com/5e-bits), que publica o conteúdo do SRD 5.1.

**Ícones.** Os ícones em `app/assets/icons/` são o [Intrinsical's D&D 5e Icon Set](https://github.com/intrinsical/tw-dnd/tree/main/icons), de [David Kor Kian Wei](https://github.com/intrinsical), sob a licença [Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/). O texto da licença está em [app/assets/icons/LICENSE](app/assets/icons/LICENSE).

**Outros arquivos de terceiros.** Estes arquivos não são do autor do CritSense e não estão sob a PolyForm Strict. Os direitos continuam com os donos originais:

* `dd-5e-ficha-de-personagem-biblioteca-elfica.pdf`: ficha de personagem de D&D 5e em português, da Biblioteca Élfica. O arquivo serve só como referência visual da ficha.
* `app/assets/sounds/dice_roll.mp3` e `app/assets/sounds/dices_roll.mp3`: sons de rolagem de dados. A origem e a licença destes sons ainda não estão registradas.

O CritSense não tem vínculo com a Wizards of the Coast nem é endossado por ela.
