/// Item do inventário de um personagem.
///
/// Os dados de combate (armadura e arma) vêm do compêndio quando o item é
/// adicionado de lá; itens personalizados não têm esses dados.
class InventoryItem {
  /// Prefixo de [itemIndex] dos itens criados à mão (fora do compêndio).
  static const customIndexPrefix = 'custom:';

  /// Identificador único do item no inventário.
  final String id;

  /// Personagem dono do item.
  final String characterId;

  /// Índice do equipamento na API 5e-bits, ou `custom:<id>` para itens
  /// criados à mão.
  final String itemIndex;

  final String name;

  /// Categoria do equipamento (ex: "Weapon", "Armor", "Adventuring Gear").
  final String equipmentCategory;

  final int quantity;

  /// Peso de uma unidade, em libras.
  final double weight;

  /// Arma empunhada ou armadura vestida.
  final bool equipped;

  /// O item exige sintonia para funcionar (itens mágicos).
  final bool requiresAttunement;

  /// O personagem está sintonizado com o item (no máximo 3 itens).
  final bool attuned;

  /// `false` em itens salvos antes destes dados existirem: a ficha busca no
  /// compêndio o peso e os dados de combate quando tem internet.
  final bool detailsLoaded;

  // ── Armadura ───────────────────────────────────────────────────────────

  /// "Light", "Medium", "Heavy" ou "Shield"; `null` se não é armadura.
  final String? armorCategory;

  /// CA base da armadura (no escudo, o bônus: +2).
  final int? armorBase;

  /// A armadura soma o modificador de DES.
  final bool armorDexBonus;

  /// Limite do modificador de DES somado (2 nas armaduras médias).
  final int? armorMaxDexBonus;

  // ── Arma ───────────────────────────────────────────────────────────────

  /// "Simple" ou "Martial"; `null` se não é arma.
  final String? weaponCategory;

  /// "Melee" ou "Ranged".
  final String? weaponRange;

  /// Dado de dano (ex: `1d8`).
  final String? damageDice;

  /// Tipo de dano (ex: "Slashing").
  final String? damageType;

  /// Dano com as duas mãos (propriedade Versátil).
  final String? versatileDamageDice;

  /// Índices das propriedades da arma (ex: `finesse`, `light`).
  final List<String> weaponProperties;

  const InventoryItem({
    required this.id,
    required this.characterId,
    required this.itemIndex,
    required this.name,
    required this.equipmentCategory,
    this.quantity = 1,
    this.weight = 0,
    this.equipped = false,
    this.requiresAttunement = false,
    this.attuned = false,
    this.detailsLoaded = true,
    this.armorCategory,
    this.armorBase,
    this.armorDexBonus = false,
    this.armorMaxDexBonus,
    this.weaponCategory,
    this.weaponRange,
    this.damageDice,
    this.damageType,
    this.versatileDamageDice,
    this.weaponProperties = const [],
  });

  bool get isCustom => itemIndex.startsWith(customIndexPrefix);

  bool get isShield => armorCategory?.toLowerCase() == 'shield';

  /// Armadura vestida no corpo (leve, média ou pesada), sem contar o escudo.
  bool get isBodyArmor => armorCategory != null && !isShield;

  bool get isWeapon => damageDice != null;

  /// Pode ser equipado: arma, armadura ou escudo.
  bool get isEquippable => isWeapon || armorCategory != null;

  /// Peso total da pilha (quantidade × peso da unidade).
  double get totalWeight => weight * quantity;

  bool hasProperty(String property) => weaponProperties.contains(property);

  InventoryItem copyWith({
    String? name,
    String? equipmentCategory,
    int? quantity,
    double? weight,
    bool? equipped,
    bool? requiresAttunement,
    bool? attuned,
    bool? detailsLoaded,
    String? armorCategory,
    int? armorBase,
    bool? armorDexBonus,
    int? armorMaxDexBonus,
    String? weaponCategory,
    String? weaponRange,
    String? damageDice,
    String? damageType,
    String? versatileDamageDice,
    List<String>? weaponProperties,
  }) {
    return InventoryItem(
      id: id,
      characterId: characterId,
      itemIndex: itemIndex,
      name: name ?? this.name,
      equipmentCategory: equipmentCategory ?? this.equipmentCategory,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      equipped: equipped ?? this.equipped,
      requiresAttunement: requiresAttunement ?? this.requiresAttunement,
      attuned: attuned ?? this.attuned,
      detailsLoaded: detailsLoaded ?? this.detailsLoaded,
      armorCategory: armorCategory ?? this.armorCategory,
      armorBase: armorBase ?? this.armorBase,
      armorDexBonus: armorDexBonus ?? this.armorDexBonus,
      armorMaxDexBonus: armorMaxDexBonus ?? this.armorMaxDexBonus,
      weaponCategory: weaponCategory ?? this.weaponCategory,
      weaponRange: weaponRange ?? this.weaponRange,
      damageDice: damageDice ?? this.damageDice,
      damageType: damageType ?? this.damageType,
      versatileDamageDice: versatileDamageDice ?? this.versatileDamageDice,
      weaponProperties: weaponProperties ?? this.weaponProperties,
    );
  }
}
