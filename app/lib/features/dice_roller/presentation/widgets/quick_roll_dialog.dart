import 'package:flutter/material.dart';

import 'package:crit_sense/di/injection_container.dart';

import '../../domain/entities/dice_notation.dart';
import '../../domain/usecases/roll_dice_usecase.dart';
import '../bloc/roll_history_cubit.dart';

/// Rola [notation] (ex: `2d6+3`), grava no histórico e mostra o total.
/// Não faz nada se a notação não é válida.
Future<void> showQuickRoll(BuildContext context, String notation) async {
  final parsed = DiceNotation.tryParse(notation);
  if (parsed == null || !parsed.hasDice) return;
  final result = sl<RollDiceUseCase>()(
    pool: parsed.pool,
    modifier: parsed.modifier,
  );
  sl<RollHistoryCubit>().record(notation, result);

  final theme = Theme.of(context);
  final color = result.hasCriticalSuccess
      ? Colors.green.shade700
      : result.hasCriticalFailure
      ? theme.colorScheme.error
      : null;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Rolar $notation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${result.total}',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(describeRoll(result), textAlign: TextAlign.center),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}
