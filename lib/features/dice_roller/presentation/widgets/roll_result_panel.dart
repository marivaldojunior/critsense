import 'package:flutter/material.dart';

import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Exibe o resultado da última rolagem: total em destaque e a fórmula
/// detalhada por tipo de dado, ex: `[4, 6] + [8] + [20] + 3 = 41`.
///
/// O valor de um d20 que rolou 20 ou 1 é destacado em verde/vermelho
/// dentro da própria fórmula, mesmo entre outros dados do pool.
class RollResultPanel extends StatelessWidget {
  const RollResultPanel({super.key, required this.result});

  final DiceRollResult result;

  static final Color _criticalSuccessColor = Colors.green.shade600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCriticalSuccess = result.hasCriticalSuccess;
    final hasCriticalFailure = result.hasCriticalFailure;

    final totalColor = hasCriticalSuccess
        ? _criticalSuccessColor
        : hasCriticalFailure
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Text(
              '${result.total}',
              style: theme.textTheme.displayMedium?.copyWith(
                color: totalColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasCriticalSuccess)
              Text(
                'ACERTO CRÍTICO!',
                style: TextStyle(
                  color: _criticalSuccessColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              )
            else if (hasCriticalFailure)
              Text(
                'FALHA CRÍTICA!',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text.rich(
                TextSpan(children: _buildFormulaSpans(theme)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildFormulaSpans(ThemeData theme) {
    final baseStyle = theme.textTheme.headlineSmall;
    final grouped = <DiceType, List<SingleDieResult>>{};
    for (final roll in result.rolls) {
      grouped.putIfAbsent(roll.type, () => []).add(roll);
    }

    final spans = <InlineSpan>[];
    var firstGroup = true;
    for (final group in grouped.values) {
      if (!firstGroup) spans.add(TextSpan(text: ' + ', style: baseStyle));
      firstGroup = false;

      spans.add(TextSpan(text: '[', style: baseStyle));
      for (var i = 0; i < group.length; i++) {
        if (i > 0) spans.add(TextSpan(text: ', ', style: baseStyle));
        final roll = group[i];
        final color = roll.isCriticalSuccess
            ? _criticalSuccessColor
            : roll.isCriticalFailure
            ? theme.colorScheme.error
            : null;
        spans.add(
          TextSpan(
            text: '${roll.value}',
            style: baseStyle?.copyWith(
              color: color,
              fontWeight: color != null ? FontWeight.bold : null,
            ),
          ),
        );
        // Dado descartado por vantagem/desvantagem: exibido pequeno e
        // riscado, só para transparência de como o valor mantido foi decidido.
        if (roll.discardedValue != null) {
          spans.add(
            TextSpan(
              text: ' (${roll.discardedValue})',
              style: baseStyle?.copyWith(
                fontSize: (baseStyle.fontSize ?? 24) * 0.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                decoration: TextDecoration.lineThrough,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        }
      }
      spans.add(TextSpan(text: ']', style: baseStyle));
    }

    if (result.modifier != 0) {
      final sign = result.modifier > 0 ? '+' : '-';
      spans.add(
        TextSpan(text: ' $sign ${result.modifier.abs()}', style: baseStyle),
      );
    }

    spans.add(
      TextSpan(
        text: ' = ${result.total}',
        style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
      ),
    );

    return spans;
  }
}
