import 'package:flutter/material.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';

/// Uma linha de atributo no formulário de Point Buy: nome, controles de
/// +/- e o valor atual com o modificador de D&D 5e entre parênteses.
class AttributeRow extends StatelessWidget {
  const AttributeRow({
    super.key,
    required this.type,
    required this.value,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final AttributeType type;
  final int value;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modifier = attributeModifier(value);
    final modifierLabel = modifier >= 0 ? '+$modifier' : '$modifier';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(type.label, style: theme.textTheme.bodyLarge),
          ),
          IconButton(
            onPressed: canDecrement ? onDecrement : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 68,
            child: Text(
              '$value ($modifierLabel)',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: canIncrement ? onIncrement : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
