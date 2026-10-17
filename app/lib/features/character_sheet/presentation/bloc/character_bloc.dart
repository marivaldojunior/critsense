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
    on<AddSpellToCharacterEvent>(_onAddSpellToCharacter);
    on<AddBossToCharacterEvent>(_onAddBossToCharacter);
    on<RemoveSpellFromCharacterEvent>(_onRemoveSpellFromCharacter);
    on<RemoveBossFromCharacterEvent>(_onRemoveBossFromCharacter);
    on<ApplyDamageEvent>(_onApplyDamage);
    on<HealHpEvent>(_onHealHp);
    on<AddTempHpEvent>(_onAddTempHp);
    on<TakeShortRestEvent>(_onTakeShortRest);
    on<TakeLongRestEvent>(_onTakeLongRest);
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

  /// Aplica [transform] ao personagem [characterId] no estado atual (se
  /// ele existir e estiver carregado), persiste o resultado e emite a
  /// lista atualizada em memória — sem recarregar do repositório, já que o
  /// resultado da alteração já é conhecido localmente.
  ///
  /// [transform] retorna `null` para sinalizar "nada a fazer" (ex: tentar
  /// remover uma magia que o personagem não tem) — nesse caso nenhum save
  /// nem emit acontece, mantendo os handlers idempotentes sem cada um
  /// precisar checar isso por conta própria.
  ///
  /// Handler compartilhado por todo evento que só modifica um campo de um
  /// [Character] já carregado (proficiências, magias, abates...), evitando
  /// repetir a mesma busca por índice + save + `CharacterLoaded` novo em
  /// cada um deles.
  Future<void> _updateCharacter(
    Emitter<CharacterState> emit,
    String characterId,
    Character? Function(Character character) transform,
  ) async {
    final currentState = state;
    if (currentState is! CharacterLoaded) return;

    final index = currentState.characters.indexWhere(
      (c) => c.id == characterId,
    );
    if (index == -1) return;

    final updatedCharacter = transform(currentState.characters[index]);
    if (updatedCharacter == null) return;

    try {
      await _saveCharacter(updatedCharacter);
      final updatedCharacters = currentState.characters.toList()
        ..[index] = updatedCharacter;
      emit(CharacterLoaded(updatedCharacters));
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }

  /// Alterna [ToggleProficiencyEvent.proficiency] na lista de proficiências
  /// do personagem [ToggleProficiencyEvent.characterId].
  Future<void> _onToggleProficiency(
    ToggleProficiencyEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      final hasProficiency = character.proficiencies.contains(
        event.proficiency,
      );
      final updatedProficiencies = hasProficiency
          ? (character.proficiencies.toList()..remove(event.proficiency))
          : [...character.proficiencies, event.proficiency];
      return character.copyWith(proficiencies: updatedProficiencies);
    });
  }

  /// Vincula [AddSpellToCharacterEvent.spell] ao personagem
  /// [AddSpellToCharacterEvent.characterId].
  Future<void> _onAddSpellToCharacter(
    AddSpellToCharacterEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      if (character.spells.contains(event.spell)) return null;
      return character.copyWith(spells: [...character.spells, event.spell]);
    });
  }

  /// Desvincula [RemoveSpellFromCharacterEvent.spell] do personagem
  /// [RemoveSpellFromCharacterEvent.characterId].
  Future<void> _onRemoveSpellFromCharacter(
    RemoveSpellFromCharacterEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      if (!character.spells.contains(event.spell)) return null;
      return character.copyWith(
        spells: character.spells.toList()..remove(event.spell),
      );
    });
  }

  /// Registra [AddBossToCharacterEvent.boss] como derrotado pelo
  /// personagem [AddBossToCharacterEvent.characterId].
  Future<void> _onAddBossToCharacter(
    AddBossToCharacterEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      if (character.defeatedBosses.contains(event.boss)) return null;
      return character.copyWith(
        defeatedBosses: [...character.defeatedBosses, event.boss],
      );
    });
  }

  /// Remove [RemoveBossFromCharacterEvent.boss] do registro de abates do
  /// personagem [RemoveBossFromCharacterEvent.characterId].
  Future<void> _onRemoveBossFromCharacter(
    RemoveBossFromCharacterEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      if (!character.defeatedBosses.contains(event.boss)) return null;
      return character.copyWith(
        defeatedBosses: character.defeatedBosses.toList()..remove(event.boss),
      );
    });
  }

  // ---------------------------------------------------------------------
  // Gerenciamento de Vida — regras do SRD do D&D 5e.
  // ---------------------------------------------------------------------

  /// Aplica [ApplyDamageEvent.amount] de dano ao personagem
  /// [ApplyDamageEvent.characterId]: o dano é primeiro absorvido pelos PV
  /// temporários — só o que sobra depois de zerá-los desconta dos PV
  /// atuais, que nunca ficam abaixo de zero.
  Future<void> _onApplyDamage(
    ApplyDamageEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      final absorbedByTemp = event.amount < character.temporaryHitPoints
          ? event.amount
          : character.temporaryHitPoints;
      final remainingDamage = event.amount - absorbedByTemp;
      final updatedCurrentHp = character.currentHitPoints - remainingDamage;

      return character.copyWith(
        currentHitPoints: updatedCurrentHp < 0 ? 0 : updatedCurrentHp,
        temporaryHitPoints: character.temporaryHitPoints - absorbedByTemp,
      );
    });
  }

  /// Cura [HealHpEvent.amount] PV do personagem [HealHpEvent.characterId],
  /// sem ultrapassar o PV máximo.
  Future<void> _onHealHp(HealHpEvent event, Emitter<CharacterState> emit) {
    return _updateCharacter(emit, event.characterId, (character) {
      final updatedCurrentHp = character.currentHitPoints + event.amount;
      return character.copyWith(
        currentHitPoints: updatedCurrentHp > character.maxHitPoints
            ? character.maxHitPoints
            : updatedCurrentHp,
      );
    });
  }

  /// Concede [AddTempHpEvent.amount] de PV temporário ao personagem
  /// [AddTempHpEvent.characterId]. PV temporário não se acumula: só
  /// substitui o valor atual se o novo for maior — um valor menor ou igual
  /// é ignorado (retorna `null`, sem persistir nada).
  Future<void> _onAddTempHp(
    AddTempHpEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      if (event.amount <= character.temporaryHitPoints) return null;
      return character.copyWith(temporaryHitPoints: event.amount);
    });
  }

  /// Aplica um Descanso Curto ao personagem [TakeShortRestEvent.characterId].
  ///
  /// Sem um sistema de Dados de Vida modelado no app, um Descanso Curto não
  /// altera PV por si só — ver a documentação de [TakeShortRestEvent].
  Future<void> _onTakeShortRest(
    TakeShortRestEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) => null);
  }

  /// Aplica um Descanso Longo ao personagem [TakeLongRestEvent.characterId]:
  /// PV atual volta ao máximo e PV temporário zera.
  Future<void> _onTakeLongRest(
    TakeLongRestEvent event,
    Emitter<CharacterState> emit,
  ) {
    return _updateCharacter(emit, event.characterId, (character) {
      return character.copyWith(
        currentHitPoints: character.maxHitPoints,
        temporaryHitPoints: 0,
      );
    });
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
