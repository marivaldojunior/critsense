part of 'character_bloc.dart';

/// Base selada para todos os eventos do [CharacterBloc].
sealed class CharacterEvent {
  const CharacterEvent();
}

/// Solicita ao BLoC que carregue a lista de personagens do repositório.
final class LoadCharactersEvent extends CharacterEvent {
  const LoadCharactersEvent();
}

/// Solicita ao BLoC que persista [character] e recarregue a lista.
final class SaveCharacterEvent extends CharacterEvent {
  /// Entidade de domínio a ser persistida.
  final Character character;

  const SaveCharacterEvent(this.character);
}

/// Solicita ao BLoC que exclua o personagem com o [id] fornecido.
final class DeleteCharacterEvent extends CharacterEvent {
  /// Identificador único do personagem a ser removido.
  final String id;

  const DeleteCharacterEvent(this.id);
}

/// Solicita ao BLoC que marque/desmarque [proficiency] para o personagem
/// [characterId], persistindo o resultado.
///
/// Alterna (toggle) em vez de "setar": a UI (checkbox de perícia/teste de
/// resistência) não sabe o estado atual com certeza no momento do toque —
/// é o BLoC quem decide se a proficiência entra ou sai da lista, evitando
/// uma corrida entre o valor exibido e o valor persistido.
final class ToggleProficiencyEvent extends CharacterEvent {
  /// Personagem cuja lista de proficiências será alterada.
  final String characterId;

  /// Proficiência (perícia ou teste de resistência) a alternar.
  final Proficiency proficiency;

  const ToggleProficiencyEvent(this.characterId, this.proficiency);
}

/// Solicita ao BLoC que adicione [item] ao inventário do personagem referenciado.
///
/// Cross-Feature Command: equivalente a um `IRequest` do MediatR no .NET —
/// encapsula a intenção de adicionar um item sem que o emissor (feature
/// `compendium`) precise conhecer a implementação do handler (feature
/// `character_sheet`).
final class AddInventoryItemEvent extends CharacterEvent {
  /// Item a ser persistido no inventário.
  final InventoryItem item;

  const AddInventoryItemEvent(this.item);
}

/// Adiciona [spell] ao grimório do personagem dele (disparado pelo
/// compêndio). Se o personagem já tem a magia, ela só é atualizada.
final class AddSpellToCharacterEvent extends CharacterEvent {
  final CharacterSpell spell;

  const AddSpellToCharacterEvent(this.spell);
}

/// Solicita ao BLoC que registre [boss] (índice/nome do monstro) como
/// derrotado pelo personagem [characterId], persistindo o resultado.
/// Idempotente: se o monstro já está registrado, não faz nada.
final class AddBossToCharacterEvent extends CharacterEvent {
  /// Personagem que derrotou o monstro.
  final String characterId;

  /// Índice ou nome do monstro no compêndio.
  final String boss;

  const AddBossToCharacterEvent(this.characterId, this.boss);
}

/// Solicita ao BLoC que remova [boss] do registro de abates do personagem
/// [characterId], persistindo o resultado — para desfazer um registro
/// criado por engano.
final class RemoveBossFromCharacterEvent extends CharacterEvent {
  final String characterId;
  final String boss;

  const RemoveBossFromCharacterEvent(this.characterId, this.boss);
}

// ---------------------------------------------------------------------------
// Gerenciamento de Vida — ver as regras de PV/PV temporário e descanso do
// SRD do D&D 5e aplicadas em `CharacterBloc._onApplyDamage` etc.
// ---------------------------------------------------------------------------

/// Solicita ao BLoC que aplique [amount] de dano ao personagem
/// [characterId]: consome primeiro os PV temporários, só depois os PV
/// atuais (nunca abaixo de zero).
final class ApplyDamageEvent extends CharacterEvent {
  final String characterId;
  final int amount;

  const ApplyDamageEvent(this.characterId, this.amount);
}

/// Solicita ao BLoC que cure [amount] de PV do personagem [characterId],
/// sem ultrapassar o PV máximo.
final class HealHpEvent extends CharacterEvent {
  final String characterId;
  final int amount;

  const HealHpEvent(this.characterId, this.amount);
}

/// Solicita ao BLoC que conceda [amount] de PV temporário ao personagem
/// [characterId]. PV temporário não se acumula: só substitui o valor atual
/// se [amount] for maior.
final class AddTempHpEvent extends CharacterEvent {
  final String characterId;
  final int amount;

  const AddTempHpEvent(this.characterId, this.amount);
}

/// Solicita ao BLoC que conclua um Descanso Curto do personagem
/// [characterId]. A cura do Descanso Curto vem dos dados de vida gastos
/// durante ele (ver [SpendHitDieEvent]).
final class TakeShortRestEvent extends CharacterEvent {
  final String characterId;

