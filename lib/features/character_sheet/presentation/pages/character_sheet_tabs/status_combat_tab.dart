import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../domain/entities/attribute_type.dart';
import '../../../domain/entities/character.dart';
import '../../../domain/entities/proficiency.dart';
import '../../../domain/entities/skill.dart';
import '../../bloc/character_bloc.dart';
import '../../widgets/animated_hp_bar.dart';

/// Aba "Status & Combate" da ficha: os blocos centrais da primeira página
/// da ficha oficial — CA/Iniciativa/Deslocamento, PV e as duas listas de
/// proficiência (Testes de Resistência e Perícias).
///
/// Só a seção de proficiências (últimos dois blocos) é reativa via
/// [BlocBuilder]: os cartões de CA/Iniciativa/Deslocamento/PV usam o
/// [character] recebido diretamente, então marcar uma perícia não os
/// reconstrói — apenas a lista de proficiências correspondente.
class StatusCombatTab extends StatelessWidget {
  const StatusCombatTab({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final topStats = _TopStats(character: character);
        final proficiencies = _ProficienciesPanel(character: character);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: topStats,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                  child: proficiencies,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: topStats),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: proficiencies,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Bloco superior (CA/Iniciativa/Deslocamento) + bloco central (PV).
class _TopStats extends StatelessWidget {
  const _TopStats({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/attribute/ac.svg',
                label: 'CA',
                value: '${character.armorClass}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/combat/initiative.svg',
                label: 'Iniciativa',
                value: character.initiative >= 0
                    ? '+${character.initiative}'
                    : '${character.initiative}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                iconAsset: 'assets/icons/movement/walking.svg',
                label: 'Deslocamento',
                value: '${character.speed} pés',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _HpCard(character: character),
      ],
    );
  }
}

/// Cartão pequeno e uniforme para CA/Iniciativa/Deslocamento.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  final String iconAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            DnDIcon(assetPath: iconAsset, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloco central de Pontos de Vida: barra animada com máximo, atual e temporário.
class _HpCard extends StatelessWidget {
  const _HpCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedHpBar(
          currentHitPoints: character.currentHitPoints,
          maxHitPoints: character.maxHitPoints,
          temporaryHitPoints: character.temporaryHitPoints,
        ),
      ),
    );
  }
}

/// Painel reativo com Sabedoria Passiva, Testes de Resistência e Perícias.
///
/// É a única parte da aba dentro de um [BlocBuilder]: o [buildWhen] só
/// libera a reconstrução quando o objeto [Character] correspondente a
/// [character] muda de identidade na lista do BLoC — o que só acontece
/// quando [ToggleProficiencyEvent] gera uma cópia nova via `copyWith`. Os
/// cartões de CA/PV da aba, fora deste widget, nunca são afetados.
class _ProficienciesPanel extends StatelessWidget {
  const _ProficienciesPanel({required this.character});

  final Character character;

  Character? _findSelf(CharacterState state) {
    if (state is! CharacterLoaded) return null;
    for (final c in state.characters) {
      if (c.id == character.id) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      buildWhen: (previous, current) =>
          !identical(_findSelf(previous), _findSelf(current)),
      builder: (context, state) {
        final liveCharacter = _findSelf(state) ?? character;
        final bloc = context.read<CharacterBloc>();

        return ListView(
          children: [
            _PassiveWisdomBadge(value: bloc.passiveWisdom(liveCharacter)),
            const SizedBox(height: 16),
            Text(
              'Testes de Resistência',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Divider(),
            for (final attribute in AttributeType.values)
              _ProficiencyRow(
                iconAsset: attribute.iconAsset,
                label: attribute.label,
                modifier: bloc.savingThrowModifier(liveCharacter, attribute),
                checked: liveCharacter.proficiencies.contains(
                  SavingThrowProficiency(attribute),
                ),
                onChanged: () => context.read<CharacterBloc>().add(
                  ToggleProficiencyEvent(
                    liveCharacter.id,
                    SavingThrowProficiency(attribute),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('Perícias', style: Theme.of(context).textTheme.titleSmall),
            const Divider(),
            for (final skill in Skill.values)
              _ProficiencyRow(
                iconAsset: skill.iconAsset,
                label: skill.label,
                sublabel: skill.attribute.label,
                modifier: bloc.skillModifier(liveCharacter, skill),
                checked: liveCharacter.proficiencies.contains(
                  SkillProficiency(skill),
                ),
                onChanged: () => context.read<CharacterBloc>().add(
                  ToggleProficiencyEvent(
                    liveCharacter.id,
                    SkillProficiency(skill),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Emblema da Sabedoria Passiva (Percepção): não é interativo, só leitura.
class _PassiveWisdomBadge extends StatelessWidget {
  const _PassiveWisdomBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const DnDIcon(
              assetPath: 'assets/icons/skill/perception.svg',
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sabedoria Passiva (Percepção)',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              '$value',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma linha de perícia ou teste de resistência: checkbox de proficiência,
/// ícone temático, rótulo e o modificador final já calculado pelo BLoC.
class _ProficiencyRow extends StatelessWidget {
  const _ProficiencyRow({
    required this.iconAsset,
    required this.label,
    this.sublabel,
    required this.modifier,
    required this.checked,
    required this.onChanged,
  });

  final String iconAsset;
  final String label;
  final String? sublabel;
  final int modifier;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modifierLabel = modifier >= 0 ? '+$modifier' : '$modifier';

    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(value: checked, onChanged: (_) => onChanged()),
            DnDIcon(
              assetPath: iconAsset,
              size: 20,
              color: checked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: theme.textTheme.bodyMedium),
                  if (sublabel != null)
                    Text(sublabel!, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                modifierLabel,
                textAlign: TextAlign.end,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
