import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/dice_roller/domain/usecases/roll_dice_usecase.dart';
import 'dice_event.dart';
import 'dice_state.dart';

/// BLoC responsável por gerenciar o ciclo de vida de um lançamento de dado.
///
/// **Fluxo de estados:**
/// ```
/// DiceInitial
///     │
///     ├─ DiceRollRequested ──► DiceRolling ──► DiceRolled
///     └─ DiceShakeDetected ──► (re-enfileira DiceRollRequested)
/// ```
///
/// O BLoC pertence à **camada de apresentação**: traduz intenções do usuário
/// (eventos) em mudanças de estado observáveis pela UI, delegando toda a
/// lógica de negócio ao [RollDiceUseCase]. Ele não conhece widgets, rotas
/// ou canais nativos — apenas o Use Case que lhe foi injetado.
class DiceBloc extends Bloc<DiceEvent, DiceState> {
  /// Use Case injetado: única ponte entre o BLoC e a camada de domínio.
  // `final` assegura imutabilidade da dependência após construção.
  final RollDiceUseCase _rollDiceUseCase;

  /// Registra os handlers de evento e define [DiceInitial] como estado inicial.
  ///
  /// O padrão `on<EventType>(handler)` do `flutter_bloc` (v8+) substitui o
  /// antigo `mapEventToState`: cada tipo de evento tem um handler isolado,
  /// tornando o código mais legível e testável por evento individual.
  DiceBloc(this._rollDiceUseCase) : super(const DiceInitial()) {
    on<DiceRollRequested>(_onDiceRollRequested);
    on<DiceShakeDetected>(_onDiceShakeDetected);
  }

  /// Processa o pedido de rolagem manual.
  ///
  /// O método é `async` porque precisamos de `await` para o delay de
  /// animação. O [Emitter] garante que emissões dentro de handlers `async`
  /// sejam seguras — ele cancela automaticamente se o BLoC for fechado
  /// antes do `Future` completar, evitando emissões após `dispose`.
  Future<void> _onDiceRollRequested(
    DiceRollRequested event,
    Emitter<DiceState> emit,
  ) async {
    // Sinaliza à UI que a animação de rolagem deve começar.
    emit(const DiceRolling());

    // Delay intencional para que a UI tenha tempo de exibir a animação
    // antes de o resultado ser revelado. Não é um "sleep" bloqueante:
    // `await Future.delayed` libera o event loop do Dart durante a espera,
    // permitindo que outros microtasks e eventos sejam processados.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // `_rollDiceUseCase()` invoca `call()` — sintaxe de callable object.
    // O Use Case é síncrono, então não precisamos de `await` aqui.
    final result = _rollDiceUseCase();

    // Emite o estado final com o resultado; a UI para a animação e exibe o número.
    emit(DiceRolled(result));
  }

  /// Processa o evento de shake detectado pelo sensor nativo.
  ///
  /// A estratégia aqui é **reuso via redespacho de evento**: em vez de
  /// duplicar a lógica de rolagem, adicionamos um [DiceRollRequested]
  /// ao próprio stream de eventos do BLoC com `add()`.
  ///
  /// Isso garante que o comportamento (animação + delay + resultado) seja
  /// idêntico independentemente da origem (toque ou shake) — DRY aplicado
  /// ao gerenciamento de estado.
  void _onDiceShakeDetected(DiceShakeDetected event, Emitter<DiceState> emit) {
    // `add` enfileira o evento; o BLoC o processará na próxima iteração
    // do seu event loop interno — não há risco de recursão síncrona.
    add(const DiceRollRequested());
  }
}
