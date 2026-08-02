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
