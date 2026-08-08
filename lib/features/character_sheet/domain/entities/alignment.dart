/// As nove tendências (alinhamentos) clássicas do D&D 5e.
enum Alignment {
  lawfulGood,
  neutralGood,
  chaoticGood,
  lawfulNeutral,
  trueNeutral,
  chaoticNeutral,
  lawfulEvil,
  neutralEvil,
  chaoticEvil;

  String get label => switch (this) {
    Alignment.lawfulGood => 'Leal e Bom',
    Alignment.neutralGood => 'Neutro e Bom',
    Alignment.chaoticGood => 'Caótico e Bom',
    Alignment.lawfulNeutral => 'Leal e Neutro',
    Alignment.trueNeutral => 'Neutro',
    Alignment.chaoticNeutral => 'Caótico e Neutro',
    Alignment.lawfulEvil => 'Leal e Mau',
    Alignment.neutralEvil => 'Neutro e Mau',
    Alignment.chaoticEvil => 'Caótico e Mau',
  };
}
