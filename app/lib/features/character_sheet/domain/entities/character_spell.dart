/// Magia do grimório de um personagem.
class CharacterSpell {
  /// Identificador único da linha (UUID).
  final String id;

  /// Personagem dono da magia.
  final String characterId;

  /// Índice da magia na API 5e-bits (ex: `magic-missile`), para abrir o
  /// detalhe no compêndio.
  final String spellIndex;

  final String name;

  /// Nível da magia: 0 para truques, 1 a 9 para as outras. `null` em magias
  /// salvas antes desta informação existir; a ficha busca o nível no
  /// compêndio quando tem internet.
  final int? level;

  /// Magia preparada para o dia (só faz diferença nas classes que preparam
  /// magias; truques estão sempre disponíveis).
  final bool prepared;

  const CharacterSpell({
    required this.id,
    required this.characterId,
    required this.spellIndex,
    required this.name,
    required this.level,
    this.prepared = false,
  });

  bool get isCantrip => level == 0;

  CharacterSpell copyWith({int? level, bool? prepared}) {
    return CharacterSpell(
      id: id,
      characterId: characterId,
      spellIndex: spellIndex,
      name: name,
      level: level ?? this.level,
      prepared: prepared ?? this.prepared,
    );
  }
}
