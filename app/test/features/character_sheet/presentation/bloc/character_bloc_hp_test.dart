import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
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

/// Testa as regras de Gerenciamento de Vida (dano/cura/PV temporário/
/// descanso) do [CharacterBloc], conforme o SRD do D&D 5e.
///
/// Sem `bloc_test` (o pacote conflita com o override de `test_api` fixado
/// em `pubspec.yaml` para o `analyzer`) — mesmo padrão de mock via
/// `mocktail` já usado em `character_bloc_skill_math_test.dart`, só que
/// aqui aguardando as emissões via `bloc.stream` diretamente.
void main() {
  late _MockGetAllCharactersUseCase getAllCharacters;
  late _MockSaveCharacterUseCase saveCharacter;
  late CharacterBloc bloc;

  const characterId = 'test-id';

  Character buildCharacter({
    required int maxHitPoints,
    required int currentHitPoints,
    int temporaryHitPoints = 0,
  }) {
    return Character(
      id: characterId,
      name: 'Personagem de Teste',
      race: 'Humano',
      characterClass: 'Guerreiro',
      level: 1,
      armorClass: 10,
      initiative: 0,
      speed: 30,
      maxHitPoints: maxHitPoints,
      currentHitPoints: currentHitPoints,
      temporaryHitPoints: temporaryHitPoints,
      attributes: const Attribute(
        strength: 10,
        dexterity: 10,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10,
      ),
      alignment: '',
      background: '',
      personalityTraits: '',
      ideals: '',
      bonds: '',
      flaws: '',
      experiencePoints: 0,
      proficiencyBonus: 2,
    );
  }

  setUpAll(() {
    registerFallbackValue(buildCharacter(maxHitPoints: 1, currentHitPoints: 1));
  });

  setUp(() {
    getAllCharacters = _MockGetAllCharactersUseCase();
    saveCharacter = _MockSaveCharacterUseCase();
    when(() => saveCharacter(any())).thenAnswer((_) async {});

    bloc = CharacterBloc(
      getAllCharacters,
      saveCharacter,
      _MockDeleteCharacterUseCase(),
      _MockAddInventoryItemUseCase(),
    );
  });

  tearDown(() => bloc.close());

  /// Carrega [character] como único personagem do estado e aguarda o
  /// [CharacterLoaded] resultante, para que `_updateCharacter` (usado por
  /// todo handler de PV) encontre um estado já carregado.
  Future<void> seedLoaded(Character character) async {
    when(() => getAllCharacters()).thenAnswer((_) async => [character]);
    final loaded = bloc.stream.firstWhere((s) => s is CharacterLoaded);
    bloc.add(const LoadCharactersEvent());
    await loaded;
  }

  /// Dispara [event] e aguarda a próxima emissão [CharacterLoaded],
  /// retornando o personagem único resultante.
  Future<Character> actAndGetCharacter(CharacterEvent event) async {
    final next = bloc.stream.firstWhere((s) => s is CharacterLoaded);
    bloc.add(event);
    final state = await next as CharacterLoaded;
    return state.characters.single;
  }

  group('ApplyDamageEvent', () {
    test('dano menor que o PV temporário só reduz o PV temporário', () async {
      await seedLoaded(
        buildCharacter(
          maxHitPoints: 20,
          currentHitPoints: 20,
          temporaryHitPoints: 5,
        ),
      );

      final character = await actAndGetCharacter(
        const ApplyDamageEvent(characterId, 3),
      );

      expect(character.currentHitPoints, 20);
      expect(character.temporaryHitPoints, 2);
    });

    test(
      'dano maior que o PV temporário zera o temporário e desconta o '
      'restante do PV atual',
      () async {
        await seedLoaded(
          buildCharacter(
            maxHitPoints: 20,
            currentHitPoints: 20,
            temporaryHitPoints: 5,
          ),
        );

        final character = await actAndGetCharacter(
          const ApplyDamageEvent(characterId, 8),
        );

        expect(character.currentHitPoints, 17);
        expect(character.temporaryHitPoints, 0);
      },
    );

    test('PV atual nunca fica abaixo de zero', () async {
      await seedLoaded(
        buildCharacter(maxHitPoints: 20, currentHitPoints: 5),
      );

      final character = await actAndGetCharacter(
        const ApplyDamageEvent(characterId, 999),
      );

      expect(character.currentHitPoints, 0);
    });
  });

  group('HealHpEvent', () {
    test('cura aumenta o PV atual sem ultrapassar o máximo', () async {
      await seedLoaded(
        buildCharacter(maxHitPoints: 20, currentHitPoints: 15),
      );

      final character = await actAndGetCharacter(
        const HealHpEvent(characterId, 100),
      );

      expect(character.currentHitPoints, 20);
    });
  });

  group('AddTempHpEvent', () {
    test('um valor maior que o PV temporário atual substitui', () async {
      await seedLoaded(
        buildCharacter(
          maxHitPoints: 20,
          currentHitPoints: 20,
          temporaryHitPoints: 3,
        ),
      );

      final character = await actAndGetCharacter(
        const AddTempHpEvent(characterId, 10),
      );

      expect(character.temporaryHitPoints, 10);
    });

    test(
      'um valor menor ou igual ao PV temporário atual é ignorado (não '
      'acumula)',
      () async {
        await seedLoaded(
          buildCharacter(
            maxHitPoints: 20,
            currentHitPoints: 20,
            temporaryHitPoints: 10,
          ),
        );
        final stateBefore = bloc.state;

        bloc.add(const AddTempHpEvent(characterId, 10));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state, same(stateBefore));
        verifyNever(() => saveCharacter(any()));
      },
    );
  });

  group('TakeLongRestEvent', () {
    test('restaura o PV atual ao máximo e zera o PV temporário', () async {
      await seedLoaded(
        buildCharacter(
          maxHitPoints: 20,
          currentHitPoints: 1,
          temporaryHitPoints: 4,
        ),
      );

      final character = await actAndGetCharacter(
        const TakeLongRestEvent(characterId),
      );

      expect(character.currentHitPoints, 20);
      expect(character.temporaryHitPoints, 0);
    });
  });

  group('TakeShortRestEvent', () {
    test(
      'não altera PV automaticamente (sem sistema de Dados de Vida)',
      () async {
        await seedLoaded(
          buildCharacter(maxHitPoints: 20, currentHitPoints: 1),
        );
        final stateBefore = bloc.state;

        bloc.add(const TakeShortRestEvent(characterId));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state, same(stateBefore));
        verifyNever(() => saveCharacter(any()));
      },
    );
  });
}
