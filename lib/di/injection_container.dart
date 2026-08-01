import 'package:get_it/get_it.dart';

import 'package:crit_sense/features/dice_roller/data/datasources/sensor_datasource.dart';
import 'package:crit_sense/features/dice_roller/data/repositories/dice_repository_impl.dart';
import 'package:crit_sense/features/dice_roller/domain/repositories/i_dice_repository.dart';
import 'package:crit_sense/features/dice_roller/domain/usecases/roll_dice_usecase.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_bloc.dart';

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
  // ─── Camada de Apresentação ────────────────────────────────────────────────
  //
  // `registerFactory`: cria uma **nova instância** a cada `sl<DiceBloc>()`.
  //
  // BLoCs gerenciam estado de UI atrelado a um subárvore de widgets. Se fossem
  // singletons, dois `BlocProvider<DiceBloc>` em telas diferentes
  // compartilhariam o mesmo estado — causando bugs difíceis de rastrear.
  // O ciclo de vida do BLoC (criação + dispose) deve espelhar o ciclo de vida
  // do widget que o consome: Factory garante isso.
  //
  // Paralelo arquitetural: Factory ≈ `Transient` no .NET DI (nova instância
  // por solicitação); Singleton ≈ `Singleton` (instância única global).
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
