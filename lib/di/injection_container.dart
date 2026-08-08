import 'package:get_it/get_it.dart';

import 'package:crit_sense/core/database/app_database.dart';
import 'package:crit_sense/features/character_sheet/data/repositories/character_repository_impl.dart';
import 'package:crit_sense/features/character_sheet/domain/repositories/i_character_repository.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_inventory_item_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/add_session_note_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_character_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/delete_session_note_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_all_characters_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_character_inventory_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/get_session_notes_usecase.dart';
import 'package:crit_sense/features/character_sheet/domain/usecases/save_character_use_case.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/form_options_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/point_buy_cubit.dart';
import 'package:crit_sense/features/dice_roller/data/datasources/sensor_datasource.dart';
import 'package:crit_sense/features/dice_roller/data/repositories/dice_repository_impl.dart';
import 'package:crit_sense/features/dice_roller/domain/repositories/i_dice_repository.dart';
import 'package:crit_sense/features/dice_roller/domain/usecases/roll_dice_usecase.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_bloc.dart';
import 'package:crit_sense/features/compendium/data/datasources/compendium_remote_datasource.dart';
import 'package:crit_sense/features/compendium/data/repositories/compendium_repository_impl.dart';
import 'package:crit_sense/features/compendium/domain/repositories/i_compendium_repository.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_classes_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_equipment_detail_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_equipments_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_monsters_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_races_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_spell_detail_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_spells_usecase.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/compendium_bloc.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/equipment_bloc.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/equipment_detail_bloc.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/monster_bloc.dart';
import 'package:crit_sense/features/compendium/presentation/bloc/spell_detail_bloc.dart';
import 'package:dio/dio.dart';

/// Instância global do service locator.
///
/// `GetIt.instance` é um singleton interno ao pacote — garante que
/// todos os módulos do app compartilhem o mesmo registro de dependências.
/// A variável `sl` (service locator) é a convenção amplamente adotada
/// na comunidade Flutter para acesso rápido sem necessidade de imports extras.
// ignore: non_constant_identifier_names — `sl` é convenção estabelecida.
final sl = GetIt.instance;

