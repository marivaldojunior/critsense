import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/compendium/domain/entities/monster_summary.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_monsters_usecase.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/monster_bloc.dart';

class _MockGetMonstersUseCase extends Mock implements GetMonstersUseCase {}

/// Testa o scroll infinito do Bestiário no [MonsterBloc]: paginação, fim da
/// lista, busca com debounce e filtro de CR.
void main() {
  late _MockGetMonstersUseCase getMonsters;
  late MonsterBloc bloc;

  List<MonsterSummary> page(int start, int count) => [
    for (var i = start; i < start + count; i++)
      MonsterSummary(
        index: 'm$i',
        name: 'Monstro $i',
        url: '/api/monsters/m$i',
      ),
  ];

  /// Espera mais que o debounce de 500ms da busca.
  Future<void> waitDebounce() =>
      Future<void>.delayed(const Duration(milliseconds: 650));

  Future<MonsterState> nextSuccess() =>
      bloc.stream.firstWhere((s) => s.status == MonsterStatus.success);

  setUp(() {
    getMonsters = _MockGetMonstersUseCase();
    bloc = MonsterBloc(getMonsters);
  });

  tearDown(() => bloc.close());

  test('FetchMonstersEvent carrega páginas de 20 e acumula a lista', () async {
    when(
      () =>
          getMonsters(offset: 0, limit: 20, name: null, challengeRating: null),
    ).thenAnswer((_) async => page(0, 20));
    when(
      () =>
          getMonsters(offset: 20, limit: 20, name: null, challengeRating: null),
    ).thenAnswer((_) async => page(20, 20));

    bloc.add(const FetchMonstersEvent());
    await nextSuccess();
    bloc.add(const FetchMonstersEvent());
    final state = await bloc.stream.firstWhere((s) => s.monsters.length == 40);

    expect(state.monsters.first.index, 'm0');
    expect(state.monsters.last.index, 'm39');
    expect(state.hasReachedMax, isFalse);
  });

  test('uma página vazia marca o fim da lista e para de buscar', () async {
    when(
      () =>
          getMonsters(offset: 0, limit: 20, name: null, challengeRating: null),
    ).thenAnswer((_) async => page(0, 5));
    when(
      () =>
          getMonsters(offset: 5, limit: 20, name: null, challengeRating: null),
    ).thenAnswer((_) async => []);

    bloc.add(const FetchMonstersEvent());
    await nextSuccess();
    bloc.add(const FetchMonstersEvent());
    await bloc.stream.firstWhere((s) => s.hasReachedMax);

    bloc.add(const FetchMonstersEvent());
    await Future<void>.delayed(Duration.zero);

    verify(
      () => getMonsters(
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
        name: any(named: 'name'),
        challengeRating: any(named: 'challengeRating'),
      ),
    ).called(2);
    expect(bloc.state.monsters.length, 5);
  });

  test('a primeira página vazia termina em success, não em loading', () async {
    when(
      () =>
          getMonsters(offset: 0, limit: 20, name: null, challengeRating: null),
    ).thenAnswer((_) async => []);

    bloc.add(const FetchMonstersEvent());
    final state = await nextSuccess();

    expect(state.monsters, isEmpty);
    expect(state.hasReachedMax, isTrue);
  });

  test('a busca espera o debounce e recomeça do offset 0', () async {
    when(
      () =>
          getMonsters(offset: 0, limit: 20, name: null, challengeRating: null),
    ).thenAnswer((_) async => page(0, 20));
    when(
      () => getMonsters(
        offset: 0,
        limit: 20,
        name: 'drag',
        challengeRating: null,
      ),
    ).thenAnswer((_) async => page(100, 3));

    bloc.add(const FetchMonstersEvent());
    await nextSuccess();

    bloc
      ..add(const SearchQueryChanged('d'))
      ..add(const SearchQueryChanged('drag'));
    await waitDebounce();

    verify(
      () => getMonsters(
        offset: 0,
        limit: 20,
        name: 'drag',
        challengeRating: null,
      ),
    ).called(1);
    verifyNever(
      () => getMonsters(offset: 0, limit: 20, name: 'd', challengeRating: null),
    );
    expect(bloc.state.monsters.map((m) => m.index), ['m100', 'm101', 'm102']);
  });

  test('a próxima página usa a busca e o filtro ativos', () async {
    when(
      () => getMonsters(
        offset: any(named: 'offset'),
        limit: 20,
        name: null,
        challengeRating: 5,
      ),
    ).thenAnswer((inv) async {
      final offset = inv.namedArguments[#offset] as int;
      return page(offset, 20);
    });

    bloc.add(const FilterToggled('challengeRating', 5));
    await nextSuccess();
    bloc.add(const FetchMonstersEvent());
    await bloc.stream.firstWhere((s) => s.monsters.length == 40);

    verify(
      () => getMonsters(offset: 20, limit: 20, name: null, challengeRating: 5),
    ).called(1);
  });

  test('FilterToggled de novo no mesmo valor remove o filtro', () async {
    when(
      () => getMonsters(
        offset: 0,
        limit: 20,
        name: null,
        challengeRating: any(named: 'challengeRating'),
      ),
    ).thenAnswer((_) async => page(0, 3));

    bloc.add(const FilterToggled('challengeRating', 2));
    await nextSuccess();
    expect(bloc.state.activeFilters, {'challengeRating': 2});

    bloc.add(const FilterToggled('challengeRating', 2));
    await bloc.stream.firstWhere(
      (s) => s.status == MonsterStatus.success && s.activeFilters.isEmpty,
    );
    verify(
      () =>
          getMonsters(offset: 0, limit: 20, name: null, challengeRating: null),
    ).called(1);
  });

  test('falha na busca emite o status failure', () async {
    when(
      () => getMonsters(
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
        name: any(named: 'name'),
        challengeRating: any(named: 'challengeRating'),
      ),
    ).thenThrow(Exception('rede'));

    bloc.add(const FetchMonstersEvent());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == MonsterStatus.failure,
    );

    expect(state.monsters, isEmpty);
  });
}
