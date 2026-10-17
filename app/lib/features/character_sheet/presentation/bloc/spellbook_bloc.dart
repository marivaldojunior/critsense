import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/compendium/domain/usecases/get_spell_detail_usecase.dart';

import '../../domain/entities/character_spell.dart';
import '../../domain/usecases/delete_character_spell_usecase.dart';
import '../../domain/usecases/get_character_spells_usecase.dart';
import '../../domain/usecases/save_character_spell_usecase.dart';

part 'spellbook_event.dart';
part 'spellbook_state.dart';

/// BLoC do grimório de um personagem (aba Magias).
///
/// Magias migradas de versões antigas não têm nível salvo; depois de cada
/// carga, o BLoC busca o nível delas no compêndio. Sem internet, elas só
/// ficam no grupo "Nível desconhecido" até a próxima abertura.
class SpellbookBloc extends Bloc<SpellbookEvent, SpellbookState> {
  final GetCharacterSpellsUseCase _getSpells;
  final SaveCharacterSpellUseCase _saveSpell;
  final DeleteCharacterSpellUseCase _deleteSpell;
  final GetSpellDetailUseCase _getSpellDetail;

  String? _characterId;

  SpellbookBloc(
    GetCharacterSpellsUseCase getSpells,
    SaveCharacterSpellUseCase saveSpell,
    DeleteCharacterSpellUseCase deleteSpell,
    GetSpellDetailUseCase getSpellDetail,
  ) : _getSpells = getSpells,
      _saveSpell = saveSpell,
      _deleteSpell = deleteSpell,
      _getSpellDetail = getSpellDetail,
      super(const SpellbookState()) {
    on<LoadSpellbookEvent>(_onLoad);
    on<TogglePreparedEvent>(_onTogglePrepared);
    on<DeleteSpellEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadSpellbookEvent event,
    Emitter<SpellbookState> emit,
  ) async {
    _characterId = event.characterId;
    emit(state.copyWith(status: SpellbookStatus.loading));
    await _reload(emit);
    await _resolveMissingLevels(emit);
  }

  Future<void> _onTogglePrepared(
    TogglePreparedEvent event,
    Emitter<SpellbookState> emit,
  ) async {
    final spell = event.spell;
    try {
      await _saveSpell(spell.copyWith(prepared: !spell.prepared));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Não foi possível salvar a magia.'));
      return;
    }
    await _reload(emit);
  }

  Future<void> _onDelete(
    DeleteSpellEvent event,
    Emitter<SpellbookState> emit,
  ) async {
    try {
      await _deleteSpell(event.spell.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Não foi possível remover a magia.'));
      return;
    }
    await _reload(emit);
  }

  Future<void> _reload(Emitter<SpellbookState> emit) async {
    final characterId = _characterId;
    if (characterId == null) return;
    try {
      final spells = await _getSpells(characterId);
      emit(state.copyWith(status: SpellbookStatus.success, spells: spells));
    } catch (e) {
      emit(
        state.copyWith(
          status: SpellbookStatus.failure,
          errorMessage: 'Não foi possível carregar as magias.',
        ),
      );
    }
  }

  /// Busca no compêndio o nível das magias sem nível. Uma falha (ex: sem
  /// internet) não é um erro para o usuário: a magia só continua sem nível.
  Future<void> _resolveMissingLevels(Emitter<SpellbookState> emit) async {
    final missing = state.spells.where((s) => s.level == null).toList();
    if (missing.isEmpty) return;
    var changed = false;
    for (final spell in missing) {
      try {
        final detail = await _getSpellDetail(spell.spellIndex);
        await _saveSpell(spell.copyWith(level: detail.level));
        changed = true;
      } catch (_) {
        // Sem internet ou magia fora do SRD: tenta de novo na próxima carga.
      }
    }
    if (changed) await _reload(emit);
  }
}
