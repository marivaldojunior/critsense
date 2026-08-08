# 🐉 D&D 5e Mobile Companion

Um aplicativo mobile robusto para gerenciamento de fichas de RPG e consulta ao compêndio do Dungeons & Dragons 5e. Construído com **Flutter**, este projeto aplica conceitos de engenharia de software corporativa, focado em performance, previsibilidade de estado e persistência de dados *Offline-First*.

## 📱 Funcionalidades

*   **Home:** Hub central com acesso rápido a todas as features e alternância entre tema claro/escuro.
*   **Ficha de Personagem (CRUD Local):** Criação e gerenciamento de personagens salvos no banco de dados local do dispositivo, com atributos definidos via Point Buy.
*   **Formulários Dinâmicos Paralelos:** Consumo simultâneo (`Future.wait`) das APIs de Raças e Classes para alimentar os formulários de criação, otimizando o tempo de resposta.
*   **Compêndio D&D 5e:** Consulta a Magias, Equipamentos e Bestiário direto da [D&D 5e API](https://www.dnd5eapi.co/), cada um com tela de detalhes dedicada:
    *   *Magias* — nível, tempo de conjuração, alcance, duração, componentes e descrição.
    *   *Equipamentos* — custo, peso, dano/alcance (armas) ou Classe de Armadura (armaduras).
    *   *Bestiário* — Stat Block completo (tamanho, tipo, tendência, CA, PV, deslocamento e ações de combate).
*   **Inventário Híbrido (Cross-Feature):** Consulta de equipamentos na API oficial e persistência dos itens escolhidos no banco SQLite (relacionamento *One-to-Many* com o personagem).
*   **Bestiário com Infinite Scroll:** Consumo da API de monstros com paginação em memória, utilizando `ScrollController` para renderização sob demanda de listas gigantes sem perda de frames.
*   **Rolador de Dados:** Montagem de um pool com múltiplos tipos de dado (d4 a d20, incluindo d100), modificador global, modos de vantagem/desvantagem no d20 e disparo de rolagem por *shake* do dispositivo (sensor nativo).
*   **Acesso a Hardware Nativo (Avatar):** Integração com a câmera e galeria do dispositivo para personalização do avatar do personagem, salvando a imagem de forma otimizada no diretório de documentos do app.
*   **Diário de Campanha:** Sistema de anotações por sessão atrelado a cada personagem.
*   **Identidade Visual Temática:** Ícones SVG próprios de D&D (widget `DnDIcon`) substituindo os ícones genéricos do Material Design nas telas principais, AppBars, listas e cards — catálogo completo documentado em [`assets/icons/README.md`](assets/icons/README.md).

## 🏗️ Arquitetura e Tecnologias

O projeto foi desenhado sob os princípios da **Clean Architecture**, dividindo cada feature em camadas de *Domain*, *Data* e *Presentation*, garantindo baixo acoplamento e alta testabilidade (conceitos familiares a ecossistemas como .NET e Java).

*   **[Flutter & Dart]**: Framework principal e linguagem (SDK ^3.12.1).
*   **[BLoC (Business Logic Component)]**: Gerenciamento de estado baseado em Eventos e Estados (padrão arquitetural semelhante ao CQRS).
*   **[Drift (SQLite)]**: ORM para persistência local de dados com segurança de tipagem e relacionamentos relacionais nativos.
*   **[Dio]**: Cliente HTTP para consumo da [D&D 5e API](https://www.dnd5eapi.co/).
*   **[GetIt]**: Service Locator para Injeção de Dependência (DI).
*   **[flutter_svg]**: Renderização dos ícones SVG temáticos via o widget `DnDIcon`.
*   **[Image Picker & Path Provider]**: Acesso nativo aos recursos de hardware e sistema de arquivos.
*   **[mocktail & bloc_test]**: Mocks e utilitários de teste para os BLoCs.

## 🚀 Como Executar o Projeto

**Pré-requisitos:**
*   Flutter SDK instalado (versão 3.x+, compatível com Dart ^3.12.1).
*   Emulador Android/iOS configurado ou dispositivo físico conectado.

**Passos:**

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd crit_sense

# 2. Instale as dependências
flutter pub get

# 3. Gere o código do Drift (tabelas/queries do banco local)
dart run build_runner build --delete-conflicting-outputs

# 4. Rode o app em um emulador/dispositivo conectado
flutter run
```

**Testes:**

```bash
flutter test
```

**Análise estática:**

```bash
flutter analyze
```
