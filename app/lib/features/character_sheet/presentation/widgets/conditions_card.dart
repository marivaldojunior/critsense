import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/character.dart';
import '../../domain/entities/condition.dart';
import '../bloc/character_bloc.dart';

/// Condições ativas e nível de exaustão do personagem.
class ConditionsCard extends StatelessWidget {
  const ConditionsCard({super.key, required this.character});

  final Character character;

  void _showConditionPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CharacterBloc>(),
        child: _ConditionPicker(characterId: character.id),
      ),
    );
  }

  void _showDescription(BuildContext context, Condition condition) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: DnDIcon(assetPath: condition.iconAsset, size: 32),
        title: Text(condition.label),
        content: Text(condition.description),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CharacterBloc>().add(
                ToggleConditionEvent(character.id, condition),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Remover'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exhaustion = character.exhaustionLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Condições',
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showConditionPicker(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            if (character.conditions.isEmpty)
              Text('Nenhuma condição ativa.', style: theme.textTheme.bodySmall)
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final condition in character.conditions)
                    ActionChip(
                      avatar: DnDIcon(assetPath: condition.iconAsset, size: 18),
                      label: Text(condition.label),
                      onPressed: () => _showDescription(context, condition),
                    ),
                ],
              ),
            const Divider(height: 24),
            Row(
              children: [
                const DnDIcon(
                  assetPath: 'assets/icons/condition/exhaustion.svg',
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exaustão',
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Diminuir exaustão',
                  onPressed: exhaustion > 0
                      ? () => context.read<CharacterBloc>().add(
                          SetExhaustionEvent(character.id, exhaustion - 1),
                        )
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$exhaustion', style: theme.textTheme.titleMedium),
                IconButton(
                  tooltip: 'Aumentar exaustão',
                  onPressed: exhaustion < maxExhaustionLevel
                      ? () => context.read<CharacterBloc>().add(
                          SetExhaustionEvent(character.id, exhaustion + 1),
                        )
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            for (var level = 1; level <= exhaustion; level++)
              Text(
                '$level. ${exhaustionEffects[level]}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConditionPicker extends StatelessWidget {
  const _ConditionPicker({required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        final active = state.findCharacter(characterId)?.conditions ?? const [];
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final condition in Condition.values)
                  CheckboxListTile(
                    value: active.contains(condition),
                    onChanged: (_) => context.read<CharacterBloc>().add(
                      ToggleConditionEvent(characterId, condition),
                    ),
                    secondary: DnDIcon(
                      assetPath: condition.iconAsset,
                      size: 24,
                    ),
                    title: Text(condition.label),
                    subtitle: Text(condition.description),
                    isThreeLine: true,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
