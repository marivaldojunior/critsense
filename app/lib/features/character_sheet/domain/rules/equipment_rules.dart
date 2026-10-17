import 'dart:math';

import '../entities/attribute_type.dart';
import '../entities/character.dart';
import '../entities/coins.dart';
import '../entities/inventory_item.dart';
import '../srd/srd_class.dart';
import 'srd_rules.dart';

/// Regras de equipamento do SRD 5.1: CA com armadura e escudo, carga,
/// sintonia e ataques com armas. Funções puras, sem estado.

/// Itens sintonizados ao mesmo tempo, no máximo.
const maxAttunedItems = 3;

/// CA do [character] com os itens equipados de [inventory]:
///
/// - armadura leve: base + DES;
/// - armadura média: base + DES (até +2);
/// - armadura pesada: só a base;
/// - sem armadura: 10 + DES, com a Defesa sem Armadura do Bárbaro (+CON) e
///   do Monge (+SAB, só sem escudo);
/// - escudo equipado: +2;
/// - mais o bônus manual de CA do personagem.
int armorClassWithEquipment(Character character, List<InventoryItem> inventory) {
  final equipped = inventory.where((i) => i.equipped);
  final bodyArmor = equipped.where((i) => i.isBodyArmor).firstOrNull;
  final shield = equipped.where((i) => i.isShield).firstOrNull;
  final dex = character.modifierOf(AttributeType.dexterity);

  final int base;
  if (bodyArmor != null) {
    final maxDex = bodyArmor.armorMaxDexBonus;
    final dexPart = !bodyArmor.armorDexBonus
        ? 0
        : maxDex == null
        ? dex
        : min(dex, maxDex);
    base = (bodyArmor.armorBase ?? 10) + dexPart;
  } else {
    final srdClass = character.srdClass;
    base = unarmoredArmorClass(
      // O Monge perde a Defesa sem Armadura usando escudo.
      srdClass: srdClass == SrdClass.monk && shield != null ? null : srdClass,
      dexterityModifier: dex,
      constitutionModifier: character.modifierOf(AttributeType.constitution),
      wisdomModifier: character.modifierOf(AttributeType.wisdom),
    );
  }
  final shieldBonus = shield == null ? 0 : (shield.armorBase ?? 2);
  return base + shieldBonus + character.armorClassBonus;
}

/// Peso que o personagem aguenta carregar: FOR × 15 libras.
int carryingCapacity(Character character) =>
    character.attributes.strength * 15;

/// Peso carregado: os itens e as moedas (50 moedas = 1 libra).
double carriedWeight(List<InventoryItem> inventory, Coins coins) =>
    inventory.fold<double>(0, (sum, item) => sum + item.totalWeight) +
    coins.weight;

/// Itens sintonizados.
int attunedCount(List<InventoryItem> inventory) =>
    inventory.where((i) => i.attuned).length;

/// Um ataque pronto para a ficha.
class WeaponAttack {
  final String name;

  /// Bônus da rolagem de ataque (d20 + este valor).
  final int attackBonus;

  /// Dano, ex: `1d8+3`.
  final String damage;

  /// Dano usando as duas mãos (armas versáteis).
  final String? versatileDamage;

  final String damageType;

  /// O personagem é proficiente com a arma (soma o bônus de proficiência).
  final bool proficient;

  /// Atributo usado no ataque e no dano.
  final AttributeType ability;

  const WeaponAttack({
    required this.name,
    required this.attackBonus,
    required this.damage,
    required this.damageType,
    required this.proficient,
    required this.ability,
    this.versatileDamage,
  });
}

String _withModifier(String dice, int modifier) {
  if (modifier == 0) return dice;
  return modifier > 0 ? '$dice+$modifier' : '$dice$modifier';
}

/// Ataques das armas equipadas de [inventory], mais o ataque desarmado.
///
/// Armas de acuidade usam o maior entre FOR e DES; armas à distância usam
/// DES; as outras usam FOR. A proficiência vem da classe do SRD.
List<WeaponAttack> weaponAttacks(
  Character character,
  List<InventoryItem> inventory,
) {
  final str = character.modifierOf(AttributeType.strength);
  final dex = character.modifierOf(AttributeType.dexterity);
  final attacks = <WeaponAttack>[];

  for (final weapon in inventory.where((i) => i.equipped && i.isWeapon)) {
    final AttributeType ability;
    if (weapon.hasProperty('finesse')) {
      ability = dex > str ? AttributeType.dexterity : AttributeType.strength;
    } else if (weapon.weaponRange?.toLowerCase() == 'ranged') {
      ability = AttributeType.dexterity;
    } else {
      ability = AttributeType.strength;
    }
    final modifier = character.modifierOf(ability);
    final proficient =
        character.srdClass?.isProficientWithWeapon(
          weapon.itemIndex,
          weapon.weaponCategory,
        ) ??
        false;
    attacks.add(
      WeaponAttack(
        name: weapon.name,
        attackBonus: modifier + (proficient ? character.proficiencyBonus : 0),
        damage: _withModifier(weapon.damageDice!, modifier),
        versatileDamage: weapon.versatileDamageDice == null
            ? null
            : _withModifier(weapon.versatileDamageDice!, modifier),
        damageType: weapon.damageType ?? '',
        proficient: proficient,
        ability: ability,
      ),
    );
  }

  // Ataque desarmado: todo personagem é proficiente; dano 1 + FOR.
  final unarmedDamage = 1 + str;
  attacks.add(
    WeaponAttack(
      name: 'Ataque desarmado',
      attackBonus: str + character.proficiencyBonus,
      damage: '${unarmedDamage < 0 ? 0 : unarmedDamage}',
      damageType: 'Bludgeoning',
      proficient: true,
      ability: AttributeType.strength,
    ),
  );
  return attacks;
}

/// Equipa ou desequipa [item]. Ao equipar uma armadura de corpo, a armadura
/// equipada antes é desequipada; o mesmo vale para o escudo. Devolve todos
/// os itens que mudaram.
List<InventoryItem> toggleEquipped(
  InventoryItem item,
  List<InventoryItem> inventory,
) {
  if (item.equipped) return [item.copyWith(equipped: false)];
  final replaced = inventory.where(
    (other) =>
        other.id != item.id &&
        other.equipped &&
        ((item.isBodyArmor && other.isBodyArmor) ||
            (item.isShield && other.isShield)),
  );
  return [
    item.copyWith(equipped: true),
    for (final other in replaced) other.copyWith(equipped: false),
  ];
}
