import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/srd/srd_race.dart';

/// Testa as raças do SRD e os bônus raciais da criação.
void main() {
  test('encontra a raça pelo nome da API', () {
    expect(SrdRace.fromName('Half-Elf'), SrdRace.halfElf);
    expect(SrdRace.fromName('half elf'), SrdRace.halfElf);
    expect(SrdRace.fromName('Dwarf'), SrdRace.dwarf);
    expect(SrdRace.fromName('Warforged'), isNull);
  });

  test('bônus fixos e deslocamento', () {
    final dwarf = applyRacialBonuses(const Attribute(), SrdRace.dwarf);

    expect(dwarf.constitution, 10);
    expect(dwarf.strength, 8);
    expect(SrdRace.dwarf.speed, 25);
  });

  test('humano recebe +1 em todos os atributos', () {
    final human = applyRacialBonuses(const Attribute(), SrdRace.human);

    for (final attribute in AttributeType.values) {
      expect(human.valueOf(attribute), 9);
    }
  });

  test('Meio-Elfo: +2 CAR e +1 em dois atributos escolhidos', () {
    final halfElf = applyRacialBonuses(
      const Attribute(),
      SrdRace.halfElf,
      chosen: {AttributeType.dexterity, AttributeType.wisdom},
    );

    expect(halfElf.charisma, 10);
    expect(halfElf.dexterity, 9);
    expect(halfElf.wisdom, 9);
    expect(halfElf.strength, 8);
    expect(
      SrdRace.halfElf.choosableAbilities,
      isNot(contains(AttributeType.charisma)),
    );
  });

  test('a escolha do +1 não soma em atributo com bônus fixo', () {
    final halfElf = applyRacialBonuses(
      const Attribute(),
      SrdRace.halfElf,
      chosen: {AttributeType.charisma},
    );

    expect(halfElf.charisma, 10);
  });

  test('nenhum atributo passa de 20', () {
    final orc = applyRacialBonuses(
      const Attribute(strength: 19),
      SrdRace.halfOrc,
    );

    expect(orc.strength, 20);
  });

  test('raça fora do SRD não muda os atributos', () {
    const base = Attribute(strength: 15);

    expect(identical(applyRacialBonuses(base, null), base), isTrue);
  });
}
