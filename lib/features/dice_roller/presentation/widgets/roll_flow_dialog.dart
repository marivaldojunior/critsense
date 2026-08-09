import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_bloc.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/animated_rolling_dice.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/roll_result_panel.dart';

/// Dialog único que acompanha todo o ciclo de uma rolagem: abre exibindo os
/// dados girando ([AnimatedRollingDice]) e transiciona suavemente para o
/// resultado ([RollResultPanel]) assim que o [DiceBloc] conclui a rolagem.
///
/// Deve ser aberto com `barrierDismissible: false` pelo chamador — fechar
/// antes do resultado deixaria a rolagem em andamento sem feedback visual.
class RollFlowDialog extends StatelessWidget {
  const RollFlowDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiceBloc, DiceState>(
      builder: (context, state) {
        final isRolling = state.status == DiceRollStatus.rolling;

        return AlertDialog(
          content: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: switch ((isRolling, state.lastResult)) {
              // Tabuleiro físico em área quadrada fixa (300x300, folga em
              // torno dos 250x250 usados na simulação): o dado precisa de um
              // espaço estável para quicar independente do que vem depois.
              (true, _) => SizedBox(
                key: const ValueKey('rolling'),
                width: 300,
                height: 300,
                child: Center(child: AnimatedRollingDice(pool: state.pool)),
              ),
              // Sem tamanho fixo aqui: o RollResultPanel se dimensiona pelo
              // próprio conteúdo (poucos dados = modal compacto) e só limita
              // a própria altura internamente para pools grandes.
              (false, final result?) => RollResultPanel(
                key: const ValueKey('result'),
                result: result,
              ),
              (false, null) => const SizedBox.shrink(key: ValueKey('empty')),
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          // Só aparece com a rolagem concluída — enquanto `rolling`, o
          // usuário não deve ter como fechar o dialog manualmente.
          actions: isRolling
              ? null
              : [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Ok'),
                  ),
                ],
        );
      },
    );
  }
}
