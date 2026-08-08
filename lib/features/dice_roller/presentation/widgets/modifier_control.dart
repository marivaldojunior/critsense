import 'package:flutter/material.dart';

/// Controle para aumentar/diminuir o modificador numérico global do pool.
class ModifierControl extends StatelessWidget {
  const ModifierControl({
    super.key,
    required this.modifier,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int modifier;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sign = modifier > 0 ? '+' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Modificador', style: theme.textTheme.titleSmall),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$sign$modifier',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton.filledTonal(onPressed: onIncrement, icon: const Icon(Icons.add)),
      ],
    );
  }
}
