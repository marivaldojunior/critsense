import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/character.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/add_inventory_item_usecase.dart';
import '../../domain/usecases/delete_character_usecase.dart';
import '../../domain/usecases/get_all_characters_usecase.dart';
import '../../domain/usecases/save_character_use_case.dart';

part 'character_event.dart';
part 'character_state.dart';

/// BLoC responsável pelo ciclo de vida do estado da listagem de personagens.
///
/// Recebe [CharacterEvent]s, executa os Use Cases correspondentes e emite
/// novos [CharacterState]s para a UI reagir de forma declarativa.
class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GetAllCharactersUseCase _getAllCharacters;
  final SaveCharacterUseCase _saveCharacter;
  final DeleteCharacterUseCase _deleteCharacter;
  final AddInventoryItemUseCase _addInventoryItem;

  /// Injeta os use cases e registra os handlers de eventos.
  CharacterBloc(
    GetAllCharactersUseCase getAllCharacters,
    SaveCharacterUseCase saveCharacter,
    DeleteCharacterUseCase deleteCharacter,
    AddInventoryItemUseCase addInventoryItem,
  ) : _getAllCharacters = getAllCharacters,
      _saveCharacter = saveCharacter,
      _deleteCharacter = deleteCharacter,
      _addInventoryItem = addInventoryItem,
      super(const CharacterInitial()) {
    on<LoadCharactersEvent>(_onLoadCharacters);
    on<SaveCharacterEvent>(_onSaveCharacter);
    on<DeleteCharacterEvent>(_onDeleteCharacter);
    on<AddInventoryItemEvent>(_onAddInventoryItem);
  }

  /// Carrega todos os personagens ao receber [LoadCharactersEvent].
  Future<void> _onLoadCharacters(
    LoadCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    emit(const CharacterLoading());
    try {
      final characters = await _getAllCharacters();
      emit(CharacterLoaded(characters));
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }

  /// Persiste o personagem e recarrega a lista para refletir o novo item.
  Future<void> _onSaveCharacter(
    SaveCharacterEvent event,
    Emitter<CharacterState> emit,
  ) async {
    try {
      await _saveCharacter(event.character);
      add(const LoadCharactersEvent());
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }

  /// Remove o personagem e recarrega a lista para refletir a exclusão.
  Future<void> _onDeleteCharacter(
    DeleteCharacterEvent event,
    Emitter<CharacterState> emit,
  ) async {
    try {
      await _deleteCharacter(event.id);
      add(const LoadCharactersEvent());
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }

  /// Persiste o item no inventário sem recarregar a lista de personagens.
  Future<void> _onAddInventoryItem(
    AddInventoryItemEvent event,
    Emitter<CharacterState> emit,
  ) async {
    try {
      await _addInventoryItem(event.item);
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }
}
