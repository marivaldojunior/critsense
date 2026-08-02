part of 'character_bloc.dart';

/// Base selada para todos os estados emitidos pelo [CharacterBloc].
sealed class CharacterState {
  const CharacterState();
}

/// Estado inicial antes de qualquer interação.
final class CharacterInitial extends CharacterState {
  const CharacterInitial();
}

/// Emitido enquanto a busca ao repositório está em andamento.
final class CharacterLoading extends CharacterState {
  const CharacterLoading();
}

/// Emitido quando a lista de personagens foi carregada com sucesso.
final class CharacterLoaded extends CharacterState {
  /// Lista de personagens retornada pelo repositório.
  final List<Character> characters;

  const CharacterLoaded(this.characters);
}

/// Emitido quando ocorre um erro durante o carregamento.
final class CharacterError extends CharacterState {
  /// Mensagem descritiva do erro para exibição na UI.
  final String message;

  const CharacterError(this.message);
}
