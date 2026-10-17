import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';
import 'package:crit_sense/features/dice_roller/domain/usecases/roll_dice_usecase.dart';
import 'package:crit_sense/features/dice_roller/domain/usecases/watch_shake_usecase.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_bloc.dart';

class _MockRollDiceUseCase extends Mock implements RollDiceUseCase {}

class _MockWatchShakeUseCase extends Mock implements WatchShakeUseCase {}

/// Testa o [DiceBloc]: montagem do pool, modificador, modo do d20 e o
/// disparo da rolagem pelo botão ou pelo shake.
void main() {
  late _MockRollDiceUseCase rollDice;
  late _MockWatchShakeUseCase watchShake;
  late StreamController<void> shakeController;
  late DiceBloc bloc;

  final fakeResult = DiceRollResult(
    rolls: const [SingleDieResult(type: DiceType.d20, value: 12)],
    modifier: 0,
  );

  setUpAll(() => registerFallbackValue(D20RollMode.normal));

  setUp(() {
    rollDice = _MockRollDiceUseCase();
    watchShake = _MockWatchShakeUseCase();
    shakeController = StreamController<void>.broadcast();
    when(() => watchShake()).thenAnswer((_) => shakeController.stream);
    when(
      () => rollDice(
        pool: any(named: 'pool'),
        modifier: any(named: 'modifier'),
        d20Mode: any(named: 'd20Mode'),
      ),
    ).thenReturn(fakeResult);
    bloc = DiceBloc(rollDice, watchShake);
  });

  tearDown(() async {
    await bloc.close();
    await shakeController.close();
  });

  /// Espera o bloc processar os eventos já enfileirados.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('shake', () {
    test('um shake com dados no pool dispara a rolagem', () async {
      bloc.add(const DiceTypeAdded(DiceType.d20));
      await settle();

      shakeController.add(null);
      final state = await bloc.stream.firstWhere((s) => s.lastResult != null);

      expect(state.lastResult, fakeResult);
      expect(state.status, DiceRollStatus.idle);
    });

    test('um shake com o pool vazio é ignorado', () async {
      shakeController.add(null);
      await settle();

      expect(bloc.state.status, DiceRollStatus.idle);
      verifyNever(
        () => rollDice(
          pool: any(named: 'pool'),
          modifier: any(named: 'modifier'),
          d20Mode: any(named: 'd20Mode'),
        ),
      );
    });

    test('um erro no stream do sensor não quebra o bloc', () async {
      shakeController.addError(Exception('canal ausente'));
      bloc.add(const DiceTypeAdded(DiceType.d6));
      await settle();

      expect(bloc.state.pool, {DiceType.d6: 1});
    });

    test('close cancela a escuta do sensor', () async {
      await bloc.close();

      expect(shakeController.hasListener, isFalse);
    });
  });
}
