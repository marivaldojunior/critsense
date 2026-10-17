import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/compendium/domain/entities/equipment_summary.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_equipments_usecase.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/equipment_bloc.dart';

class _MockGetEquipmentsUseCase extends Mock implements GetEquipmentsUseCase {}

/// Testa a listagem de Equipamentos no [EquipmentBloc]: carga, debounce da
/// busca e filtro de categoria.
void main() {
  late _MockGetEquipmentsUseCase getEquipments;
  late EquipmentBloc bloc;

  const longsword = EquipmentSummary(
    index: 'longsword',
    name: 'Longsword',
    url: '/api/equipment/longsword',
  );

  /// Espera mais que o debounce de 500ms da busca.
  Future<void> waitDebounce() =>
      Future<void>.delayed(const Duration(milliseconds: 650));

  setUp(() {
    getEquipments = _MockGetEquipmentsUseCase();
    bloc = EquipmentBloc(getEquipments);
    when(
      () => getEquipments(
        name: any(named: 'name'),
        equipmentCategory: any(named: 'equipmentCategory'),
      ),
    ).thenAnswer((_) async => [longsword]);
  });

  tearDown(() => bloc.close());

  test('LoadEquipmentsEvent carrega a lista sem filtros', () async {
    bloc.add(const LoadEquipmentsEvent());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == EquipmentStatus.success,
    );

    expect(state.equipments, [longsword]);
    verify(() => getEquipments(name: null, equipmentCategory: null)).called(1);
  });

  test('a busca espera o debounce e usa só o último texto', () async {
    bloc
      ..add(const SearchQueryChanged('lo'))
      ..add(const SearchQueryChanged('long'));
    await waitDebounce();

    verify(
      () => getEquipments(name: 'long', equipmentCategory: null),
    ).called(1);
    verifyNoMoreInteractions(getEquipments);
  });

  test('FilterToggled envia a categoria e mantém a busca ativa', () async {
    bloc.add(const SearchQueryChanged('sword'));
    await waitDebounce();
    bloc.add(const FilterToggled('equipmentCategory', 'weapon'));
    await bloc.stream.firstWhere(
      (s) =>
          s.status == EquipmentStatus.success &&
          s.activeFilters['equipmentCategory'] == 'weapon',
    );

    verify(
      () => getEquipments(name: 'sword', equipmentCategory: 'weapon'),
    ).called(1);
  });

  test('falha na carga emite o status failure', () async {
    when(
      () => getEquipments(
        name: any(named: 'name'),
        equipmentCategory: any(named: 'equipmentCategory'),
      ),
    ).thenThrow(Exception('rede'));

    bloc.add(const LoadEquipmentsEvent());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == EquipmentStatus.failure,
    );

    expect(state.errorMessage, isNotNull);
  });
}
