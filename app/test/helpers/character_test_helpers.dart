import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/character.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/condition.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/inventory_item.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_character_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_all_characters_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_character_inventory_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/save_character_spell_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/save_character_use_case.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/inventory_bloc.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_equipment_detail_usecase.dart';

class MockGetAllCharactersUseCase extends Mock
    implements GetAllCharactersUseCase {}

class MockSaveCharacterUseCase extends Mock implements SaveCharacterUseCase {}

class MockDeleteCharacterUseCase extends Mock
    implements DeleteCharacterUseCase {}

class MockAddInventoryItemUseCase extends Mock
    implements AddInventoryItemUseCase {}

class MockSaveCharacterSpellUseCase extends Mock
    implements SaveCharacterSpellUseCase {}

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
    MockSaveCharacterSpellUseCase(),
  );
  final loaded = bloc.stream.firstWhere((s) => s is CharacterLoaded);
  bloc.add(const LoadCharactersEvent());
  await loaded;
  return (bloc: bloc, saveCharacter: save);
}

class MockGetCharacterInventoryUseCase extends Mock
    implements GetCharacterInventoryUseCase {}

class MockDeleteInventoryItemUseCase extends Mock
    implements DeleteInventoryItemUseCase {}

class MockGetEquipmentDetailUseCase extends Mock
    implements GetEquipmentDetailUseCase {}

/// [InventoryBloc] com use cases falsos, já carregado com [items]. Salvar um
/// item atualiza a lista devolvida nas próximas cargas.
Future<InventoryBloc> loadedInventoryBloc(
  List<InventoryItem> items, {
  String characterId = 'c1',
}) async {
  registerFallbackValue(
    const InventoryItem(
      id: 'fallback',
      characterId: 'c1',
      itemIndex: 'fallback',
      name: 'fallback',
      equipmentCategory: '',
    ),
  );
  final current = [...items];
  final getInventory = MockGetCharacterInventoryUseCase();
  final save = MockAddInventoryItemUseCase();
  when(() => getInventory(characterId)).thenAnswer((_) async => [...current]);
  when(() => save(any())).thenAnswer((invocation) async {
    final item = invocation.positionalArguments.single as InventoryItem;
    final index = current.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      current.add(item);
    } else {
      current[index] = item;
    }
  });

  final bloc = InventoryBloc(
    getInventory,
    MockDeleteInventoryItemUseCase(),
    save,
    MockGetEquipmentDetailUseCase(),
  );
  final loaded = bloc.stream.firstWhere(
    (s) => s.status == InventoryStatus.success,
  );
  bloc.add(LoadInventoryEvent(characterId));
  await loaded;
  return bloc;
}
