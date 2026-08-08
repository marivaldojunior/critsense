import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Caminho do ícone SVG temático correspondente a cada [DiceType].
///
/// O d100 (percentual) não possui ícone dedicado no pacote e é rolado com um
/// d10 na mesa, por isso reutiliza o mesmo asset.
String _diceIconAsset(DiceType type) => switch (type) {
  DiceType.d4 => 'assets/icons/dice/d4.svg',
  DiceType.d6 => 'assets/icons/dice/d6.svg',
  DiceType.d8 => 'assets/icons/dice/d8.svg',
  DiceType.d10 => 'assets/icons/dice/d10.svg',
  DiceType.d12 => 'assets/icons/dice/d12.svg',
  DiceType.d20 => 'assets/icons/dice/d20.svg',
  DiceType.d100 => 'assets/icons/dice/d10.svg',
};

/// Botão de um tipo de dado no painel de montagem do pool: exibe o rótulo
/// (`d6`, `d20`...) e controles de +/- para a quantidade selecionada.
class DiceTypeButton extends StatelessWidget {
  const DiceTypeButton({
    super.key,
    required this.type,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final DiceType type;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = count > 0;

    return Card(
      elevation: selected ? 3 : 0,
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.12)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onAdd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DnDIcon(
                assetPath: _diceIconAsset(type),
                size: 40,
                color: selected ? colorScheme.primary : colorScheme.outline,
              ),
              const SizedBox(height: 4),
              Text(
                type.label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepIconButton(
                    icon: Icons.remove_circle_outline,
                    onPressed: selected ? onRemove : null,
                  ),
                  SizedBox(
                    width: 22,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StepIconButton(
                    icon: Icons.add_circle_outline,
                    onPressed: onAdd,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIconButton extends StatelessWidget {
  const _StepIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 20,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
