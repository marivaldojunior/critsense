import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/proficiency.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/skill.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_character_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_all_characters_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/save_character_use_case.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';

class _MockGetAllCharactersUseCase extends Mock
    implements GetAllCharactersUseCase {}

class _MockSaveCharacterUseCase extends Mock implements SaveCharacterUseCase {}

class _MockDeleteCharacterUseCase extends Mock
    implements DeleteCharacterUseCase {}

class _MockAddInventoryItemUseCase extends Mock
    implements AddInventoryItemUseCase {}

/// Testa apenas os métodos puros de cálculo da ficha (perícias, testes de
/// resistência e sabedoria passiva) do [CharacterBloc]. Os use cases são
/// mockados só para satisfazer o construtor — nenhum deles é chamado ou
/// stubado, já que esses métodos não disparam eventos nem leem [state].
void main() {
  late CharacterBloc bloc;

  setUp(() {
    bloc = CharacterBloc(
      _MockGetAllCharactersUseCase(),
      _MockSaveCharacterUseCase(),
      _MockDeleteCharacterUseCase(),
      _MockAddInventoryItemUseCase(),
    );
  });

  tearDown(() => bloc.close());

  /// Personagem base: DEX 14 (mod +2), WIS 12 (mod +1), FOR 7 (mod -2),
  /// bônus de proficiência +2 e nenhuma proficiência marcada por padrão.
  Character buildCharacter({
    List<Proficiency> proficiencies = const [],
    int proficiencyBonus = 2,
  }) {
    return Character(
      id: 'test-id',
      name: 'Personagem de Teste',
      race: 'Humano',
      characterClass: 'Guerreiro',
      level: 1,
      armorClass: 10,
      initiative: 0,
      speed: 30,
      maxHitPoints: 10,
      currentHitPoints: 10,
      temporaryHitPoints: 0,
      attributes: const Attribute(
        strength: 7,
        dexterity: 14,
        constitution: 10,
        intelligence: 10,
        wisdom: 12,
        charisma: 8,
      ),
      alignment: '',
      background: '',
      personalityTraits: '',
      ideals: '',
      bonds: '',
      flaws: '',
      experiencePoints: 0,
      proficiencyBonus: proficiencyBonus,
      proficiencies: proficiencies,
    );
  }

  group('skillModifier', () {
    test('sem proficiência retorna apenas o modificador do atributo', () {
      final character = buildCharacter();
      expect(bloc.skillModifier(character, Skill.stealth), 2); // DEX +2
    });

    test('com proficiência soma o bônus de proficiência (exemplo do enunciado)', () {
      final character = buildCharacter(
        proficiencies: const [SkillProficiency(Skill.stealth)],
      );
      // Furtividade (DEX +2) + Bônus de Proficiência (+2) = +4.
      expect(bloc.skillModifier(character, Skill.stealth), 4);
    });

    test('proficiência em outra perícia não afeta a perícia consultada', () {
      final character = buildCharacter(
        proficiencies: const [SkillProficiency(Skill.arcana)],
      );
      expect(bloc.skillModifier(character, Skill.stealth), 2);
    });

    test('acompanha o proficiencyBonus do personagem, não um valor fixo', () {
      final character = buildCharacter(
        proficiencies: const [SkillProficiency(Skill.stealth)],
        proficiencyBonus: 3,
      );
      expect(bloc.skillModifier(character, Skill.stealth), 5); // 2 + 3
    });

    test('atributo abaixo de 10 gera modificador negativo na perícia', () {
      final withoutProficiency = buildCharacter();
      expect(
        bloc.skillModifier(withoutProficiency, Skill.athletics),
        -2,
      ); // FOR 7 -> mod -2

      final withProficiency = buildCharacter(
        proficiencies: const [SkillProficiency(Skill.athletics)],
      );
      expect(bloc.skillModifier(withProficiency, Skill.athletics), 0); // -2 + 2
    });
  });

  group('savingThrowModifier', () {
    test('sem proficiência retorna apenas o modificador do atributo', () {
      final character = buildCharacter();
      expect(
        bloc.savingThrowModifier(character, AttributeType.wisdom),
        1,
      ); // WIS +1
    });

    test('com proficiência soma o bônus de proficiência', () {
      final character = buildCharacter(
        proficiencies: const [SavingThrowProficiency(AttributeType.wisdom)],
      );
      expect(
        bloc.savingThrowModifier(character, AttributeType.wisdom),
        3,
      ); // 1 + 2
    });

    test(
      'proficiência em perícia não confere proficiência no teste de '
      'resistência do mesmo atributo',
      () {
        // Percepção é regida por Sabedoria, mas é uma proficiência distinta
        // do Teste de Resistência de Sabedoria.
        final character = buildCharacter(
          proficiencies: const [SkillProficiency(Skill.perception)],
        );
        expect(bloc.savingThrowModifier(character, AttributeType.wisdom), 1);
      },
    );
  });

  group('passiveWisdom', () {
    test('sem proficiência em Percepção: 10 + mod. Sabedoria', () {
      final character = buildCharacter();
      expect(bloc.passiveWisdom(character), 11); // 10 + 1
    });

    test('com proficiência em Percepção soma também o bônus de proficiência', () {
      final character = buildCharacter(
        proficiencies: const [SkillProficiency(Skill.perception)],
      );
      expect(bloc.passiveWisdom(character), 13); // 10 + 1 + 2
    });
  });
}
