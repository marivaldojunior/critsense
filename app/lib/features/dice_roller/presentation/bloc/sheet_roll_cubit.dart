import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/d20_roll_mode.dart';
import '../../domain/entities/dice_notation.dart';
import '../../domain/entities/dice_result.dart';
import '../../domain/entities/dice_type.dart';
import '../../domain/usecases/roll_dice_usecase.dart';

/// Estado da rolagem feita a partir da ficha.
class SheetRollState extends Equatable {
  final D20RollMode mode;

  /// Última rolagem de d20 (teste, salvaguarda, iniciativa ou ataque).
  final DiceRollResult? d20Result;

  /// Última rolagem de dano.
  final DiceRollResult? damageResult;

  const SheetRollState({
    this.mode = D20RollMode.normal,
    this.d20Result,
    this.damageResult,
  });

  @override
  List<Object?> get props => [mode, d20Result, damageResult];
}

/// Rola o d20 (com vantagem ou desvantagem) e o dano para a ficha, usando o
/// mesmo [RollDiceUseCase] do rolador — a vibração nos críticos também vale
/// aqui.
class SheetRollCubit extends Cubit<SheetRollState> {
  SheetRollCubit(this._rollDice, {D20RollMode initialMode = D20RollMode.normal})
    : super(SheetRollState(mode: initialMode));

  final RollDiceUseCase _rollDice;

  void setMode(D20RollMode mode) => emit(
    SheetRollState(
      mode: mode,
      d20Result: state.d20Result,
      damageResult: state.damageResult,
    ),
  );

  /// Rola 1d20 + [modifier] no modo atual. Zera o dano anterior.
  void rollD20(int modifier) {
    final result = _rollDice(
      pool: const {DiceType.d20: 1},
      modifier: modifier,
      d20Mode: state.mode,
    );
    emit(SheetRollState(mode: state.mode, d20Result: result));
  }

  /// Rola o dano [notation] (ex: `1d8+3`). Com [critical], os dados dobram
  /// (regra do SRD: o modificador não dobra). Um valor fixo (ex: `1`) vira
  /// um resultado sem dados.
  void rollDamage(String notation, {bool critical = false}) {
    final parsed = DiceNotation.tryParse(notation);
    if (parsed == null) return;
    final pool = {
      for (final entry in parsed.pool.entries)
        entry.key: critical ? entry.value * 2 : entry.value,
    };
    final result = pool.isEmpty
        ? DiceRollResult(rolls: const [], modifier: parsed.modifier)
        : _rollDice(pool: pool, modifier: parsed.modifier);
    emit(
      SheetRollState(
        mode: state.mode,
        d20Result: state.d20Result,
        damageResult: result,
      ),
    );
  }
}