/// Registra todas as dependências do app no service locator.
///
/// Deve ser chamada **uma única vez**, em `main()`, antes de `runApp()`,
/// garantindo que todas as instâncias estejam disponíveis quando a UI
/// iniciar e solicitar suas dependências.
///
/// A ordem de registro segue a hierarquia de dependências de **dentro para fora**:
/// DataSources → Repositories → Use Cases → BLoCs. Isso não é estritamente
/// necessário para `LazySingleton` (resolvidos sob demanda), mas torna o
/// arquivo legível como um grafo de dependências de baixo para cima.
Future<void> init() async {
  // ─── Infraestrutura ────────────────────────────────────────────────────────
  //
  // `AppDatabase` é registrado como `LazySingleton` — única instância global.
  // O SQLite aplica um lock exclusivo no arquivo `.sqlite` enquanto está aberto:
  // múltiplas instâncias de `AppDatabase` tentariam abrir o mesmo arquivo ao
  // mesmo tempo, resultando em erros de "database is locked". Singleton garante
  // que apenas uma conexão exista durante todo o ciclo de vida do app.
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(AppDatabase.openConnection()),
  );

  // ─── Feature: character_sheet ──────────────────────────────────────────────

  // Apresentação — Factory: cada tela que consuma CharacterBloc recebe sua
  // própria instância, isolando estado entre rotas distintas.
  sl.registerFactory<CharacterBloc>(
    () => CharacterBloc(
      sl<GetAllCharactersUseCase>(),
      sl<SaveCharacterUseCase>(),
      sl<DeleteCharacterUseCase>(),
      sl<AddInventoryItemUseCase>(),
    ),
  );

  // Factory: nova instância por tela, assim os pontos alocados de uma
  // criação de personagem não vazam para a próxima.
  sl.registerFactory<PointBuyCubit>(() => PointBuyCubit());

  // Factory: nova instância por tela, assim o estado de carregamento é limpo
  // a cada abertura do formulário.
  sl.registerFactory<FormOptionsBloc>(
    () => FormOptionsBloc(sl<GetClassesUseCase>(), sl<GetRacesUseCase>()),
  );

  // Domínio — Use Cases stateless compartilhados com segurança como singletons.
  sl.registerLazySingleton<GetAllCharactersUseCase>(
    () => GetAllCharactersUseCase(sl<ICharacterRepository>()),
  );
  sl.registerLazySingleton<SaveCharacterUseCase>(
    () => SaveCharacterUseCase(sl<ICharacterRepository>()),
  );
  sl.registerLazySingleton<DeleteCharacterUseCase>(
    () => DeleteCharacterUseCase(sl<ICharacterRepository>()),
  );
  sl.registerLazySingleton<AddInventoryItemUseCase>(
    () => AddInventoryItemUseCase(sl<ICharacterRepository>()),
  );
  sl.registerLazySingleton<GetCharacterInventoryUseCase>(
    () => GetCharacterInventoryUseCase(sl<ICharacterRepository>()),
  );
  sl.registerLazySingleton<GetSessionNotesUseCase>(
    () => GetSessionNotesUseCase(sl<ICharacterRepository>()),
  );
  sl.registerLazySingleton<AddSessionNoteUseCase>(
    () => AddSessionNoteUseCase(sl<ICharacterRepository>()),
  );
  sl.registerLazySingleton<DeleteSessionNoteUseCase>(
    () => DeleteSessionNoteUseCase(sl<ICharacterRepository>()),
  );

  // Dados — Implementação concreta amarrada à interface do domínio.
  sl.registerLazySingleton<ICharacterRepository>(
    () => CharacterRepositoryImpl(sl<AppDatabase>()),
  );

  // ─── Feature: compendium ──────────────────────────────────────────────────────────

  // Dio como LazySingleton reutiliza o pool de conexões HTTP internamente.
  // No .NET, instanciar `new HttpClient()` a cada requisição esgota os sockets
  // disponíveis do SO (socket exhaustion) porque o TCP TIME_WAIT mantém a
  // porta ocupada por até 240s após o fechamento. O mesmo risco existe no Dart:
  // um único Dio singleton centraliza e reutiliza as conexões abertas.
  sl.registerLazySingleton<Dio>(() => Dio());

  // Factory: cada tela recebe um BLoC zerado, evitando estado compartilhado.
  sl.registerFactory<CompendiumBloc>(
    () => CompendiumBloc(sl<GetSpellsUseCase>()),
  );
  sl.registerFactory<SpellDetailBloc>(
    () => SpellDetailBloc(sl<GetSpellDetailUseCase>()),
  );
  sl.registerFactory<EquipmentBloc>(
    () => EquipmentBloc(sl<GetEquipmentsUseCase>()),
  );
  sl.registerFactory<EquipmentDetailBloc>(
    () => EquipmentDetailBloc(sl<GetEquipmentDetailUseCase>()),
  );
  sl.registerFactory<MonsterBloc>(() => MonsterBloc(sl<GetMonstersUseCase>()));
  sl.registerLazySingleton<GetSpellsUseCase>(
    () => GetSpellsUseCase(sl<ICompendiumRepository>()),
  );
  sl.registerLazySingleton<GetSpellDetailUseCase>(
    () => GetSpellDetailUseCase(sl<ICompendiumRepository>()),
  );
  sl.registerLazySingleton<GetEquipmentsUseCase>(
    () => GetEquipmentsUseCase(sl<ICompendiumRepository>()),
  );
  sl.registerLazySingleton<GetEquipmentDetailUseCase>(
    () => GetEquipmentDetailUseCase(sl<ICompendiumRepository>()),
  );
  sl.registerLazySingleton<GetMonstersUseCase>(
    () => GetMonstersUseCase(sl<ICompendiumRepository>()),
  );
  sl.registerLazySingleton<GetClassesUseCase>(
    () => GetClassesUseCase(sl<ICompendiumRepository>()),
  );
  sl.registerLazySingleton<GetRacesUseCase>(
    () => GetRacesUseCase(sl<ICompendiumRepository>()),
  );
  sl.registerLazySingleton<ICompendiumRepository>(
    () => CompendiumRepositoryImpl(sl<ICompendiumRemoteDataSource>()),
  );
  sl.registerLazySingleton<ICompendiumRemoteDataSource>(
    () => CompendiumRemoteDataSourceImpl(sl<Dio>()),
  );

  // ─── Feature: dice_roller ──────────────────────────────────────────────────
  //
  // `registerFactory`: cria uma **nova instância** a cada `sl<DiceBloc>()`.
  //
  // BLoCs gerenciam estado de UI atrelado a um subárvore de widgets. Se fossem
  // singletons, dois `BlocProvider<DiceBloc>` em telas diferentes
  // compartilhariam o mesmo estado — causando bugs difíceis de rastrear.
  // O ciclo de vida do BLoC (criação + dispose) deve espelhar o ciclo de vida
  // do widget que o consome: Factory garante isso.
  sl.registerFactory<DiceBloc>(() => DiceBloc(sl<RollDiceUseCase>()));

  // ─── Camada de Domínio (Use Cases) ────────────────────────────────────────
  //
  // `registerLazySingleton`: cria a instância **na primeira** `sl()` e
  // reutiliza a mesma para todas as chamadas subsequentes.
  //
  // Use Cases são stateless por design (não guardam dados entre chamadas),
  // portanto uma única instância partilhada é segura e economiza memória.
  // `Lazy` significa que a instância só é criada quando realmente necessária —
  // se uma feature nunca for aberta, seu Use Case nunca será instanciado.
  sl.registerLazySingleton<RollDiceUseCase>(
    () => RollDiceUseCase(sl<IDiceRepository>()),
  );

  // ─── Camada de Domínio (Repositórios — contratos) ─────────────────────────
  //
  // Registramos a **interface** `IDiceRepository` amarrada à implementação
  // `DiceRepositoryImpl`. Quem solicitar `sl<IDiceRepository>()` receberá
  // um `DiceRepositoryImpl`, mas nunca saberá disso — apenas conhecerá o contrato.
  // Para trocar a implementação (ex: repositório remoto), basta mudar esta linha.
  sl.registerLazySingleton<IDiceRepository>(
    () => DiceRepositoryImpl(sl<ISensorDataSource>()),
  );

  // ─── Camada de Dados (Data Sources) ───────────────────────────────────────
  //
  // `SensorDataSourceImpl` é `const` (sem estado mutável), tornando-o
  // naturalmente thread-safe e ideal para singleton.
  // Registramos pela interface `ISensorDataSource` pelo mesmo motivo
  // arquitetural dos repositórios: isolamento da implementação concreta.
  sl.registerLazySingleton<ISensorDataSource>(
    () => const SensorDataSourceImpl(),
  );
}
