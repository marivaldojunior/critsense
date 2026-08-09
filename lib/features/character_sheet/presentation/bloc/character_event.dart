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
