import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/character_spell.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_character_spell_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_character_spells_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/save_character_spell_usecase.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/spellbook_bloc.dart';
import 'package:crit_sense/features/compendium/domain/entities/spell_detail.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_spell_detail_usecase.dart';

class _MockGetSpells extends Mock implements GetCharacterSpellsUseCase {}

class _MockSaveSpell extends Mock implements SaveCharacterSpellUseCase {}

class _MockDeleteSpell extends Mock implements DeleteCharacterSpellUseCase {}

class _MockGetSpellDetail extends Mock implements GetSpellDetailUseCase {}

/// Testa o grimório: carga, preparo, remoção e busca do nível das magias
/// migradas sem nível.
void main() {
  late _MockGetSpells getSpells;
  late _MockSaveSpell saveSpell;
  late _MockDeleteSpell deleteSpell;
  late _MockGetSpellDetail getDetail;
  late SpellbookBloc bloc;

  CharacterSpell spell(String index, int? level, {bool prepared = false}) =>
      CharacterSpell(
        id: 'id-$index',
        characterId: 'c1',
        spellIndex: index,
        name: index,
        level: level,
        prepared: prepared,
      );

  SpellDetail detail(String index, int level) => SpellDetail(
    index: index,
    name: index,
    desc: const [],
    range: '',
    components: const [],
    duration: '',
    castingTime: '',
    level: level,
  );

  setUpAll(() => registerFallbackValue(spell('fallback', 0)));

  setUp(() {
    getSpells = _MockGetSpells();
    saveSpell = _MockSaveSpell();
    deleteSpell = _MockDeleteSpell();
    getDetail = _MockGetSpellDetail();
    when(() => saveSpell(any())).thenAnswer((_) async {});
    when(() => deleteSpell(any())).thenAnswer((_) async {});
    bloc = SpellbookBloc(getSpells, saveSpell, deleteSpell, getDetail);
  });

  tearDown(() => bloc.close());

  test('carrega o grimório do personagem', () async {
    when(() => getSpells('c1')).thenAnswer((_) async => [spell('light', 0)]);

    bloc.add(const LoadSpellbookEvent('c1'));
    final state = await bloc.stream.firstWhere(
      (s) => s.status == SpellbookStatus.success,
    );

    expect(state.spells.single.spellIndex, 'light');
    verifyNever(() => getDetail(any()));
  });

  test('busca no compêndio o nível das magias sem nível', () async {
    var calls = 0;
    when(() => getSpells('c1')).thenAnswer(
      (_) async => calls++ == 0
          ? [spell('magic-missile', null)]
          : [spell('magic-missile', 1)],
    );
    when(
      () => getDetail('magic-missile'),
    ).thenAnswer((_) async => detail('magic-missile', 1));

    bloc.add(const LoadSpellbookEvent('c1'));
    await bloc.stream.firstWhere((s) => s.spells.firstOrNull?.level == 1);

    final saved =
        verify(() => saveSpell(captureAny())).captured.single as CharacterSpell;
    expect(saved.level, 1);
  });

  test('sem internet a magia continua sem nível, sem erro', () async {
    when(
      () => getSpells('c1'),
    ).thenAnswer((_) async => [spell('magic-missile', null)]);
    when(() => getDetail(any())).thenThrow(Exception('sem rede'));

    bloc.add(const LoadSpellbookEvent('c1'));
    await bloc.stream.firstWhere((s) => s.status == SpellbookStatus.success);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.errorMessage, isNull);
    expect(bloc.state.spells.single.level, isNull);
  });

  test('marcar como preparada salva e recarrega', () async {
    when(() => getSpells('c1')).thenAnswer((_) async => [spell('shield', 1)]);
    bloc.add(const LoadSpellbookEvent('c1'));
    await bloc.stream.firstWhere((s) => s.status == SpellbookStatus.success);

    bloc.add(TogglePreparedEvent(spell('shield', 1)));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final saved =
        verify(() => saveSpell(captureAny())).captured.single as CharacterSpell;
    expect(saved.prepared, isTrue);
  });

  test('preparedCount não conta truques', () {
    final state = SpellbookState(
      spells: [
        spell('light', 0, prepared: true),
        spell('shield', 1, prepared: true),
        spell('sleep', 1),
      ],
    );

    expect(state.preparedCount, 1);
  });
}
