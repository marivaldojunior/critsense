import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/compendium/domain/entities/spell_summary.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_spells_usecase.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/compendium_bloc.dart';

class _MockGetSpellsUseCase extends Mock implements GetSpellsUseCase {}

/// Testa a listagem de Magias no [CompendiumBloc]: carga, debounce da busca,
/// filtros rápidos e descarte de respostas obsoletas.
void main() {
  late _MockGetSpellsUseCase getSpells;
  late CompendiumBloc bloc;

  SpellSummary spell(String name) => SpellSummary(
    index: name.toLowerCase(),
    name: name,
    url: '/api/spells/${name.toLowerCase()}',
  );

  final fireball = spell('Fireball');
  final shield = spell('Shield');

  /// Espera mais que o debounce de 500ms da busca.
  Future<void> waitDebounce() =>
      Future<void>.delayed(const Duration(milliseconds: 650));

  void stubSpells(List<SpellSummary> result) {
    when(
      () => getSpells(
        name: any(named: 'name'),
        level: any(named: 'level'),
        school: any(named: 'school'),
      ),
    ).thenAnswer((_) async => result);
  }

  setUp(() {
    getSpells = _MockGetSpellsUseCase();
    bloc = CompendiumBloc(getSpells);
  });

  tearDown(() => bloc.close());

  test('LoadSpellsEvent carrega a lista sem filtros', () async {
    stubSpells([fireball, shield]);

    bloc.add(const LoadSpellsEvent());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == CompendiumStatus.success,
    );

    expect(state.spells, [fireball, shield]);
    verify(() => getSpells(name: null, level: null, school: null)).called(1);
  });

  test('falha na carga emite o status failure', () async {
    when(
      () => getSpells(
        name: any(named: 'name'),
        level: any(named: 'level'),
        school: any(named: 'school'),
      ),
    ).thenThrow(Exception('rede'));

    bloc.add(const LoadSpellsEvent());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == CompendiumStatus.failure,
    );

    expect(state.errorMessage, isNotNull);
  });

  test('a busca espera o debounce e usa só o último texto', () async {
    stubSpells([fireball]);

    bloc
      ..add(const SearchQueryChanged('f'))
      ..add(const SearchQueryChanged('fi'))
      ..add(const SearchQueryChanged('fire'));
    await waitDebounce();

    verify(() => getSpells(name: 'fire', level: null, school: null)).called(1);
    verifyNoMoreInteractions(getSpells);
    expect(bloc.state.searchQuery, 'fire');
  });

  test('texto de busca vazio não envia o filtro de nome', () async {
    stubSpells([fireball, shield]);

    bloc.add(const SearchQueryChanged(''));
    await waitDebounce();

    verify(() => getSpells(name: null, level: null, school: null)).called(1);
  });

  test('FilterToggled aplica o filtro e, de novo, remove o filtro', () async {
    stubSpells([shield]);

    bloc.add(const FilterToggled('level', 1));
    await bloc.stream.firstWhere((s) => s.status == CompendiumStatus.success);
    expect(bloc.state.activeFilters, {'level': 1});
    verify(() => getSpells(name: null, level: 1, school: null)).called(1);

    bloc.add(const FilterToggled('level', 1));
    await bloc.stream.firstWhere(
      (s) => s.status == CompendiumStatus.success && s.activeFilters.isEmpty,
    );
    verify(() => getSpells(name: null, level: null, school: null)).called(1);
  });

  test('a busca mantém o filtro ativo', () async {
    stubSpells([fireball]);

    bloc.add(const FilterToggled('level', 3));
    await bloc.stream.firstWhere((s) => s.status == CompendiumStatus.success);
    bloc.add(const SearchQueryChanged('fire'));
    await waitDebounce();

    verify(() => getSpells(name: 'fire', level: 3, school: null)).called(1);
  });

  test('uma resposta antiga não sobrescreve a mais recente', () async {
    final slow = Completer<List<SpellSummary>>();
    when(
      () => getSpells(name: null, level: null, school: null),
    ).thenAnswer((_) => slow.future);
    when(
      () => getSpells(name: null, level: 1, school: null),
    ).thenAnswer((_) async => [shield]);

    bloc.add(const LoadSpellsEvent());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const FilterToggled('level', 1));
    await bloc.stream.firstWhere((s) => s.status == CompendiumStatus.success);

    slow.complete([fireball, shield]);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.spells, [shield]);
  });
}
