/// As condições do SRD 5.1. A exaustão é separada (ver [exhaustionEffects]),
/// porque ela tem níveis em vez de só ligada/desligada.
///
/// O nome do valor (ex: `poisoned`) é o que fica salvo no banco.
enum Condition {
  blinded(
    'Cego',
    'Falha em testes que dependem da visão. Ataques contra ele têm vantagem; '
        'os ataques dele têm desvantagem.',
  ),
  charmed(
    'Enfeitiçado',
    'Não pode atacar quem o enfeitiçou. Quem o enfeitiçou tem vantagem em '
        'testes sociais contra ele.',
  ),
  deafened('Surdo', 'Falha em testes que dependem da audição.'),
  frightened(
    'Amedrontado',
    'Desvantagem em testes e ataques enquanto vê a fonte do medo. Não pode se '
        'aproximar dela por vontade própria.',
  ),
  grappled(
    'Agarrado',
    'Deslocamento 0. Termina se quem agarra ficar incapacitado ou for afastado.',
  ),
  incapacitated('Incapacitado', 'Não pode fazer ações nem reações.'),
  invisible(
    'Invisível',
    'Não pode ser visto sem magia. Ataques contra ele têm desvantagem; os '
        'ataques dele têm vantagem.',
  ),
  paralyzed(
    'Paralisado',
    'Incapacitado, não se move nem fala. Falha em testes de resistência de '
        'FOR e DES. Ataques a até 1,5 m que acertam são críticos.',
  ),
  petrified(
    'Petrificado',
    'Vira pedra: incapacitado e com resistência a todo dano. Falha em testes '
        'de resistência de FOR e DES.',
  ),
  poisoned('Envenenado', 'Desvantagem em ataques e em testes de habilidade.'),
  prone(
    'Caído',
    'Só rasteja. Desvantagem nos próprios ataques. Ataques a até 1,5 m contra '
        'ele têm vantagem; os de mais longe, desvantagem.',
  ),
  restrained(
    'Impedido',
    'Deslocamento 0. Desvantagem em ataques e em testes de resistência de DES. '
        'Ataques contra ele têm vantagem.',
  ),
  stunned(
    'Atordoado',
    'Incapacitado e só fala com dificuldade. Falha em testes de resistência de '
        'FOR e DES. Ataques contra ele têm vantagem.',
  ),
  unconscious(
    'Inconsciente',
    'Incapacitado, cai e larga o que segura. Falha em testes de resistência de '
        'FOR e DES. Ataques a até 1,5 m que acertam são críticos.',
  );

  final String label;
  final String description;

  const Condition(this.label, this.description);

  String get iconAsset => 'assets/icons/condition/$name.svg';

  /// Condições que zeram o deslocamento.
  bool get stopsMovement =>
      this == grappled ||
      this == restrained ||
      this == paralyzed ||
      this == petrified ||
      this == stunned ||
      this == unconscious;

  /// Condições que deixam o personagem incapacitado e, por isso, terminam a
  /// concentração.
  bool get incapacitates =>
      this == incapacitated ||
      this == paralyzed ||
      this == petrified ||
      this == stunned ||
      this == unconscious;

  /// Lê o nome salvo no banco; nomes desconhecidos viram `null`.
  static Condition? fromName(String name) {
    for (final condition in values) {
      if (condition.name == name) return condition;
    }
    return null;
  }
}

/// Nível máximo de exaustão: no nível 6 o personagem morre.
const maxExhaustionLevel = 6;

/// Efeito de cada nível de exaustão do SRD (os efeitos se acumulam).
const exhaustionEffects = <int, String>{
  1: 'Desvantagem em testes de habilidade.',
  2: 'Deslocamento reduzido à metade.',
  3: 'Desvantagem em ataques e testes de resistência.',
  4: 'PV máximo reduzido à metade.',
  5: 'Deslocamento 0.',
  6: 'Morte.',
};
