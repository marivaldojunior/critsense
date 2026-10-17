import CoreMotion
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CritSenseHardwarePlugin") {
      CritSenseHardwarePlugin.register(with: registrar)
    }
  }
}

/// Lado iOS dos canais usados pelo `HardwareBridge` (Dart). Espelha o
/// `MainActivity.kt` do Android:
/// - `feedback` (MethodChannel): feedback háptico de crítico e falha crítica.
/// - `sensor` (EventChannel): emite um evento a cada shake do aparelho.
///
/// Fica neste arquivo (e não num arquivo próprio) para não precisar
/// registrar um arquivo novo no `project.pbxproj` do Xcode.
final class CritSenseHardwarePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let methodChannelName = "com.marivaldojunior.critsense/feedback"
  private static let eventChannelName = "com.marivaldojunior.critsense/sensor"

  /// Mesmos valores do Android: aceleração mínima (em g) para contar como
  /// shake e intervalo mínimo entre dois shakes.
  private static let shakeThresholdG = 2.2
  private static let shakeDebounce: TimeInterval = 1.0

  private let motionManager = CMMotionManager()
  private var eventSink: FlutterEventSink?
  private var lastShake = Date.distantPast

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CritSenseHardwarePlugin()

    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "criticalSuccess":
      UINotificationFeedbackGenerator().notificationOccurred(.success)
      result(nil)
    case "criticalFailure":
      UINotificationFeedbackGenerator().notificationOccurred(.error)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    // Sem acelerômetro (ex: simulador), o stream fica aberto sem eventos.
    guard motionManager.isAccelerometerAvailable else { return nil }

    motionManager.accelerometerUpdateInterval = 1.0 / 50.0
    motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
      guard let self = self, let acceleration = data?.acceleration else { return }

      // No iOS a aceleração já vem em g (incluindo a gravidade), então não
      // há divisão pela gravidade como no Android.
      let gForce = (acceleration.x * acceleration.x
        + acceleration.y * acceleration.y
        + acceleration.z * acceleration.z).squareRoot()
      guard gForce >= CritSenseHardwarePlugin.shakeThresholdG else { return }

      let now = Date()
      guard now.timeIntervalSince(self.lastShake) >= CritSenseHardwarePlugin.shakeDebounce else {
        return
      }
      self.lastShake = now
      self.eventSink?("SHAKE_DETECTED")
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motionManager.stopAccelerometerUpdates()
    eventSink = nil
    return nil
  }
}
