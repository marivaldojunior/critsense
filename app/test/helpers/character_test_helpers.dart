import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_character_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_all_characters_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/save_character_use_case.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';

class MockGetAllCharactersUseCase extends Mock
    implements GetAllCharactersUseCase {}

class MockSaveCharacterUseCase extends Mock implements SaveCharacterUseCase {}

class MockDeleteCharacterUseCase extends Mock
    implements DeleteCharacterUseCase {}

class MockAddInventoryItemUseCase extends Mock
    implements AddInventoryItemUseCase {}

/// Personagem de teste: Guerreiro nível 4, CON 14 e DES 14, 30 PV máximos.
Character buildTestCharacter({
  String id = 'c1',
  String characterClass = 'Fighter',
  int level = 4,
  int maxHitPoints = 30,
  int currentHitPoints = 30,
  List<Condition> conditions = const [],
  int exhaustionLevel = 0,
  Attribute attributes = const Attribute(constitution: 14, dexterity: 14),
}) {
  return Character(
    id: id,
    name: 'Thorin',
    race: 'Dwarf',
    characterClass: characterClass,
    level: level,
    speed: 25,
    maxHitPoints: maxHitPoints,
    currentHitPoints: currentHitPoints,
    temporaryHitPoints: 0,
    conditions: conditions,
    exhaustionLevel: exhaustionLevel,
    attributes: attributes,
    alignment: '',
    background: '',
    personalityTraits: '',
    ideals: '',
    bonds: '',
    flaws: '',
    experiencePoints: 0,
  );
}

/// [CharacterBloc] com use cases falsos, já carregado com [characters]. O
/// [saveCharacter] devolvido permite conferir o que foi salvo.
Future<({CharacterBloc bloc, MockSaveCharacterUseCase saveCharacter})>
loadedCharacterBloc(List<Character> characters) async {
  registerFallbackValue(buildTestCharacter());
  final getAll = MockGetAllCharactersUseCase();
  final save = MockSaveCharacterUseCase();
  when(() => getAll()).thenAnswer((_) async => characters);
  when(() => save(any())).thenAnswer((_) async {});

  final bloc = CharacterBloc(
    getAll,
    save,
    MockDeleteCharacterUseCase(),
    MockAddInventoryItemUseCase(),
  );
  final loaded = bloc.stream.firstWhere((s) => s is CharacterLoaded);
  bloc.add(const LoadCharactersEvent());
  await loaded;
  return (bloc: bloc, saveCharacter: save);
}
