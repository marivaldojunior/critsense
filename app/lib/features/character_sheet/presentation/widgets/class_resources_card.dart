import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/character.dart';
import '../../domain/rules/class_resource_rules.dart';
import '../bloc/character_bloc.dart';
import 'number_edit_dialog.dart';

/// Recursos de classe com usos contados (Fúria, Pontos de Ki, Surto de
/// Ação...). Os botões gastam e devolvem um uso; tocar no número define os
/// usos que restam. Não aparece para uma classe sem recursos.
class ClassResourcesCard extends StatelessWidget {
  const ClassResourcesCard({super.key, required this.character});

  final Character character;

  Future<void> _editRemaining(
    BuildContext context,
    ClassResource resource,
  ) async {
    final bloc = context.read<CharacterBloc>();
    final value = await showNumberEditDialog(
      context,
      title: '${resource.name}: usos restantes',
      initialValue: character.resourceRemaining(resource),
      helperText: 'Máximo: ${resource.max}.',
    );
    if (value != null) {
      bloc.add(
        SetClassResourceRemainingEvent(character.id, resource.key, value),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resources = character.classResources;
    if (resources.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final bloc = context.read<CharacterBloc>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Recursos de classe', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final resource in resources)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(resource.name, style: theme.textTheme.bodyLarge),
                        Text(
                          'Volta no ${resource.recharge.label}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (resource.unlimited)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 14,
                      ),
                      child: Text(
                        'Sem limite',
                        style: theme.textTheme.titleSmall,
                      ),
                    )
                  else ...[
                    IconButton(
                      tooltip: 'Gastar ${resource.name}',
                      onPressed: character.resourceRemaining(resource) > 0
                          ? () => bloc.add(
                              UseClassResourceEvent(character.id, resource.key),
                            )
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    InkWell(
                      onTap: () => _editRemaining(context, resource),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Text(
                          '${character.resourceRemaining(resource)}'
                          '/${resource.max}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Devolver ${resource.name}',
                      onPressed:
                          character.resourceRemaining(resource) < resource.max
                          ? () => bloc.add(
                              RestoreClassResourceEvent(
                                character.id,
                                resource.key,
                              ),
                            )
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
