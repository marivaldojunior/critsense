import 'package:equatable/equatable.dart';

import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';

/// Classe base selada para todos os estados do [DiceBloc].
///
/// **Por que [Equatable] é fundamental nos Estados?**
///
/// O `flutter_bloc` só reconstrói widgets (`BlocBuilder`) quando o estado
/// **muda**. Para determinar mudança, ele usa `==`. Sem [Equatable], `==`
/// compara referências de memória, e dois estados idênticos como
/// `DiceRolling() == DiceRolling()` retornam `false` (objetos distintos),
/// forçando um rebuild desnecessário a cada emissão.
///
/// [Equatable] gera `==` e `hashCode` baseados nos campos listados em
/// [props], tornando a comparação **por valor**. Isso garante que o Flutter
/// só redesenhe a tela quando o conteúdo do estado realmente diferir —
/// equivalente ao `IEquatable<T>` do C# ou `equals()` do Java com
/// campos explicitamente listados.
abstract class DiceState extends Equatable {
  const DiceState();
}

/// Estado inicial: nenhum dado foi lançado ainda nesta sessão.
///
/// Emitido uma única vez, ao criar o BLoC. Serve como estado neutro
/// para que a UI possa renderizar uma tela de "aguardando ação".
class DiceInitial extends DiceState {
  const DiceInitial();

  @override
  List<Object?> get props => [];
}

/// Estado transitório: o dado está sendo "lançado" (animação em progresso).
///
/// A UI deve exibir uma animação de rolagem enquanto este estado estiver
/// ativo. Não carrega dados porque o resultado ainda não é conhecido.
class DiceRolling extends DiceState {
  const DiceRolling();

  // Lista vazia: dois estados `DiceRolling` são sempre iguais.
  // O BLoC não emitirá um segundo `DiceRolling` consecutivo graças a isso.
  @override
  List<Object?> get props => [];
}

/// Estado final: o dado foi lançado e o resultado está disponível.
///
/// Carrega a entidade [DiceResult] com o valor e os flags de crítico.
/// A UI deve ler [result] para exibir o número e reagir visualmente
/// a [DiceResult.isCriticalSuccess] ou [DiceResult.isCriticalFailure].
class DiceRolled extends DiceState {
  /// O resultado completo do lançamento, incluindo flags de crítico.
  final DiceResult result;

  const DiceRolled(this.result);

  // `result` em `props` garante que dois `DiceRolled` com valores
  // distintos sejam considerados estados diferentes, acionando rebuild.
  // Se o mesmo número sair duas vezes seguidas, `DiceResult.==` (que
  // compara `value`) os tornará iguais e o BLoC suprimirá o segundo emit.
  @override
  List<Object?> get props => [result];
}
