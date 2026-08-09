import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/character_picker_bottom_sheet.dart';
import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';

import '../../../../di/injection_container.dart';
import '../../domain/entities/monster_detail.dart';
import '../bloc/monster_detail_bloc.dart';
import '../widgets/compendium_feedback_state.dart';

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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (state) {
                MonsterDetailInitial() =>
                  const SizedBox.shrink(key: ValueKey('initial')),
                MonsterDetailLoading() =>
                  const _MonsterDetailSkeleton(key: ValueKey('loading')),
                MonsterDetailLoaded(:final monster) => _MonsterDetailBody(
                  key: const ValueKey('loaded'),
                  monster: monster,
                ),
                MonsterDetailError(:final message) =>
                  CompendiumFeedbackState.error(
                    key: const ValueKey('error'),
                    message: message,
                  ),
              },
            ),
            // Fixo na base da tela — "Registrar Abate" fica sempre
            // alcançável na thumb zone, seguindo o mesmo padrão de CTA
            // primário fixo já usado no Rolador de Dados e no Formulário
            // de Personagem. Só existe com o monstro já carregado.
            bottomNavigationBar: state is MonsterDetailLoaded
                ? _RegisterKillBar(monster: state.monster)
                : null,
          );
        },
      ),
    );
  }
}

/// Barra fixa com o CTA "Registrar Abate": abre o [CharacterPickerBottomSheet]
/// e, se um personagem for escolhido, registra o monstro como derrotado por
/// ele via [AddBossToCharacterEvent].
class _RegisterKillBar extends StatelessWidget {
  final MonsterDetail monster;

  const _RegisterKillBar({required this.monster});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _registerKill(context, monster),
            icon: const DnDIcon(
              assetPath: 'assets/icons/monster/dragon.svg',
              size: 24,
            ),
            label: const Text('Registrar Abate'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerKill(BuildContext context, MonsterDetail monster) async {
    final character = await CharacterPickerBottomSheet.show(context);
    if (character == null) return;
    if (!context.mounted) return;

    context.read<CharacterBloc>().add(
      AddBossToCharacterEvent(character.id, monster.name),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${monster.name} registrado como abatido por ${character.name}.',
        ),
      ),
    );
  }
}

/// Corpo da tela com o Stat Block completo do monstro.
class _MonsterDetailBody extends StatelessWidget {
  final MonsterDetail monster;

  const _MonsterDetailBody({super.key, required this.monster});

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
                Hero(
                  tag: 'monster-icon-${monster.index}',
                  child: DnDIcon(
                    assetPath: typeIconAsset,
                    size: 28,
                    color: theme.colorScheme.secondary,
                  ),
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

/// Esqueleto de carregamento que imita o layout do Stat Block: bloco de
/// título, blocos menores de status (CA/PV) e linhas de ações.
class _MonsterDetailSkeleton extends StatelessWidget {
  const _MonsterDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho: tamanho, tipo e tendência ───────────────────
            Row(
              children: const [
                SkeletonBones.circle(size: 28),
                SizedBox(width: 8),
                SkeletonBones.rect(width: 140, height: 18),
              ],
            ),
            const SizedBox(height: 8),
            const SkeletonBones.rect(width: 100, height: 12),
            const SizedBox(height: 16),

            // ── CA e PV ──────────────────────────────────────────────
            Row(
              children: const [
                SkeletonBones.rect(width: 96, height: 52, borderRadius: 12),
                SizedBox(width: 12),
                SkeletonBones.rect(width: 96, height: 52, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 20),

            // ── Deslocamento ─────────────────────────────────────────
            const SkeletonBones.rect(width: 130, height: 16),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                SkeletonBones.rect(width: 64, height: 26, borderRadius: 14),
                SkeletonBones.rect(width: 64, height: 26, borderRadius: 14),
              ],
            ),
            const SizedBox(height: 24),

            // ── Ações ────────────────────────────────────────────────
            const SkeletonBones.rect(width: 70, height: 16),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: SkeletonBones.rect(
                  width: double.infinity,
                  height: 60,
                  borderRadius: 12,
                ),
              ),
            ),
          ],
        ),
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
