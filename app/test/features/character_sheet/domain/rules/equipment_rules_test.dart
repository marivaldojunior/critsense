import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/coins.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/domain/rules/equipment_rules.dart';

import '../../../../helpers/character_test_helpers.dart';

/// Testa a CA com equipamento, a carga e os ataques com armas.
void main() {
  InventoryItem armor(
    String index, {
    required String category,
    required int base,
    bool dexBonus = false,
    int? maxDex,
    bool equipped = true,
  }) => InventoryItem(
    id: index,
    characterId: 'c1',
    itemIndex: index,
    name: index,
    equipmentCategory: 'Armor',
    armorCategory: category,
    armorBase: base,
    armorDexBonus: dexBonus,
    armorMaxDexBonus: maxDex,
    equipped: equipped,
  );

  InventoryItem weapon(
    String index, {
    required String category,
    String range = 'Melee',
    String dice = '1d8',
    String? versatile,
    List<String> properties = const [],
    bool equipped = true,
  }) => InventoryItem(
    id: index,
    characterId: 'c1',
    itemIndex: index,
    name: index,
    equipmentCategory: 'Weapon',
    weaponCategory: category,
    weaponRange: range,
    damageDice: dice,
    damageType: 'Slashing',
    versatileDamageDice: versatile,
    weaponProperties: properties,
    equipped: equipped,
  );

  final leather = armor(
    'leather-armor',
    category: 'Light',
    base: 11,
    dexBonus: true,
  );
  final chainShirt = armor(
    'chain-shirt',
    category: 'Medium',
    base: 13,
    dexBonus: true,
    maxDex: 2,
  );
  final plate = armor('plate-armor', category: 'Heavy', base: 18);
  final shield = armor('shield', category: 'Shield', base: 2);

  group('CA com equipamento', () {
    // DES 16 (+3).
    final rogue = buildTestCharacter(
      characterClass: 'Rogue',
      attributes: const Attribute(dexterity: 16),
    );

    test('armadura leve soma toda a DES', () {
      expect(armorClassWithEquipment(rogue, [leather]), 14);
    });

    test('armadura média soma até +2 de DES', () {
      expect(armorClassWithEquipment(rogue, [chainShirt]), 15);
    });

    test('armadura pesada não soma DES', () {
      expect(armorClassWithEquipment(rogue, [plate]), 18);
    });

    test('escudo soma +2, e item não equipado não conta', () {
      expect(armorClassWithEquipment(rogue, [plate, shield]), 20);
      expect(
        armorClassWithEquipment(rogue, [
          armor('plate-armor', category: 'Heavy', base: 18, equipped: false),
        ]),
        13, // sem armadura: 10 + 3
      );
    });

    test('o bônus manual de CA soma por cima', () {
      expect(
        armorClassWithEquipment(rogue.copyWith(armorClassBonus: 1), [plate]),
        19,
      );
    });

    test('Bárbaro sem armadura usa a Defesa sem Armadura com escudo', () {
      final barbarian = buildTestCharacter(
        characterClass: 'Barbarian',
        attributes: const Attribute(dexterity: 14, constitution: 16),
      );

      expect(armorClassWithEquipment(barbarian, [shield]), 17); // 10+2+3+2
      expect(armorClassWithEquipment(barbarian, [chainShirt]), 15); // armadura
    });

    test('Monge perde a Defesa sem Armadura usando escudo', () {
      final monk = buildTestCharacter(
        characterClass: 'Monk',
        attributes: const Attribute(dexterity: 16, wisdom: 14),
      );

      expect(armorClassWithEquipment(monk, []), 15); // 10 + 3 + 2
      expect(
        armorClassWithEquipment(monk, [shield]),
        15,
      ); // 10 + 3 + 2 (escudo)
    });
  });

  group('carga', () {
    test('capacidade é FOR × 15', () {
      final strong = buildTestCharacter(
        attributes: const Attribute(strength: 16),
      );
      expect(carryingCapacity(strong), 240);
    });

    test('peso carregado soma itens × quantidade e as moedas', () {
      final rope = InventoryItem(
        id: 'rope',
        characterId: 'c1',
        itemIndex: 'rope',
        name: 'Corda',
        equipmentCategory: 'Gear',
        quantity: 2,
        weight: 10,
      );
      final coins = const Coins().withAmount(Coin.gold, 100);

      expect(carriedWeight([rope, plate.copyWith(weight: 65)], coins), 87);
    });

    test('total das moedas em PO', () {
      final coins = const Coins()
          .withAmount(Coin.platinum, 1)
          .withAmount(Coin.gold, 2)
          .withAmount(Coin.silver, 5);

      expect(coins.totalInGold, 12.5);
      expect(coins.withAmount(Coin.copper, -3).of(Coin.copper), 0);
    });
  });

  group('ataques', () {
    test('arma marcial do Guerreiro usa FOR e soma proficiência', () {
      final fighter = buildTestCharacter(
        level: 1,
        attributes: const Attribute(strength: 16),
      );
      final attack = weaponAttacks(fighter, [
        weapon('longsword', category: 'Martial', versatile: '1d10'),
      ]).first;

      expect(attack.attackBonus, 5); // 3 + 2
      expect(attack.damage, '1d8+3');
      expect(attack.versatileDamage, '1d10+3');
      expect(attack.proficient, isTrue);
      expect(attack.ability, AttributeType.strength);
    });

    test('acuidade usa o maior entre FOR e DES', () {
      final rogue = buildTestCharacter(
        characterClass: 'Rogue',
        level: 1,
        attributes: const Attribute(strength: 10, dexterity: 18),
      );
      final attack = weaponAttacks(rogue, [
        weapon('rapier', category: 'Martial', properties: ['finesse']),
      ]).first;

      // O Ladino é proficiente com rapieira mesmo sem armas marciais.
      expect(attack.attackBonus, 6);
      expect(attack.damage, '1d8+4');
      expect(attack.ability, AttributeType.dexterity);
    });

    test('arma à distância usa DES; sem proficiência não soma o bônus', () {
      final wizard = buildTestCharacter(
        characterClass: 'Wizard',
        level: 1,
        attributes: const Attribute(dexterity: 14),
      );
      final attack = weaponAttacks(wizard, [
        weapon('longbow', category: 'Martial', range: 'Ranged', dice: '1d8'),
      ]).first;

      expect(attack.attackBonus, 2);
      expect(attack.proficient, isFalse);
    });

    test(
      'arma não equipada não aparece; o ataque desarmado sempre aparece',
      () {
        final fighter = buildTestCharacter(
          attributes: const Attribute(strength: 8),
        );
        final attacks = weaponAttacks(fighter, [
          weapon('longsword', category: 'Martial', equipped: false),
        ]);

        expect(attacks.single.name, 'Ataque desarmado');
        expect(attacks.single.damage, '0'); // 1 + FOR -1, nunca negativo
      },
    );
  });

  group('equipar', () {
    test('equipar armadura desequipa a anterior; o escudo continua', () {
      final inventory = [
        chainShirt,
        shield,
        armor('plate-armor', category: 'Heavy', base: 18, equipped: false),
      ];

      final changed = toggleEquipped(inventory[2], inventory);

      expect(changed.map((i) => (i.id, i.equipped)), [
        ('plate-armor', true),
        ('chain-shirt', false),
      ]);
    });

    test('desequipar só muda o próprio item', () {
      expect(toggleEquipped(chainShirt, [chainShirt]).single.equipped, isFalse);
    });
  });
}
