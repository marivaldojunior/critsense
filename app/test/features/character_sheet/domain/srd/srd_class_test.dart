import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/srd/srd_class.dart';

/// Testa os dados das classes do SRD usados na criação.
void main() {
  test('encontra a classe pelo nome da API', () {
    expect(SrdClass.fromName('Fighter'), SrdClass.fighter);
    expect(SrdClass.fromName(' wizard '), SrdClass.wizard);
    expect(SrdClass.fromName('Artificer'), isNull);
  });

  test('cada classe tem dois testes de resistência', () {
    for (final srdClass in SrdClass.values) {
      expect(srdClass.savingThrows, hasLength(2), reason: srdClass.name);
    }
    expect(SrdClass.rogue.savingThrows, {
      AttributeType.dexterity,
      AttributeType.intelligence,
    });
  });

  test('proficiências de equipamento com nomes em português', () {
    expect(defaultEquipmentProficiencies(SrdClass.fighter), [
      'Armaduras leves',
      'Armaduras médias',
      'Armaduras pesadas',
      'Escudos',
      'Armas simples',
      'Armas marciais',
    ]);
    expect(defaultEquipmentProficiencies(SrdClass.rogue), [
      'Armaduras leves',
      'Armas simples',
      'Besta de mão',
      'Espada longa',
      'Rapieira',
      'Espada curta',
    ]);
    expect(defaultEquipmentProficiencies(SrdClass.wizard), contains('Bordão'));
    expect(defaultEquipmentProficiencies(null), isEmpty);
  });

  test('proficiência com arma pela categoria ou pela arma específica', () {
    expect(SrdClass.rogue.isProficientWithWeapon('rapier', 'Martial'), isTrue);
    expect(
      SrdClass.rogue.isProficientWithWeapon('greataxe', 'Martial'),
      isFalse,
    );
    expect(SrdClass.wizard.isProficientWithWeapon('dagger', 'Simple'), isTrue);
    expect(SrdClass.wizard.isProficientWithWeapon('mace', 'Simple'), isFalse);
    expect(
      SrdClass.fighter.isProficientWithWeapon('greataxe', 'Martial'),
      isTrue,
    );
  });
}
