import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/widgets/edit_identity_sheet.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa a edição dos dados básicos do personagem.
void main() {
  Future<CharacterBloc> pumpSheet(WidgetTester tester) async {
    final character = buildTestCharacter().copyWith(alignment: 'Leal e Bom');
    final (:bloc, saveCharacter: _) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: EditIdentitySheet(
              character: character,
              pickAvatar: (_) async => File('/fotos/nova.png'),
            ),
          ),
        ),
      ),
    );
    return bloc;
  }

  Future<CharacterState> waitFor(
    WidgetTester tester,
    CharacterBloc bloc,
    bool Function(CharacterState) test,
  ) async {
    final state = await tester.runAsync(
      () => bloc.stream.firstWhere(test).timeout(const Duration(seconds: 5)),
    );
    await tester.pumpAndSettle();
    return state!;
  }

  testWidgets('salva nome, classe e foto sem mudar o resto da ficha', (
    tester,
  ) async {
    final bloc = await pumpSheet(tester);

    await tester.enterText(find.byType(TextFormField), '  Thorin II ');
    await tester.tap(find.text('Fighter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paladin').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('não muda os atributos'), findsOneWidget);

    await tester.tap(find.text('Galeria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));

    final state = await waitFor(
      tester,
      bloc,
      (s) => s.findCharacter('c1')!.name == 'Thorin II',
    );
    final saved = state.findCharacter('c1')!;
    expect(saved.characterClass, 'Paladin');
    expect(saved.race, 'Dwarf');
    expect(saved.alignment, 'Leal e Bom');
    expect(saved.avatarPath, '/fotos/nova.png');
    expect(saved.maxHitPoints, 30);
    expect(saved.level, 4);
  });

  testWidgets('não salva sem nome', (tester) async {
    final bloc = await pumpSheet(tester);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o nome.'), findsOneWidget);
    expect(bloc.state.findCharacter('c1')!.name, 'Thorin');
  });

  test('nome em inglês a partir do índice da API', () {
    expect(titleFromApiIndex('half-elf'), 'Half-Elf');
  });
}
