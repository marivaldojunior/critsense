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

/// Busca a versão mais atual de um personagem a partir de um [CharacterState].
extension CharacterStateX on CharacterState {
  /// Retorna o [Character] de [id] neste estado, ou `null` se o estado não
  /// for [CharacterLoaded] ou o personagem não existir (mais) nele.
  ///
  /// Usado por widgets que recebem um [Character] "congelado" no momento da
  /// navegação (ex: abas da ficha) mas precisam refletir mudanças feitas em
  /// outro lugar (ex: adicionar uma magia pelo Compêndio) sem esperar o
  /// usuário sair e voltar à tela.
  Character? findCharacter(String id) {
    final state = this;
    if (state is! CharacterLoaded) return null;
    for (final character in state.characters) {
      if (character.id == id) return character;
    }
    return null;
  }
}
