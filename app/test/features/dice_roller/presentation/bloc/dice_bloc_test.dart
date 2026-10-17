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

  group('pool', () {
    test('DiceTypeAdded soma uma unidade do tipo ao pool', () async {
      bloc
        ..add(const DiceTypeAdded(DiceType.d6))
        ..add(const DiceTypeAdded(DiceType.d6))
        ..add(const DiceTypeAdded(DiceType.d20));
      await settle();

      expect(bloc.state.pool, {DiceType.d6: 2, DiceType.d20: 1});
      expect(bloc.state.totalDiceCount, 3);
    });

    test('DiceTypeRemoved tira uma unidade e remove o tipo no zero', () async {
      bloc
        ..add(const DiceTypeAdded(DiceType.d8))
        ..add(const DiceTypeAdded(DiceType.d8))
        ..add(const DiceTypeRemoved(DiceType.d8));
      await settle();
      expect(bloc.state.pool, {DiceType.d8: 1});

      bloc.add(const DiceTypeRemoved(DiceType.d8));
      await settle();
      expect(bloc.state.pool, isEmpty);
    });

    test('DiceTypeRemoved de um tipo fora do pool não muda nada', () async {
      bloc
        ..add(const DiceTypeAdded(DiceType.d4))
        ..add(const DiceTypeRemoved(DiceType.d12));
      await settle();

      expect(bloc.state.pool, {DiceType.d4: 1});
    });

    test('PoolCleared volta ao estado inicial', () async {
      bloc
        ..add(const DiceTypeAdded(DiceType.d20))
        ..add(const ModifierIncremented())
        ..add(const D20ModeChanged(D20RollMode.advantage))
        ..add(const PoolCleared());
      await settle();

      expect(bloc.state.pool, isEmpty);
      expect(bloc.state.modifier, 0);
      expect(bloc.state.d20Mode, D20RollMode.normal);
    });
  });

  group('modificador e modo do d20', () {
    test('o modificador sobe e desce, inclusive abaixo de zero', () async {
      bloc
        ..add(const ModifierIncremented())
        ..add(const ModifierIncremented())
        ..add(const ModifierDecremented());
      await settle();
      expect(bloc.state.modifier, 1);

      bloc
        ..add(const ModifierDecremented())
        ..add(const ModifierDecremented());
      await settle();
      expect(bloc.state.modifier, -1);
    });

    test('D20ModeChanged troca o modo de rolagem do d20', () async {
      bloc.add(const D20ModeChanged(D20RollMode.disadvantage));
      await settle();

      expect(bloc.state.d20Mode, D20RollMode.disadvantage);
    });
  });

  group('rolagem', () {
    test('DiceRollRequested passa por rolling e termina em idle com o '
        'resultado', () async {
      bloc
        ..add(const DiceTypeAdded(DiceType.d20))
        ..add(const ModifierIncremented())
        ..add(const D20ModeChanged(D20RollMode.advantage));
      await settle();

      final statuses = <DiceRollStatus>[];
      final sub = bloc.stream.listen((s) => statuses.add(s.status));
      bloc.add(const DiceRollRequested());
      await bloc.stream.firstWhere((s) => s.lastResult != null);
      await sub.cancel();

      expect(statuses, [DiceRollStatus.rolling, DiceRollStatus.idle]);
      expect(bloc.state.lastResult, fakeResult);
      verify(
        () => rollDice(
          pool: {DiceType.d20: 1},
          modifier: 1,
          d20Mode: D20RollMode.advantage,
        ),
      ).called(1);
    });

    test('a rolagem mantém o pool e o modificador', () async {
      bloc
        ..add(const DiceTypeAdded(DiceType.d10))
        ..add(const ModifierIncremented())
        ..add(const DiceRollRequested());
      await bloc.stream.firstWhere((s) => s.lastResult != null);

      expect(bloc.state.pool, {DiceType.d10: 1});
      expect(bloc.state.modifier, 1);
    });

    test('DiceRollRequested com o pool vazio é ignorado', () async {
      bloc.add(const DiceRollRequested());
      await settle();

      expect(bloc.state.status, DiceRollStatus.idle);
      expect(bloc.state.lastResult, isNull);
    });
  });

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

    test('um shake durante uma rolagem em andamento é ignorado', () async {
      bloc.add(const DiceTypeAdded(DiceType.d20));
      await settle();

      bloc.add(const DiceRollRequested());
      await bloc.stream.firstWhere((s) => s.status == DiceRollStatus.rolling);
      shakeController.add(null);
      await bloc.stream.firstWhere((s) => s.lastResult != null);
      // Folga para uma segunda rolagem indevida aparecer, se existisse.
      await Future<void>.delayed(const Duration(milliseconds: 700));

      verify(
        () => rollDice(
          pool: any(named: 'pool'),
          modifier: any(named: 'modifier'),
          d20Mode: any(named: 'd20Mode'),
        ),
      ).called(1);
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
