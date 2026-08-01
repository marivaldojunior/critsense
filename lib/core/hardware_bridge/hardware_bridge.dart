import 'package:flutter/services.dart';

/// Ponte entre o Dart e os canais nativos (Android/iOS) do CritSense.
///
/// Centraliza **toda** comunicação com o código nativo em um único lugar,
/// seguindo o princípio de responsabilidade única: nenhuma outra classe
/// do projeto deve referenciar [MethodChannel] ou [EventChannel] diretamente.
///
/// Dois mecanismos de comunicação são usados:
/// - [MethodChannel]: chamada **unidirecional** de Dart → Nativo.
///   Equivale a um RPC: dispara um método e aguarda resposta (Future).
/// - [EventChannel]: fluxo **contínuo e bidirecional** de Nativo → Dart.
///   Equivale a um Observable/Stream: o nativo emite eventos que o Dart consome.
class HardwareBridge {
  // Construtor privado: esta classe só expõe membros estáticos.
  // Instanciá-la não faz sentido semântico, então bloqueamos isso.
  HardwareBridge._();

  /// Canal de método para ações únicas de feedback (vibração, LED, etc.).
  ///
  /// O nome do canal deve ser idêntico ao registrado no lado nativo
  /// (MainActivity.kt no Android / AppDelegate.swift no iOS).
  // `static const` porque o canal é um singleton imutável por design;
  // criá-lo uma única vez evita overhead de alocação em cada chamada.
  static const MethodChannel _methodChannel = MethodChannel(
    'com.marivaldojunior.critsense/feedback',
  );

  /// Canal de evento para receber dados contínuos do acelerômetro.
  ///
  /// No nativo, o lado `StreamHandler` produz eventos; aqui recebemos como [Stream].
  static const EventChannel _eventChannel = EventChannel(
    'com.marivaldojunior.critsense/sensor',
  );

  // ─── MethodChannel: chamadas únicas (Future) ───────────────────────────────
  //
  // `invokeMethod` retorna `Future<T>`: a chamada é assíncrona porque o Dart
  // precisa atravessar a "plataform message bridge" (uma fila de mensagens
  // entre isolates) até o thread nativo e aguardar a resposta.
  // `async/await` é apenas açúcar sintático sobre Futures — equivale ao
  // `async/await` do C# ou ao `.then()` das Promises do JavaScript.

  /// Aciona o feedback sensorial de **acerto crítico** no hardware.
  ///
  /// Dispara um padrão de vibração comemorativo e/ou efeito de luz
  /// configurado no código nativo ao receber o método `criticalSuccess`.
  ///
  /// O bloco `try-catch` com [PlatformException] é obrigatório aqui porque:
  /// 1. O canal pode não estar registrado no nativo (ex: build de teste).
  /// 2. O hardware pode não suportar vibração (emuladores, tablets antigos).
  /// 3. Permissões podem ter sido negadas pelo sistema operacional.
  /// Em todos esses casos, o app deve **continuar funcionando** — o feedback
  /// é uma melhoria de experiência, não uma funcionalidade crítica.
  static Future<void> triggerCriticalSuccess() async {
    try {
      await _methodChannel.invokeMethod<void>('criticalSuccess');
    } on PlatformException catch (e) {
      // Falha silenciosa: o feedback é acessório; não deve interromper o jogo.
      // Em produção, substitua por um logger centralizado (ex: Firebase Crashlytics).
      // ignore: avoid_print
      print('[HardwareBridge] criticalSuccess falhou: ${e.message}');
    }
  }

  /// Aciona o feedback sensorial de **falha crítica** no hardware.
  ///
  /// Dispara um padrão de vibração de alerta configurado no código nativo
  /// ao receber o método `criticalFailure`.
  ///
  /// Segue a mesma estratégia de resiliência de [triggerCriticalSuccess]:
  /// captura [PlatformException] e trata a falha como não-fatal.
  static Future<void> triggerCriticalFailure() async {
    try {
      await _methodChannel.invokeMethod<void>('criticalFailure');
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[HardwareBridge] criticalFailure falhou: ${e.message}');
    }
  }

  // ─── EventChannel: fluxo contínuo (Stream) ────────────────────────────────
  //
  // `EventChannel.receiveBroadcastStream()` retorna um `Stream<dynamic>`.
  // Um `Stream` em Dart é equivalente ao `IObservable<T>` do C# (Rx) ou ao
  // `Observable` do RxJS: representa uma sequência assíncrona de eventos ao
  // longo do tempo. O nativo "pusha" dados; o Dart reage via `listen()` ou
  // operadores como `map`, `where`, `asyncMap`.
  //
  // `receiveBroadcastStream` cria um *broadcast stream* (vs. *single-subscription*),
  // permitindo múltiplos `listen()` simultâneos — necessário quando mais de
  // um widget reage ao shake ao mesmo tempo.

  /// Stream que emite um evento a cada movimento de shake detectado pelo sensor.
  ///
  /// O getter recria o stream a cada acesso para garantir que o `StreamHandler`
  /// nativo seja registrado/desregistrado corretamente durante o ciclo de vida.
  ///
  /// O [PlatformException] lançado pelo nativo é propagado automaticamente
  /// como erro no stream; o consumidor deve tratar via `.handleError()` ou
  /// `try-catch` dentro de um `await for`.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// HardwareBridge.onShakeDetected.listen((_) {
  ///   // reagir ao shake
  /// });
  /// ```
  static Stream<void> get onShakeDetected {
    return _eventChannel.receiveBroadcastStream()
    // Descarta o payload (o nativo só precisa sinalizar o evento, sem dados).
    .map<void>((_) => null);
  }
}
