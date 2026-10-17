import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/compendium/presentation/pages/spell_detail_screen.dart';
import 'package:crit_sense/features/compendium/presentation/pages/spells_screen.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/sheet_roll_sheet.dart';

import '../../../domain/entities/character.dart';
import '../../../domain/entities/character_spell.dart';
import '../../../domain/rules/roll_rules.dart';
import '../../../domain/srd/spell_slots.dart';
import '../../bloc/character_bloc.dart';
import '../../bloc/spellbook_bloc.dart';

/// Aba "Magias": conjuração (CD e ataque), espaços de magia e o grimório.
///
/// Os espaços ficam no [Character] ([CharacterBloc]); as magias ficam na
/// tabela do grimório ([SpellbookBloc], criado por esta aba).
class SpellsTab extends StatelessWidget {
  const SpellsTab({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpellbookBloc>(
      create: (_) => sl<SpellbookBloc>()..add(LoadSpellbookEvent(character.id)),
      child: BlocBuilder<CharacterBloc, CharacterState>(
        buildWhen: (previous, current) => !identical(
          previous.findCharacter(character.id),
          current.findCharacter(character.id),
        ),
        builder: (context, state) {
          final live = state.findCharacter(character.id) ?? character;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SpellcastingCard(character: live),
              const SizedBox(height: 10),
              if (live.maxSpellSlots.any((n) => n > 0) ||
                  live.pactMagic != null)
                _SpellSlotsCard(character: live),
              const SizedBox(height: 16),
              _Spellbook(character: live),
            ],
          );
        },
      ),
    );
  }
}

String _signed(int value) => value >= 0 ? '+$value' : '$value';

class _SpellcastingCard extends StatelessWidget {
  const _SpellcastingCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ability = character.spellcastingAbility;

