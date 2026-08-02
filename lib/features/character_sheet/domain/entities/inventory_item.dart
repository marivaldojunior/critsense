/// Item do inventário de um personagem.
class InventoryItem {
  /// Identificador único do item (UUID gerado no domínio).
  final String id;

  /// Identificador do personagem dono do item.
  final String characterId;

  /// Identificador do item na API do D&D 5e (ex: "longsword").
  final String itemIndex;

  /// Nome legível do item.
  final String name;

  /// Categoria do equipamento (ex: "Weapon", "Armor").
  final String equipmentCategory;

  const InventoryItem({
    required this.id,
    required this.characterId,
    required this.itemIndex,
    required this.name,
    required this.equipmentCategory,
  });
}
