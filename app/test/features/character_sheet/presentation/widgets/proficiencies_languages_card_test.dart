import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/widgets/proficiencies_languages_card.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa a edição das proficiências e dos idiomas.
void main() {
  Future<CharacterBloc> pumpCard(WidgetTester tester) async {
    final character = buildTestCharacter();
    final (:bloc, saveCharacter: _) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: BlocBuilder<CharacterBloc, CharacterState>(
              builder: (context, state) => ProficienciesLanguagesCard(
                character: state.findCharacter('c1') ?? character,
              ),
            ),
          ),
        ),
      ),
    );
    return bloc;
  }

  Future<void> waitFor(
    WidgetTester tester,
    CharacterBloc bloc,
    bool Function(CharacterState) test,
  ) async {
    await tester.runAsync(
      () => bloc.stream.firstWhere(test).timeout(const Duration(seconds: 5)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('preencher pela classe e raça (Guerreiro anão)', (tester) async {
    final bloc = await pumpCard(tester);

    await tester.tap(find.text('Preencher pela classe e raça'));
    await waitFor(
      tester,
      bloc,
      (s) => s.findCharacter('c1')!.languages.isNotEmpty,
    );

    expect(find.text('Armaduras pesadas'), findsOneWidget);
    expect(find.text('Armas marciais'), findsOneWidget);
    expect(find.text('Anão'), findsOneWidget);
    expect(find.text('Comum'), findsOneWidget);
  });

  testWidgets('adicionar e remover um idioma', (tester) async {
    final bloc = await pumpCard(tester);

    await tester.tap(find.byTooltip('Adicionar idioma'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Élfico');
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await waitFor(
      tester,
      bloc,
      (s) => s.findCharacter('c1')!.languages.contains('Élfico'),
    );
    expect(find.text('Élfico'), findsOneWidget);

    tester.widget<InputChip>(find.byType(InputChip)).onDeleted!();
    await waitFor(
      tester,
      bloc,
      (s) => s.findCharacter('c1')!.languages.isEmpty,
    );
    expect(find.text('Élfico'), findsNothing);
  });
}
