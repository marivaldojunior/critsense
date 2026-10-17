import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/attribute.dart';
import '../../domain/entities/attribute_type.dart';
import '../bloc/ability_scores_cubit.dart';
import 'point_buy_section.dart';

/// Atributos da criação: escolhe o método (compra de pontos, matriz padrão
/// ou rolagem 4d6) e, na matriz e na rolagem, distribui os valores.
class AbilityScoresSection extends StatelessWidget {
  const AbilityScoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AbilityScoresCubit, AbilityScoresState>(
      builder: (context, state) {
        final cubit = context.read<AbilityScoresCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<AbilityScoreMethod>(
              showSelectedIcon: false,
              segments: [
                for (final method in AbilityScoreMethod.values)
                  ButtonSegment(value: method, label: Text(method.label)),
              ],
              selected: {state.method},
              onSelectionChanged: (selected) =>
                  cubit.selectMethod(selected.single),
            ),
            const SizedBox(height: 12),
            if (state.method == AbilityScoreMethod.pointBuy)
              const PointBuySection()
            else
              _AssignmentPanel(state: state),
          ],
        );
      },
    );
  }
}

class _AssignmentPanel extends StatelessWidget {
  const _AssignmentPanel({required this.state});

  final AbilityScoresState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AbilityScoresCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.method == AbilityScoreMethod.roll
              ? 'Valores rolados (4d6, sem o menor dado):'
              : 'Valores da matriz padrão:',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < state.pool.length; i++)
              Chip(
                label: Text(
                  state.rolls.isEmpty
                      ? '${state.pool[i]}'
                      : '${state.pool[i]} (${state.rolls[i].join(', ')})',
                ),
                backgroundColor: state.usedIndices.contains(i)
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primaryContainer,
              ),
          ],
        ),
        if (state.method == AbilityScoreMethod.roll)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: cubit.reroll,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Rolar de novo'),
            ),
          ),
        const SizedBox(height: 8),
        for (final attribute in AttributeType.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                DnDIcon(assetPath: attribute.iconAsset, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(attribute.label)),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey(
                      '${state.method}-${attribute.name}-'
                      '${state.assignment[attribute]}',
                    ),
                    initialValue: state.assignment[attribute],
                    isDense: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(child: Text('—')),
                      for (var i = 0; i < state.pool.length; i++)
                        DropdownMenuItem<int?>(
                          value: i,
                          child: Text('${state.pool[i]}'),
                        ),
                    ],
                    onChanged: (index) => cubit.assign(attribute, index),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    state.assignment[attribute] == null
                        ? ''
                        : _signed(
                            attributeModifier(
                              state.pool[state.assignment[attribute]!],
                            ),
                          ),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        if (!state.isComplete)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Dê um valor a cada atributo. Cada valor só pode ser usado uma vez.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  String _signed(int value) => value >= 0 ? '+$value' : '$value';
}
