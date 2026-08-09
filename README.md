# ⚔️ CritSense

**Companion app completo para mestres e jogadores de D&D 5e** — gerenciamento de fichas de personagem, compêndio oficial (magias, equipamentos e bestiário) e rolador de dados físico, tudo em um único app **offline-first**, construído com padrões de arquitetura de nível corporativo.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.12.1-0175C2?logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Drift-003B57?logo=sqlite&logoColor=white)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-5C2D91)
![Material 3](https://img.shields.io/badge/Design-Material%203-757575?logo=materialdesign&logoColor=white)

---

## 🏗️ Visão Geral e Arquitetura

O projeto é estruturado sob os princípios de **Clean Architecture**, com cada feature isolada em três camadas — `domain`, `data` e `presentation` — garantindo baixo acoplamento, alta testabilidade e regras de negócio livres de dependências de framework ou infraestrutura.

* **Injeção de Dependência (`get_it`):** todo o grafo de dependências (DataSources → Repositories → Use Cases → BLoCs) é registrado centralmente em [lib/di/injection_container.dart](lib/di/injection_container.dart), com `LazySingleton` para recursos compartilhados (conexão SQLite, cliente HTTP) e `Factory` para estado de UI isolado por tela.
* **Gerenciamento de estado previsível (`flutter_bloc`):** cada feature expõe seu estado através de eventos e states imutáveis (`Equatable`), eliminando mutação implícita e tornando toda transição de estado rastreável e testável — coberto com testes de BLoC usando `bloc_test` e `mocktail`.
* **Persistência local com Drift/SQLite:** camada de dados com migrações versionadas (`MigrationStrategy`), transações atômicas, UPSERTs e cascade delete via foreign keys — sem depender de conectividade para uso contínuo do app (*Offline-First*).
* **Integração cruzada entre features:** o módulo `compendium` dispara eventos diretamente nos BLoCs de `character_sheet` (ex: `AddInventoryItemEvent`, `AddSpellToCharacterEvent`, `AddBossToCharacterEvent`), mantendo baixo acoplamento sem um mediador central — cada feature conhece apenas o contrato do evento que dispara.

---

## ✨ Principais Funcionalidades

### 📜 Ficha de Personagem
* **Criação via Point Buy:** alocação dos 27 pontos entre os seis atributos, com regras de custo/limite aplicadas em tempo real (`PointBuyCubit`).
* **Status de Combate completo:** Classe de Armadura, iniciativa, deslocamento, pontos de vida (atuais/máximos/temporários), experiência e bônus de proficiência.
* **Diário de Campanha:** notas de sessão por personagem com criação via formulário validado e **exclusão com sistema de Undo** — a nota some da lista imediatamente e só é removida do banco se o usuário não tocar em "Desfazer" dentro da janela do `SnackBar`.
* **Persistência local offline-first:** todos os dados (atributos, inventário, magias, notas, chefes derrotados) sobrevivem sem conexão, com schema versionado e migrações incrementais no Drift.

### 📚 Compêndio D&D 5e
* Integração com a **API 5e-bits** via `Dio`, cobrindo **Magias**, **Equipamentos** e **Bestiário**, cada um com tela de listagem e detalhe dedicadas (stat blocks completos para monstros, componentes/duração para magias, dano/CA para equipamentos).
* Busca por nome e filtros rápidos (nível, categoria, Classe de Desafio) combinados em um único fluxo reativo por feature.

### 🔗 Integração Cruzada (Compêndio → Personagem)
* Adição direta de **magias** e **itens de equipamento** ao inventário de um personagem a partir das telas de detalhe do compêndio.
* Registro de **chefes/monstros derrotados** vinculados ao personagem, direto da tela de detalhe do Bestiário.
* Toda a persistência dessas ações é gravada no banco **Drift/SQLite** do personagem, sem acoplamento direto entre os módulos de `compendium` e `character_sheet`.

### 🎲 Rolador de Dados
* Pool com múltiplos tipos e quantidades de dados (d4 a d100).
* Modificador global configurável e modos de **vantagem/desvantagem** aplicados especificamente ao d20.
* **Suporte a hardware:** disparo de rolagem via sensor de movimento do dispositivo (shake), além do CTA manual fixo na tela.

---

## 🎨 Destaques de UI/UX e Performance

* **Design System em Material Design 3:** paleta inteira derivada de uma única semente via `ColorScheme.fromSeed`, com temas claro/escuro consistentes e cores semânticas reservadas (verde/vermelho) para sucesso e falha crítica.
* **Busca reativa com `RxDart`:** transformador de eventos customizado aplica `debounceTime` + `switchMap` nos BLoCs de busca do compêndio, cancelando requisições obsoletas e evitando chamadas excessivas à API a cada tecla digitada.
* **Skeleton Loading com `shimmer`:** transições suaves entre estados de carregamento e conteúdo real, com esqueletos que imitam o layout final (listagens e telas de detalhe).
* **Paginação infinita:** Bestiário consumido sob demanda via `ScrollController`, disparando novas páginas ao atingir 90% do scroll, sem travar a renderização de listas extensas.

---

## 🚀 Como Rodar o Projeto

**Pré-requisitos:** Flutter SDK (compatível com Dart `^3.12.1`) e um emulador/dispositivo configurado.

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd crit_sense

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
