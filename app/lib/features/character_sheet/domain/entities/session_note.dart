/// Nota de sessão de RPG atrelada a um personagem.
class SessionNote {
  /// Identificador único da nota (UUID gerado no domínio).
  final String id;

  /// Identificador do personagem ao qual esta nota pertence.
  final String characterId;

  /// Título resumido da anotação de sessão.
  final String title;

  /// Corpo completo da anotação.
  final String content;

  /// Momento em que a nota foi criada.
  final DateTime createdAt;

  const SessionNote({
    required this.id,
    required this.characterId,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}
