import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';

/// Exibe o resultado da última rolagem: total em destaque no topo e, abaixo,
/// o "extrato" visual de cada dado — um bloco por [SingleDieResult] com seu
/// ícone e valor, como se fossem os próprios dados vistos sobre a mesa.
///
/// O d20 que rolou 20 ou 1 tem o valor destacado em verde/vermelho; um dado
/// descartado por vantagem/desvantagem aparece em um bloco extra, apagado e
/// riscado, ao lado do valor mantido.
///
/// Não traz superfície própria (sem [Card]): é exibido dentro de um
/// [AlertDialog] pelo chamador, que já fornece o fundo/elevação.
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        // `min`: o painel se dimensiona pelo próprio conteúdo — sem isso
        // (e sem um `Expanded` esperando altura vinda de fora) o Column
        // tentaria ocupar todo o espaço disponível do AlertDialog mesmo
        // com poucos dados.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(height: 16),
          // `maxHeight` sem `minHeight`: a área dos chips cresce só até o
          // necessário (poucos dados = pouca altura) e passa a rolar em vez
          // de estourar o modal quando o pool é grande (ex: 50 dados).
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _buildDieChips(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Um chip por dado mantido, mais um chip extra (apagado e riscado) para
  /// cada valor descartado por vantagem/desvantagem, e um último chip para o
  /// modificador global, se houver.
  List<Widget> _buildDieChips(ThemeData theme) {
    final chips = <Widget>[];

    for (final roll in result.rolls) {
      chips.add(
        _DieChip(
          icon: roll.type.iconAsset,
          value: roll.value,
          valueColor: roll.isCriticalSuccess
              ? _criticalSuccessColor
              : roll.isCriticalFailure
              ? theme.colorScheme.error
              : null,
        ),
      );

      if (roll.discardedValue != null) {
        chips.add(
          _DieChip(
            icon: roll.type.iconAsset,
            value: roll.discardedValue!,
            discarded: true,
          ),
        );
      }
    }

    if (result.modifier != 0) {
      final sign = result.modifier > 0 ? '+' : '-';
      chips.add(_ModifierChip(label: '$sign${result.modifier.abs()}'));
    }

    return chips;
  }
}

/// Bloco visual de um único dado: ícone do tipo + valor rolado, sobre um
/// fundo sutil de superfície. Quando [discarded] é `true` (dado perdido para
/// vantagem/desvantagem), o bloco inteiro fica com opacidade reduzida e o
/// valor ganha risco — mantido só para transparência de como o resultado foi
/// decidido, nunca somado ao total.
class _DieChip extends StatelessWidget {
  const _DieChip({
    required this.icon,
    required this.value,
    this.valueColor,
    this.discarded = false,
  });

  final String icon;
  final int value;
  final Color? valueColor;
  final bool discarded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DnDIcon(assetPath: icon, size: 28),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: discarded ? theme.colorScheme.onSurface : valueColor,
              fontWeight: FontWeight.bold,
              decoration: discarded ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );

    return discarded ? Opacity(opacity: 0.4, child: chip) : chip;
  }
}

/// Bloco visual do modificador global da rolagem, ex: `Mod +3`. Mesmo estilo
/// dos chips de dado para se ler como mais um item do "extrato", sem ícone
/// de dado por não vir de nenhuma rolagem.
class _ModifierChip extends StatelessWidget {
  const _ModifierChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mod ',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
