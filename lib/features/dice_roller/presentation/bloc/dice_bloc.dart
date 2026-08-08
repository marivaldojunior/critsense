import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';
import 'package:crit_sense/features/dice_roller/domain/usecases/roll_dice_usecase.dart';

part 'dice_event.dart';
part 'dice_state.dart';

/// BLoC responsável pelo pool de dados, modificador e ciclo de vida da rolagem.
class DiceBloc extends Bloc<DiceEvent, DiceState> {
  final RollDiceUseCase _rollDiceUseCase;

  DiceBloc(this._rollDiceUseCase) : super(const DiceState()) {
    on<DiceTypeAdded>(_onDiceTypeAdded);
    on<DiceTypeRemoved>(_onDiceTypeRemoved);
    on<ModifierIncremented>(_onModifierIncremented);
    on<ModifierDecremented>(_onModifierDecremented);
    on<PoolCleared>(_onPoolCleared);
    on<D20ModeChanged>(_onD20ModeChanged);
    on<DiceRollRequested>(_onDiceRollRequested);
    on<DiceShakeDetected>(_onDiceShakeDetected);
  }

  void _onDiceTypeAdded(DiceTypeAdded event, Emitter<DiceState> emit) {
    final updatedPool = Map<DiceType, int>.of(state.pool);
    updatedPool[event.type] = (updatedPool[event.type] ?? 0) + 1;
    emit(state.copyWith(pool: updatedPool));
  }

  void _onDiceTypeRemoved(DiceTypeRemoved event, Emitter<DiceState> emit) {
    final currentCount = state.pool[event.type];
    if (currentCount == null) return;

    final updatedPool = Map<DiceType, int>.of(state.pool);
    if (currentCount <= 1) {
      updatedPool.remove(event.type);
    } else {
      updatedPool[event.type] = currentCount - 1;
    }
    emit(state.copyWith(pool: updatedPool));
  }

  void _onModifierIncremented(
    ModifierIncremented event,
    Emitter<DiceState> emit,
  ) {
    emit(state.copyWith(modifier: state.modifier + 1));
  }

  void _onModifierDecremented(
    ModifierDecremented event,
    Emitter<DiceState> emit,
  ) {
    emit(state.copyWith(modifier: state.modifier - 1));
  }

  void _onPoolCleared(PoolCleared event, Emitter<DiceState> emit) {
    emit(const DiceState());
  }

  void _onD20ModeChanged(D20ModeChanged event, Emitter<DiceState> emit) {
    emit(state.copyWith(d20Mode: event.mode));
  }

  /// Rola o pool atual, mantendo pool e modificador intactos após o
  /// resultado — o usuário pode repetir a mesma rolagem sem remontá-la.
  Future<void> _onDiceRollRequested(
    DiceRollRequested event,
    Emitter<DiceState> emit,
  ) async {
    if (state.totalDiceCount == 0) return;

    emit(state.copyWith(status: DiceRollStatus.rolling));

    // Delay intencional para a UI exibir a animação de rolagem antes do
    // resultado ser revelado.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final result = _rollDiceUseCase(
      pool: state.pool,
      modifier: state.modifier,
      d20Mode: state.d20Mode,
    );
    emit(state.copyWith(status: DiceRollStatus.idle, lastResult: result));
  }

  void _onDiceShakeDetected(DiceShakeDetected event, Emitter<DiceState> emit) {
    // Ignora o shake se o pool estiver vazio: não há o que rolar.
    if (state.totalDiceCount == 0) return;
    add(const DiceRollRequested());
  }
}
