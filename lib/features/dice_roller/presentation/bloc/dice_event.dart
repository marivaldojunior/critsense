import 'package:equatable/equatable.dart';

/// Classe base selada para todos os eventos do [DiceBloc].
///
/// Estender [Equatable] nos eventos permite que o BLoC (e os testes)
/// comparem dois eventos por **valor** e não por **referência de memória**.
/// Sem isso, `DiceRollRequested() == DiceRollRequested()` seria `false`,
/// pois seriam objetos diferentes — o mesmo problema que `==` de `Object`.
abstract class DiceEvent extends Equatable {
  const DiceEvent();
}

/// Evento disparado quando o usuário solicita um lançamento manual do dado.
///
/// Não carrega payload: a intenção ("rolar") é toda a informação necessária.
/// O resultado será computado pelo Use Case dentro do BLoC.
class DiceRollRequested extends DiceEvent {
  const DiceRollRequested();

  // Lista vazia: sem campos a comparar. Dois `DiceRollRequested` são
  // sempre iguais — o que é correto, pois representam a mesma intenção.
  @override
  List<Object?> get props => [];
}

/// Evento disparado quando o sensor nativo detecta um shake no dispositivo.
///
/// Separar `DiceShakeDetected` de `DiceRollRequested` segue o princípio
/// de **causa ≠ ação**: a origem do gesto (shake físico) é diferente da
/// ação de negócio (rolar o dado), mesmo que a resposta seja a mesma.
/// Isso facilita adicionar lógica específica para cada gatilho no futuro
/// (ex: animações diferentes, analytics distintos).
class DiceShakeDetected extends DiceEvent {
  const DiceShakeDetected();

  @override
  List<Object?> get props => [];
}
