# 🎲 CritSense: Native Hardware RPG Roller

> Um aplicativo de rolagem de dados para RPG focado em imersão sensorial, construído com Flutter (UI/State) e Kotlin (Native Android Hardware).

Este projeto foi desenvolvido para demonstrar arquitetura de software avançada no ecossistema mobile, focando em separação de responsabilidades (Clean Architecture), gerenciamento de estado reativo (BLoC) e **comunicação bidirecional profunda com o hardware nativo do Android**.

## 🏗️ Arquitetura e Padrões Aplicados

Para garantir resiliência, escalabilidade e facilidade de testes, o projeto segue os princípios da **Clean Architecture**, dividindo a base de código em camadas estritas (`Domain`, `Data`, e `Presentation`).

*   **Gerenciamento de Estado:** `flutter_bloc`. Uso de `Equatable` para evitar reconstruções desnecessárias na árvore de widgets, garantindo alta performance de UI.
*   **Injeção de Dependência:** `get_it`. Registro de *Factories* e *LazySingletons* (análogo ao ciclo de vida de contêineres IoC do ecossistema .NET).
*   **Pattern Matching:** Uso avançado das features do Dart 3 para extração segura de estados.
*   **Gerenciamento de Ciclo de Vida:** Controle estrito de *Streams* e *Listeners* (`IDisposable` pattern) para evitar *Memory Leaks* ao consumir sensores de hardware.

## ⚙️ Integração Nativa (Flutter ↔ Android)

O grande diferencial tecnológico deste app é a descida para o código nativo (Kotlin) para acessar APIs do sistema operacional que o Flutter não alcança nativamente com a mesma granularidade.

1.  **EventChannel (Giroscópio / Acelerômetro):**
    *   Implementação do `SensorEventListener` no Android.
    *   Cálculo de força G com *debounce* nativo para detectar o movimento de chacoalhar o celular (Shake-to-Roll) e enviar eventos contínuos para o Dart.
2.  **MethodChannel (Haptic Feedback & Câmera):**
    *   Acionamento assíncrono do `VibratorManager` (com fallback de segurança para SDKs antigos).
    *   Padrões de forma de onda (Waveform) distintos: Pulsos rápidos para **Acertos Críticos (20)** e vibração densa e contínua para **Falhas Críticas (1)**.
    *   Acionamento do *Flash* da câmera via `CameraManager` para reforço visual no crítico.

## 🚀 Como Executar

**Nota:** Como este projeto consome sensores físicos (acelerômetro, motor de vibração e câmera), **é altamente recomendado rodar em um dispositivo Android físico** conectado via cabo USB com depuração ativada. Emuladores não reproduzirão a experiência sensorial de hardware.

1. Clone o repositório:
   ```bash
   git clone [https://github.com/marivaldojunior/critsense.git](https://github.com/marivaldojunior/critsense.git)