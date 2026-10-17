import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/attribute_type.dart';
import '../../domain/rules/srd_rules.dart';
import '../bloc/character_bloc.dart';

/// Painel do Descanso Curto: o jogador gasta dados de vida um a um e vê
/// cada rolagem. "Concluir" fecha o descanso.
class ShortRestSheet extends StatefulWidget {
  const ShortRestSheet({super.key, required this.characterId, this.random});

  final String characterId;

  /// Gerador dos dados; os testes passam um com semente fixa.
  final Random? random;

  @override
  State<ShortRestSheet> createState() => _ShortRestSheetState();
}

class _ShortRestSheetState extends State<ShortRestSheet> {
  late final Random _random = widget.random ?? Random();
  final List<String> _log = [];

  void _spendHitDie(int hitDie, int constitutionModifier) {
    final roll = _random.nextInt(hitDie) + 1;
    final healing = hitDieHealing(
      roll: roll,
      constitutionModifier: constitutionModifier,
    );
    final modifier = constitutionModifier >= 0
        ? '+ $constitutionModifier'
        : '- ${constitutionModifier.abs()}';
    setState(() => _log.add('d$hitDie: $roll $modifier = $healing PV'));
    context.read<CharacterBloc>().add(
      SpendHitDieEvent(widget.characterId, roll),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        final character = state.findCharacter(widget.characterId);
        if (character == null) return const SizedBox.shrink();
        final conModifier = character.modifierOf(AttributeType.constitution);
        final canSpend =
            character.hitDiceRemaining > 0 &&
            character.currentHitPoints < character.maxHitPoints;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Descanso Curto', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Gaste dados de vida para recuperar PV. Cada dado cura o '
                  'valor rolado + modificador de CON.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const DnDIcon(
                          assetPath: 'assets/icons/hp/full.svg',
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PV ${character.currentHitPoints}/'
                          '${character.maxHitPoints}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Text(
                      'Dados de vida: ${character.hitDiceRemaining}/'
                      '${character.level} (d${character.hitDie})',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (_log.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final line in _log)
                    Text(line, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: canSpend
                      ? () => _spendHitDie(character.hitDie, conModifier)
                      : null,
                  icon: const Icon(Icons.casino_outlined),
                  label: const Text('Gastar 1 dado de vida'),
                ),
                if (character.hitDiceRemaining == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Sem dados de vida. Eles voltam no Descanso Longo.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    context.read<CharacterBloc>().add(
                      TakeShortRestEvent(widget.characterId),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Concluir descanso'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