    if (ability == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'A classe ${character.characterClass} não conjura magias. Você '
            'ainda pode guardar aqui magias de raça ou de itens.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _Stat(label: 'Conjuração', value: ability.label),
            ),
            Expanded(
              child: _Stat(
                label: 'CD de resistência',
                value: '${character.spellSaveDc}',
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  final suggestion = suggestedRollMode(
                    character,
                    RollKind.attack,
                  );
                  showSheetRoll(
                    context,
                    title: 'Ataque mágico',
                    modifier: character.spellAttackBonus!,
                    initialMode: suggestion.mode,
                    note: rollSuggestionNote(suggestion),
                  );
                },
                child: _Stat(
                  label: 'Ataque mágico (toque para rolar)',
                  value: _signed(character.spellAttackBonus!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// Espaços de magia: cada bolinha cheia é um espaço disponível. Tocar numa
/// cheia gasta um espaço; tocar numa vazia devolve um (correção).
class _SpellSlotsCard extends StatelessWidget {
  const _SpellSlotsCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<CharacterBloc>();
    final pact = character.pactMagic;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Espaços de magia', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Toque num espaço para gastar; toque num vazio para devolver. '
              'Os espaços voltam no Descanso Longo.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (var level = 1; level <= spellSlotLevels; level++)
              if (character.maxSpellSlots[level - 1] > 0)
                _SlotRow(
                  label: '$levelº nível',
                  total: character.maxSpellSlots[level - 1],
                  available: character.availableSpellSlots(level),
                  onUse: () => bloc.add(UseSpellSlotEvent(character.id, level)),
                  onRestore: () =>
                      bloc.add(RestoreSpellSlotEvent(character.id, level)),
                ),
            if (pact != null)
              _SlotRow(
                label: 'Pacto (${pact.slotLevel}º)',
                total: pact.slots,
                available: (pact.slots - character.pactSlotsUsed).clamp(
                  0,
                  pact.slots,
                ),
                onUse: () => bloc.add(UsePactSlotEvent(character.id)),
                onRestore: () => bloc.add(RestorePactSlotEvent(character.id)),
              ),
            if (pact != null)
              Text(
                'A Magia de Pacto volta no Descanso Curto.',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.label,
    required this.total,
    required this.available,
    required this.onUse,
    required this.onRestore,
  });

  final String label;
  final int total;
  final int available;
  final VoidCallback onUse;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: Wrap(
            children: [
              for (var i = 0; i < total; i++)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: i < available ? 'Gastar espaço' : 'Devolver espaço',
                  onPressed: i < available ? onUse : onRestore,
                  icon: Icon(
                    i < available ? Icons.circle : Icons.circle_outlined,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        Text('$available/$total'),
      ],
    );
  }
}

class _Spellbook extends StatelessWidget {
  const _Spellbook({required this.character});

  final Character character;

  String _groupLabel(int? level) => switch (level) {
    null => 'Nível desconhecido',
    0 => 'Truques',
    _ => '$levelº nível',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preparesSpells = character.srdClass?.preparesSpells ?? false;
    final limit = character.preparedSpellLimit;

    return BlocConsumer<SpellbookBloc, SpellbookState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.status != SpellbookStatus.failure,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
      builder: (context, state) {
        final header = Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grimório', style: theme.textTheme.titleMedium),
                  if (limit != null)
                    Text(
                      'Preparadas: ${state.preparedCount}/$limit',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: state.preparedCount > limit
                            ? theme.colorScheme.error
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpellsScreen()),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<SpellbookBloc>().add(
                        LoadSpellbookEvent(character.id),
                      );
                    }
                  }),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        );

        final body = switch (state.status) {
          SpellbookStatus.initial || SpellbookStatus.loading => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          SpellbookStatus.failure => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(state.errorMessage ?? 'Erro ao carregar as magias.'),
          ),
          SpellbookStatus.success when state.spells.isEmpty => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Nenhuma magia ainda. Toque em "Adicionar" para escolher no '
              'compêndio.',
            ),
          ),
          SpellbookStatus.success => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final group in _groupByLevel(state.spells).entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    _groupLabel(group.key),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                for (final spell in group.value)
                  _SpellTile(
                    spell: spell,
                    showPrepared: preparesSpells && !spell.isCantrip,
                    concentrating: character.concentrationSpell == spell.name,
                  ),
              ],
            ],
          ),
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, const Divider(), body],
        );
      },
    );
  }

  /// Agrupa por nível, com os truques primeiro e os desconhecidos no fim.
  Map<int?, List<CharacterSpell>> _groupByLevel(List<CharacterSpell> spells) {
    final groups = <int?, List<CharacterSpell>>{};
    final sorted = spells.toList()
      ..sort((a, b) => (a.level ?? 99).compareTo(b.level ?? 99));
    for (final spell in sorted) {
      groups.putIfAbsent(spell.level, () => []).add(spell);
    }
    return groups;
  }
}

class _SpellTile extends StatelessWidget {
  const _SpellTile({
    required this.spell,
    required this.showPrepared,
    required this.concentrating,
  });

  final CharacterSpell spell;
  final bool showPrepared;

  /// O personagem mantém a concentração nesta magia.
  final bool concentrating;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpellbookBloc>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: showPrepared
            ? Checkbox(
                value: spell.prepared,
                onChanged: (_) => bloc.add(TogglePreparedEvent(spell)),
              )
            : const DnDIcon(
                assetPath: 'assets/icons/spell/evocation.svg',
                size: 24,
              ),
        title: Text(spell.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: showPrepared
            ? Text(spell.prepared ? 'Preparada' : 'Não preparada')
            : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpellDetailScreen(spellIndex: spell.spellIndex),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              isSelected: concentrating,
              icon: DnDIcon(
                assetPath: 'assets/icons/game/concentration.svg',
                size: 22,
                color: concentrating
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              tooltip: concentrating ? 'Encerrar concentração' : 'Concentrar',
              onPressed: () => context.read<CharacterBloc>().add(
                SetConcentrationEvent(
                  spell.characterId,
                  concentrating ? null : spell.name,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover magia',
              onPressed: () => bloc.add(DeleteSpellEvent(spell)),
            ),
          ],
        ),
      ),
    );
  }
}
