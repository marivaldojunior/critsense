import '../repositories/i_dice_repository.dart';

/// Caso de uso que expõe os shakes do dispositivo detectados pelo sensor,
/// usados para disparar uma rolagem sem tocar na tela.
class WatchShakeUseCase {
  final IDiceRepository _repository;

  const WatchShakeUseCase(this._repository);

  /// Stream que emite um evento a cada shake detectado.
  Stream<void> call() => _repository.shakeEvents;
}
