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

/// Solicita ao BLoC que vincule [spell] (índice/nome da magia) ao
/// personagem [characterId], persistindo o resultado. Idempotente: se a
/// magia já está registrada, não faz nada.
final class AddSpellToCharacterEvent extends CharacterEvent {
  /// Personagem que passa a conhecer a magia.
  final String characterId;

  /// Índice ou nome da magia no compêndio.
  final String spell;

  const AddSpellToCharacterEvent(this.characterId, this.spell);
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

/// Solicita ao BLoC que desvincule [spell] do personagem [characterId],
/// persistindo o resultado — para desfazer um vínculo criado por engano.
final class RemoveSpellFromCharacterEvent extends CharacterEvent {
  final String characterId;
  final String spell;

  const RemoveSpellFromCharacterEvent(this.characterId, this.spell);
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

/// Solicita ao BLoC que aplique um Descanso Curto ao personagem
/// [characterId].
///
/// Sem um sistema de Dados de Vida modelado no app, um Descanso Curto não
/// restaura PV automaticamente por si só (regra correta do SRD: cura no
/// descanso curto exige gastar Dados de Vida) — o evento existe para o
/// fluxo da UI e para acomodar essa regra quando for implementada.
final class TakeShortRestEvent extends CharacterEvent {
  final String characterId;

  const TakeShortRestEvent(this.characterId);
}

/// Solicita ao BLoC que aplique um Descanso Longo ao personagem
/// [characterId]: PV atual volta ao máximo e PV temporário zera.
final class TakeLongRestEvent extends CharacterEvent {
  final String characterId;

  const TakeLongRestEvent(this.characterId);
}
