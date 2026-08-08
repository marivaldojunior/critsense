import 'package:flutter/material.dart';

import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';

/// Alterna o modo de rolagem aplicado aos d20 do pool: normal, vantagem
/// (rola 2, mantém o maior) ou desvantagem (rola 2, mantém o menor).
class D20ModeSelector extends StatelessWidget {
  const D20ModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final D20RollMode mode;
  final ValueChanged<D20RollMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<D20RollMode>(
      segments: const [
        ButtonSegment(
          value: D20RollMode.disadvantage,
          label: Text('Desvantagem'),
          icon: Icon(Icons.trending_down),
        ),
        ButtonSegment(
          value: D20RollMode.normal,
          label: Text('Normal'),
        ),
        ButtonSegment(
          value: D20RollMode.advantage,
          label: Text('Vantagem'),
          icon: Icon(Icons.trending_up),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
