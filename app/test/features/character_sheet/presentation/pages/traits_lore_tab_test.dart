import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_sheet_tabs/traits_lore_tab.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Editar os textos da aba não pode desfazer o que mudou em outra aba.
void main() {
  testWidgets('editar um traço depois de um dano mantém o PV novo', (
    tester,
  ) async {
    final character = buildTestCharacter(currentHitPoints: 30);
    final (:bloc, saveCharacter: _) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: TraitsLoreTab(character: character),
          ),
        ),
      ),
    );

    // Dano dado em outra aba depois que esta abriu.
    bloc.add(const ApplyDamageEvent('c1', 10));
    await tester.runAsync(
      () => bloc.stream
          .firstWhere((s) => s.findCharacter('c1')?.currentHitPoints == 20)
          .timeout(const Duration(seconds: 5)),
    );

    await tester.enterText(find.byType(TextField).first, 'Teimoso');
    // Passa o debounce de 500ms da aba.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(
      () => bloc.stream
          .firstWhere(
            (s) => s.findCharacter('c1')?.personalityTraits == 'Teimoso',
          )
          .timeout(const Duration(seconds: 5)),
    );

    final saved = bloc.state.findCharacter('c1')!;
    expect(saved.personalityTraits, 'Teimoso');
    expect(saved.currentHitPoints, 20);
  });
}
