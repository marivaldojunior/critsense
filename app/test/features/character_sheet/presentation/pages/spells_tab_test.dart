import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character_spell.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_character_spell_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_character_spells_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/save_character_spell_usecase.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/spellbook_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_sheet_tabs/spells_tab.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_spell_detail_usecase.dart';

import '../../../../helpers/character_test_helpers.dart';

class _MockGetSpells extends Mock implements GetCharacterSpellsUseCase {}

class _MockSaveSpell extends Mock implements SaveCharacterSpellUseCase {}

class _MockDeleteSpell extends Mock implements DeleteCharacterSpellUseCase {}

class _MockGetSpellDetail extends Mock implements GetSpellDetailUseCase {}

/// Testa a aba Magias: CD e ataque, espaços de magia e grimório por nível.
void main() {
  late _MockGetSpells getSpells;

  setUp(() {
    getSpells = _MockGetSpells();
    sl.registerFactory<SpellbookBloc>(
      () => SpellbookBloc(
        getSpells,
        _MockSaveSpell(),
        _MockDeleteSpell(),
        _MockGetSpellDetail(),
      ),
    );
  });

  tearDown(() => sl.reset());

  Future<CharacterBloc> pumpTab(
    WidgetTester tester,
    Character character,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 860);
    addTearDown(tester.view.reset);

    final (:bloc, saveCharacter: _) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: SpellsTab(character: character),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('mago mostra CD, ataque, espaços e magias por nível', (
    tester,
  ) async {
    when(() => getSpells('c1')).thenAnswer(
      (_) async => const [
        CharacterSpell(
          id: 's1',
          characterId: 'c1',
          spellIndex: 'light',
          name: 'Light',
          level: 0,
        ),
        CharacterSpell(
          id: 's2',
          characterId: 'c1',
          spellIndex: 'shield',
          name: 'Shield',
          level: 1,
          prepared: true,
        ),
      ],
    );

    await pumpTab(
      tester,
      buildTestCharacter(
        characterClass: 'Wizard',
        level: 3,
        attributes: const Attribute(intelligence: 16),
      ),
    );

    expect(find.text('13'), findsOneWidget); // CD: 8 + 2 + 3
    expect(find.text('+5'), findsOneWidget); // ataque: 2 + 3
    expect(find.text('4/4'), findsOneWidget); // 1º nível
    expect(find.text('2/2'), findsOneWidget); // 2º nível
    expect(find.text('Truques'), findsOneWidget);
    expect(find.text('1º nível'), findsWidgets);
    expect(find.text('Preparadas: 1/6'), findsOneWidget); // 3 + 3
    expect(tester.takeException(), isNull);
  });

  testWidgets('gastar um espaço atualiza o contador', (tester) async {
    when(() => getSpells('c1')).thenAnswer((_) async => const []);
    final bloc = await pumpTab(
      tester,
      buildTestCharacter(characterClass: 'Wizard', level: 1),
    );

    await tester.tap(find.byTooltip('Gastar espaço').first);
    await tester.runAsync(
      () => bloc.stream.firstWhere(
        (s) => s.findCharacter('c1')?.availableSpellSlots(1) == 1,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('classe sem magia mostra o aviso e nenhum espaço', (
    tester,
  ) async {
    when(() => getSpells('c1')).thenAnswer((_) async => const []);
    await pumpTab(tester, buildTestCharacter());

    expect(find.textContaining('não conjura magias'), findsOneWidget);
    expect(find.text('Espaços de magia'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
