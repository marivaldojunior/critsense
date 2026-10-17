import 'package:crit_sense/core/hardware_bridge/hardware_bridge.dart';

/// Contrato da fonte de dados de sensores e feedback de hardware.
///
/// Segue o mesmo princípio de inversão de dependência da camada de domínio:
/// a camada `data` declara **o que precisa** do hardware, mas não como
/// o hardware está implementado. Isso permite substituir [SensorDataSourceImpl]
/// por um stub/mock nos testes sem tocar em nenhum código nativo.
///
/// Todos os métodos retornam [Future] porque as operações de hardware
/// são assíncronas por natureza — cruzam a platform bridge e aguardam
/// confirmação do thread nativo.
abstract interface class ISensorDataSource {
  /// Aciona o feedback sensorial de acerto crítico no hardware do dispositivo.
  ///
  /// Retorna [Future<void>] porque o chamador precisa saber quando a operação
  /// terminou (ou falhou), mas não há valor de retorno significativo.
  Future<void> triggerCriticalSuccess();

  /// Aciona o feedback sensorial de falha crítica no hardware do dispositivo.
  Future<void> triggerCriticalFailure();

  /// Stream de eventos de shake detectados pelo acelerômetro nativo.
  ///
  /// Exposto como getter para que consumidores possam fazer `listen()` ou
  /// usar `await for` em um loop assíncrono, reagindo a cada agitação do
  /// dispositivo sem precisar fazer polling.
  Stream<void> get onShakeDetected;
}

/// Implementação concreta de [ISensorDataSource] que delega ao [HardwareBridge].
///
/// Esta classe é um **Adapter** (padrão GoF): traduz a interface do domínio
/// de dados para as chamadas estáticas do [HardwareBridge], isolando o
/// restante do sistema dos detalhes dos [MethodChannel]/[EventChannel].
///
/// Por não conter estado próprio, pode ser registrada como **singleton**
/// no sistema de injeção de dependências (ex: `get_it`, `riverpod`).
class SensorDataSourceImpl implements ISensorDataSource {
  /// Construtor `const` permite que a instância seja criada em tempo de
  /// compilação quando usada em constantes, reduzindo alocações em runtime.
  const SensorDataSourceImpl();

  /// Delega diretamente ao [HardwareBridge.triggerCriticalSuccess].
  ///
  /// O `async/await` não é necessário aqui porque apenas repassamos o
  /// [Future] retornado pelo [HardwareBridge] — não há código a executar
  /// após a chamada nativa. Retornar o Future diretamente é mais eficiente
  /// (evita criar um wrapper de state machine desnecessário).
  @override
  Future<void> triggerCriticalSuccess() =>
      HardwareBridge.triggerCriticalSuccess();

  /// Delega diretamente ao [HardwareBridge.triggerCriticalFailure].
  @override
  Future<void> triggerCriticalFailure() =>
      HardwareBridge.triggerCriticalFailure();

  /// Delega diretamente ao getter [HardwareBridge.onShakeDetected].
  ///
  /// O stream é recriado a cada acesso ao getter, conforme a política do
  /// [HardwareBridge] — garantindo que o StreamHandler nativo seja
  /// registrado/cancelado corretamente.
  @override
  Stream<void> get onShakeDetected => HardwareBridge.onShakeDetected;
}
