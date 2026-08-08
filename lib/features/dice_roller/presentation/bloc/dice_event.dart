part of 'dice_bloc.dart';

sealed class DiceEvent {
  const DiceEvent();
}

/// Adiciona uma unidade de [type] ao pool.
final class DiceTypeAdded extends DiceEvent {
  final DiceType type;
  const DiceTypeAdded(this.type);
}

/// Remove uma unidade de [type] do pool (sem efeito se já estiver em zero).
final class DiceTypeRemoved extends DiceEvent {
  final DiceType type;
  const DiceTypeRemoved(this.type);
}

final class ModifierIncremented extends DiceEvent {
  const ModifierIncremented();
}

final class ModifierDecremented extends DiceEvent {
  const ModifierDecremented();
}

/// Reseta pool, modificador e último resultado.
final class PoolCleared extends DiceEvent {
  const PoolCleared();
}

/// Altera o modo de rolagem aplicado aos d20 do pool (normal/vantagem/desvantagem).
final class D20ModeChanged extends DiceEvent {
  final D20RollMode mode;
  const D20ModeChanged(this.mode);
}

/// Solicita a rolagem do pool atual.
final class DiceRollRequested extends DiceEvent {
  const DiceRollRequested();
}

/// Disparado quando o sensor nativo detecta um shake do dispositivo.
final class DiceShakeDetected extends DiceEvent {
  const DiceShakeDetected();
}