  const TakeShortRestEvent(this.characterId);
}

/// Solicita ao BLoC que aplique um Descanso Longo ao personagem
/// [characterId] (ver `HitPointRules.afterLongRest`).
final class TakeLongRestEvent extends CharacterEvent {
  final String characterId;

  const TakeLongRestEvent(this.characterId);
}

/// Gasta um dado de vida do personagem [characterId] no Descanso Curto. A UI
/// rola o dado e manda o valor em [roll], para mostrar o resultado ao
/// jogador.
final class SpendHitDieEvent extends CharacterEvent {
  final String characterId;
  final int roll;

  const SpendHitDieEvent(this.characterId, this.roll);
}

// ---------------------------------------------------------------------------
// Salvaguardas contra a morte, condições e outros marcadores da ficha.
// ---------------------------------------------------------------------------

/// Aplica uma salvaguarda contra a morte com o d20 [roll], rolado pela UI.
final class DeathSaveRolledEvent extends CharacterEvent {
  final String characterId;
  final int roll;

  const DeathSaveRolledEvent(this.characterId, this.roll);
}

/// Ajusta à mão os sucessos e as falhas das salvaguardas contra a morte.
final class SetDeathSavesEvent extends CharacterEvent {
  final String characterId;
  final int successes;
  final int failures;

  const SetDeathSavesEvent(this.characterId, this.successes, this.failures);
}

/// Liga ou desliga a [condition] do personagem [characterId].
final class ToggleConditionEvent extends CharacterEvent {
  final String characterId;
  final Condition condition;

  const ToggleConditionEvent(this.characterId, this.condition);
}

/// Define o nível de exaustão (0 a 6) do personagem [characterId].
final class SetExhaustionEvent extends CharacterEvent {
  final String characterId;
  final int level;

  const SetExhaustionEvent(this.characterId, this.level);
}

/// Liga ou desliga a inspiração do personagem [characterId].
final class ToggleInspirationEvent extends CharacterEvent {
  final String characterId;

  const ToggleInspirationEvent(this.characterId);
}

/// Define o bônus manual de CA do personagem [characterId].
final class SetArmorClassBonusEvent extends CharacterEvent {
  final String characterId;
  final int bonus;

  const SetArmorClassBonusEvent(this.characterId, this.bonus);
}

/// Define o deslocamento base do personagem [characterId], em pés.
final class SetSpeedEvent extends CharacterEvent {
  final String characterId;
  final int speed;

  const SetSpeedEvent(this.characterId, this.speed);
}

// ---------------------------------------------------------------------------
// Espaços de magia — ver `SpellRules`.
// ---------------------------------------------------------------------------

/// Gasta um espaço de magia do nível [spellLevel] (1 a 9).
final class UseSpellSlotEvent extends CharacterEvent {
  final String characterId;
  final int spellLevel;

  const UseSpellSlotEvent(this.characterId, this.spellLevel);
}

/// Devolve um espaço gasto do nível [spellLevel] (correção manual).
final class RestoreSpellSlotEvent extends CharacterEvent {
  final String characterId;
  final int spellLevel;

  const RestoreSpellSlotEvent(this.characterId, this.spellLevel);
}

/// Gasta um espaço da Magia de Pacto (Bruxo).
final class UsePactSlotEvent extends CharacterEvent {
  final String characterId;

  const UsePactSlotEvent(this.characterId);
}

/// Devolve um espaço gasto da Magia de Pacto.
final class RestorePactSlotEvent extends CharacterEvent {
  final String characterId;

  const RestorePactSlotEvent(this.characterId);
}

/// Define a quantidade da moeda [coin] do personagem [characterId].
final class SetCoinsEvent extends CharacterEvent {
  final String characterId;
  final Coin coin;
  final int amount;

  const SetCoinsEvent(this.characterId, this.coin, this.amount);
}

// ---------------------------------------------------------------------------
// Evolução — ver `LevelRules`.
// ---------------------------------------------------------------------------

/// Soma [amount] de XP ao personagem [characterId].
final class AddExperienceEvent extends CharacterEvent {
  final String characterId;
  final int amount;

  const AddExperienceEvent(this.characterId, this.amount);
}

/// Sobe um nível do personagem [characterId] com o valor do dado de vida
/// [hitDieResult] (sem a CON) e o Aumento de Valor de Atributo
/// [abilityIncreases], quando o nível tem um.
final class LevelUpEvent extends CharacterEvent {
  final String characterId;
  final int hitDieResult;
  final Map<AttributeType, int> abilityIncreases;

  const LevelUpEvent(
    this.characterId, {
    required this.hitDieResult,
    this.abilityIncreases = const {},
  });
}
