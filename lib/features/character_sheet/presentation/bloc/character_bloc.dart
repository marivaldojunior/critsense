import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/attribute.dart';
import '../../domain/entities/attribute_type.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/proficiency.dart';
import '../../domain/entities/skill.dart';
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
    on<ToggleProficiencyEvent>(_onToggleProficiency);
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

  /// Alterna [ToggleProficiencyEvent.proficiency] na lista de proficiências
  /// do personagem [ToggleProficiencyEvent.characterId], persiste e emite a
  /// lista atualizada em memória — sem recarregar do repositório, já que o
  /// resultado da alteração já é conhecido localmente.
  Future<void> _onToggleProficiency(
    ToggleProficiencyEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CharacterLoaded) return;

    final index = currentState.characters.indexWhere(
      (c) => c.id == event.characterId,
    );
    if (index == -1) return;

    final character = currentState.characters[index];
    final hasProficiency = character.proficiencies.contains(
      event.proficiency,
    );
    final updatedProficiencies = hasProficiency
        ? (character.proficiencies.toList()..remove(event.proficiency))
        : [...character.proficiencies, event.proficiency];
    final updatedCharacter = character.copyWith(
      proficiencies: updatedProficiencies,
    );

    try {
      await _saveCharacter(updatedCharacter);
      final updatedCharacters = currentState.characters.toList()
        ..[index] = updatedCharacter;
      emit(CharacterLoaded(updatedCharacters));
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }

  // ---------------------------------------------------------------------
  // Cálculos da ficha — Perícias e Testes de Resistência.
  //
  // São funções puras (sem `emit`/estado): a UI as chama diretamente a
  // partir do [Character] exibido, então não há necessidade de disparar
  // eventos nem de guardar o resultado no [CharacterState] para obter um
  // valor que já é 100% derivável dos dados do próprio personagem.
  // ---------------------------------------------------------------------

  /// Modificador final de [skill] para [character]: o modificador do
  /// atributo que a rege somado ao [Character.proficiencyBonus] quando o
  /// personagem é proficiente nela.
  ///
  /// Ex: Furtividade (Destreza) com DEX +2 e proficiência: 2 + 2 = 4.
  int skillModifier(Character character, Skill skill) {
    final abilityMod = attributeModifier(
      character.attributes.valueOf(skill.attribute),
    );
    final isProficient = character.proficiencies.contains(
      SkillProficiency(skill),
    );
    return isProficient ? abilityMod + character.proficiencyBonus : abilityMod;
  }

  /// Modificador final do Teste de Resistência de [attribute] para
  /// [character]: mesma regra de [skillModifier], mas para o atributo
  /// diretamente em vez de uma perícia específica.
  int savingThrowModifier(Character character, AttributeType attribute) {
    final abilityMod = attributeModifier(character.attributes.valueOf(attribute));
    final isProficient = character.proficiencies.contains(
      SavingThrowProficiency(attribute),
    );
    return isProficient ? abilityMod + character.proficiencyBonus : abilityMod;
  }

  /// Sabedoria Passiva (Percepção): `10 + modificador de Percepção`, que já
  /// inclui o bônus de proficiência quando o personagem é proficiente na
  /// perícia Percepção — não existe uma proficiência "passiva" separada no
  /// SRD, a passiva deriva da perícia ativa.
  int passiveWisdom(Character character) =>
      10 + skillModifier(character, Skill.perception);
}
