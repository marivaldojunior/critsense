/// Custo de um equipamento em moedas do D&D 5e (ex: 15 gp).
class EquipmentCost {
  /// Quantidade de moedas.
  final int quantity;

  /// Unidade monetária (ex: "gp", "sp", "cp").
  final String unit;

  const EquipmentCost({required this.quantity, required this.unit});
}

/// Dano causado por uma arma, incluindo o tipo elemental/físico do dado.
class EquipmentDamage {
  /// Fórmula de dados do dano (ex: "1d8").
  final String dice;

  /// Identificador do tipo de dano na API (ex: "slashing"), usado para
  /// localizar o ícone correspondente em `assets/icons/damage/`.
  final String damageTypeIndex;

  /// Nome legível do tipo de dano (ex: "Slashing").
  final String damageTypeName;

  const EquipmentDamage({
    required this.dice,
    required this.damageTypeIndex,
    required this.damageTypeName,
  });
}

/// Alcance de uma arma em pés.
class EquipmentRange {
  /// Alcance normal, sem desvantagem.
  final int normal;

  /// Alcance máximo (com desvantagem); nulo para armas corpo a corpo.
  final int? long;

  const EquipmentRange({required this.normal, this.long});
}

/// Detalhes completos de um equipamento retornados pelo endpoint individual da API.
class EquipmentDetail {
  /// Identificador único do equipamento na API (ex: "longsword").
  final String index;

  /// Nome legível do equipamento.
  final String name;

  /// Categoria do equipamento (ex: "Weapon", "Armor", "Adventuring Gear").
  final String equipmentCategory;

  /// Custo em moedas.
  final EquipmentCost cost;

  /// Peso em libras.
  final double weight;

  /// Parágrafos de descrição do equipamento.
  final List<String> desc;

  /// Dano da arma; nulo para equipamentos que não são armas.
  final EquipmentDamage? damage;

  /// Alcance da arma; nulo para equipamentos que não são armas.
  final EquipmentRange? range;

  /// Classe de Armadura base; nula para equipamentos que não são armaduras.
  final int? armorClass;

  const EquipmentDetail({
    required this.index,
    required this.name,
    required this.equipmentCategory,
    required this.cost,
    required this.weight,
    required this.desc,
    this.damage,
    this.range,
    this.armorClass,
  });
}
