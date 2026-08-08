import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../../domain/entities/monster_detail.dart';
import '../bloc/monster_detail_bloc.dart';

/// Traduz o campo `type` da API (ex: "dragon", "fey") para o nome do
/// arquivo correspondente em `assets/icons/monster/`.
///
/// "fey" é normalizado para "fae" — grafia usada pelo pacote de ícones.
/// Tipos compostos sem ícone dedicado (ex: "swarm of Tiny beasts") retornam
/// `null`, caso em que a UI omite o ícone em vez de exibir um asset inexistente.
const _knownMonsterTypeIcons = {
  'aberration',
  'beast',
  'celestial',
  'construct',
  'dragon',
  'elemental',
  'fae',
  'fiend',
  'giant',
  'humanoid',
  'monstrosity',
  'ooze',
  'plant',
  'undead',
};

String? _monsterTypeIconAsset(String type) {
  final key = type.toLowerCase() == 'fey' ? 'fae' : type.toLowerCase();
  if (!_knownMonsterTypeIcons.contains(key)) return null;
  return 'assets/icons/monster/$key.svg';
}

/// Tela de detalhes de um monstro do compêndio, no formato de um Stat Block
/// de D&D 5e: cabeçalho de tamanho/tipo/tendência, atributos de combate
/// (CA, PV, deslocamento) e a lista de ações.
///
/// Recebe [monsterIndex] via construtor, seguindo o mesmo padrão de
/// [SpellDetailScreen] e [EquipmentDetailScreen].
class MonsterDetailScreen extends StatelessWidget {
  /// Índice do monstro na API (ex: "adult-red-dragon").
  final String monsterIndex;

  const MonsterDetailScreen({super.key, required this.monsterIndex});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<MonsterDetailBloc>()..add(LoadMonsterDetailEvent(monsterIndex)),
      child: BlocBuilder<MonsterDetailBloc, MonsterDetailState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state is MonsterDetailLoaded ? state.monster.name : 'Detalhes',
              ),
            ),
            body: switch (state) {
              MonsterDetailInitial() => const SizedBox.shrink(),
              MonsterDetailLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              MonsterDetailLoaded(:final monster) => _MonsterDetailBody(
                monster: monster,
              ),
              MonsterDetailError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            },
          );
        },
      ),
    );
  }
}

/// Corpo da tela com o Stat Block completo do monstro.
class _MonsterDetailBody extends StatelessWidget {
  final MonsterDetail monster;

  const _MonsterDetailBody({required this.monster});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeIconAsset = _monsterTypeIconAsset(monster.type);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabeçalho: tamanho, tipo e tendência ───────────────────────
          Row(
            children: [
              if (typeIconAsset != null) ...[
                DnDIcon(
                  assetPath: typeIconAsset,
                  size: 28,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${monster.size} • ${monster.type}',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            monster.alignment,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),

          // ── CA e PV ──────────────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                iconAsset: 'assets/icons/attribute/ac.svg',
                label: 'CA',
                value: '${monster.armorClass}',
              ),
              _StatCard(
                iconAsset: 'assets/icons/hp/full.svg',
                label: 'PV',
                value: '${monster.hitPoints}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Deslocamento ─────────────────────────────────────────────
          Text('Deslocamento', style: theme.textTheme.titleMedium),
          const Divider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: monster.speed.entries
                .map(
                  (entry) => Chip(
                    avatar: DnDIcon(
                      assetPath: 'assets/icons/movement/${entry.key}.svg',
                      size: 18,
                    ),
                    label: Text(entry.value),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),

          // ── Ações ────────────────────────────────────────────────────
          if (monster.actions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Ações', style: theme.textTheme.titleMedium),
            const Divider(),
            ...monster.actions.map(
              (action) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const DnDIcon(
                    assetPath: 'assets/icons/combat/action.svg',
                    size: 24,
                  ),
                  title: Text(
                    action.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(action.desc),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card compacto que exibe um atributo do monstro com ícone temático.
class _StatCard extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;

  const _StatCard({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DnDIcon(assetPath: iconAsset, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
