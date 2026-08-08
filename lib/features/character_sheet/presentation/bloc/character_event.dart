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
