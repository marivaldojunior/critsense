# 🐉 D&D 5e Mobile Companion

Um aplicativo mobile robusto para gerenciamento de fichas de RPG e consulta ao compêndio do Dungeons & Dragons 5e. Construído com **Flutter**, este projeto aplica conceitos de engenharia de software corporativa, focado em performance, previsibilidade de estado e persistência de dados *Offline-First*.

## 📱 Funcionalidades

*   **Ficha de Personagem (CRUD Local):** Criação e gerenciamento de personagens salvos no banco de dados local do dispositivo.
*   **Formulários Dinâmicos Paralelos:** Consumo simultâneo (`Future.wait`) das APIs de Raças e Classes para alimentar os formulários de criação, otimizando o tempo de resposta.
*   **Inventário Híbrido (Cross-Feature):** Consulta de equipamentos na API oficial e persistência dos itens escolhidos no banco SQLite (relacionamento *One-to-Many* com o personagem).
*   **Bestiário com Infinite Scroll:** Consumo da API de monstros com paginação em memória, utilizando `ScrollController` para renderização sob demanda de listas gigantes sem perda de frames.
*   **Acesso a Hardware Nativo (Avatar):** Integração com a câmera e galeria do dispositivo para personalização do avatar do personagem, salvando a imagem de forma otimizada no diretório de documentos do app.
*   **Diário de Campanha:** Sistema de anotações por sessão atrelado a cada personagem.

## 🏗️ Arquitetura e Tecnologias

O projeto foi desenhado sob os princípios da **Clean Architecture**, dividindo o sistema em camadas de *Domain*, *Data* e *Presentation*, garantindo baixo acoplamento e alta testabilidade (conceitos familiares a ecossistemas como .NET e Java).

*   **[Flutter & Dart]**: Framework principal e linguagem.
*   **[BLoC (Business Logic Component)]**: Gerenciamento de estado baseado em Eventos e Estados (padrão arquitetural semelhante ao CQRS).
*   **[Drift (SQLite)]**: ORM para persistência local de dados com segurança de tipagem e relacionamentos relacionais nativos.
*   **[Dio]**: Cliente HTTP para consumo da [D&D 5e API](https://www.dnd5eapi.co/).
*   **[GetIt]**: Service Locator para Injeção de Dependência (DI).
*   **[Image Picker & Path Provider]**: Acesso nativo aos recursos de hardware e sistema de arquivos.

## 🚀 Como Executar o Projeto

**Pré-requisitos:**
*   Flutter SDK instalado (versão 3.x+).
*   Emulador Android/iOS configurado ou dispositivo físico conectado.

1. Clone o repositório:
   ```bash
   git clone [https://github.com/marivaldojunior/critsense.git](https://github.com/marivaldojunior/critsense.git)