import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa os recursos de classe no [CharacterBloc].
void main() {
  Future<CharacterState> next(
    CharacterBloc bloc,
    bool Function(CharacterState) test,
  ) => bloc.stream.firstWhere(test).timeout(const Duration(seconds: 5));

  test(
    'o Descanso Curto devolve o Surto de Ação e mantém o Indomável',
    () async {
      final fighter = buildTestCharacter(
        level: 9,
      ).copyWith(resourcesUsed: const {'action-surge': 1, 'indomitable': 1});
      final (:bloc, :saveCharacter) = await loadedCharacterBloc([fighter]);
      addTearDown(bloc.close);

      bloc.add(const TakeShortRestEvent('c1'));
      final state = await next(
        bloc,
        (s) => s.findCharacter('c1')!.resourcesUsed.length == 1,
      );

      expect(state.findCharacter('c1')!.resourcesUsed, {'indomitable': 1});
    },
  );

  test('gastar, devolver e definir usos', () async {
    final (:bloc, :saveCharacter) = await loadedCharacterBloc([
      buildTestCharacter(characterClass: 'Paladin', level: 2),
    ]);
    addTearDown(bloc.close);

    bloc.add(const UseClassResourceEvent('c1', 'divine-sense'));
    var state = await next(
      bloc,
      (s) => s.findCharacter('c1')!.resourcesUsed.isNotEmpty,
    );
    expect(state.findCharacter('c1')!.resourcesUsed, {'divine-sense': 1});

    bloc.add(const RestoreClassResourceEvent('c1', 'divine-sense'));
    state = await next(
      bloc,
      (s) => s.findCharacter('c1')!.resourcesUsed.isEmpty,
    );

    bloc.add(const SetClassResourceRemainingEvent('c1', 'lay-on-hands', 4));
    state = await next(
      bloc,
      (s) => s.findCharacter('c1')!.resourcesUsed.isNotEmpty,
    );
    expect(state.findCharacter('c1')!.resourcesUsed, {'lay-on-hands': 6});
  });
}
