import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/spell_summary.dart';
import '../../domain/usecases/get_spells_usecase.dart';

part 'compendium_event.dart';
part 'compendium_state.dart';

/// BLoC responsável pelo estado da listagem de magias do compêndio.
class CompendiumBloc extends Bloc<CompendiumEvent, CompendiumState> {
  final GetSpellsUseCase _getSpells;

  /// Injeta [getSpells] e registra os handlers de eventos.
  CompendiumBloc(GetSpellsUseCase getSpells)
    : _getSpells = getSpells,
      super(const CompendiumInitial()) {
    on<LoadSpellsEvent>(_onLoadSpells);
  }

  /// Busca as magias na API ao receber [LoadSpellsEvent].
  Future<void> _onLoadSpells(
    LoadSpellsEvent event,
    Emitter<CompendiumState> emit,
  ) async {
    emit(const CompendiumLoading());
    try {
      final spells = await _getSpells();
      emit(CompendiumLoaded(spells));
    } catch (e) {
      emit(CompendiumError(e.toString()));
    }
  }
}
