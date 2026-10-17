import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/character.dart';
import '../../domain/rules/srd_rules.dart';
import '../bloc/character_bloc.dart';

/// Salvaguardas contra a morte: aparece com o personagem em 0 PV. Mostra os
/// 3 sucessos e as 3 falhas (tocar numa bolinha ajusta à mão) e rola o d20.
class DeathSavesCard extends StatelessWidget {
  const DeathSavesCard({super.key, required this.character, this.random});

  final Character character;

  /// Gerador dos dados; os testes passam um com semente fixa.
  final Random? random;

  void _roll(BuildContext context) {
    final roll = (random ?? Random()).nextInt(20) + 1;
    final message = switch (deathSaveOutcome(roll)) {
      DeathSaveOutcome.criticalSuccess => '20 natural! Volta com 1 PV.',
      DeathSaveOutcome.success => '$roll: sucesso.',
      DeathSaveOutcome.failure => '$roll: falha.',
      DeathSaveOutcome.criticalFailure => '1 natural: duas falhas.',
    };
    context.read<CharacterBloc>().add(DeathSaveRolledEvent(character.id, roll));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _set(BuildContext context, {int? successes, int? failures}) {
    context.read<CharacterBloc>().add(
      SetDeathSavesEvent(
        character.id,
        successes ?? character.deathSaveSuccesses,
        failures ?? character.deathSaveFailures,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = character.isDead
        ? 'Morto'
        : character.isStable
        ? 'Estável (inconsciente)'
        : 'Morrendo';

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DnDIcon(
                  assetPath: 'assets/icons/condition/unconscious.svg',
                  size: 22,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Salvaguardas contra a morte',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MarksRow(
              label: 'Sucessos',
              count: character.deathSaveSuccesses,
              color: Colors.green.shade700,
              onTap: (value) => _set(context, successes: value),
            ),
            _MarksRow(
              label: 'Falhas',
              count: character.deathSaveFailures,
              color: theme.colorScheme.error,
              onTap: (value) => _set(context, failures: value),
            ),
            if (character.isDying) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _roll(context),
                icon: const Icon(Icons.casino_outlined),
                label: const Text('Rolar salvaguarda (d20)'),
              ),
            ],
            if (character.isDead)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Só magia traz o personagem de volta. Para corrigir um erro, '
                  'toque nas falhas para desmarcar.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MarksRow extends StatelessWidget {
  const _MarksRow({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;

  /// Recebe o novo total: tocar na bolinha N marca até ela; tocar na última
  /// marcada desmarca.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        for (var i = 1; i <= deathSavesToResolve; i++)
          IconButton(
            tooltip: '$label: $i',
            onPressed: () => onTap(count == i ? i - 1 : i),
            icon: Icon(
              i <= count ? Icons.circle : Icons.circle_outlined,
              color: color,
            ),
          ),
      ],
    );
  }
}
