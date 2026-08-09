import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';

import '../../../../di/injection_container.dart';
import '../../domain/entities/equipment_detail.dart';
import '../bloc/equipment_detail_bloc.dart';
import '../widgets/compendium_feedback_state.dart';

/// Tela de detalhes de um equipamento do compêndio.
///
/// Recebe [equipmentIndex] via construtor, seguindo o mesmo padrão de
/// [SpellDetailScreen]: o índice é passado diretamente ao widget, sem
/// depender de um roteador centralizado tipado.
class EquipmentDetailScreen extends StatelessWidget {
  /// Índice do equipamento na API (ex: "longsword").
  final String equipmentIndex;

  const EquipmentDetailScreen({super.key, required this.equipmentIndex});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EquipmentDetailBloc>()
        ..add(LoadEquipmentDetailEvent(equipmentIndex)),
      child: BlocBuilder<EquipmentDetailBloc, EquipmentDetailState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state is EquipmentDetailLoaded
                    ? state.equipment.name
                    : 'Detalhes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (state) {
                EquipmentDetailInitial() =>
                  const SizedBox.shrink(key: ValueKey('initial')),
                EquipmentDetailLoading() =>
                  const _EquipmentDetailSkeleton(key: ValueKey('loading')),
                EquipmentDetailLoaded(:final equipment) => _EquipmentDetailBody(
                  key: const ValueKey('loaded'),
                  equipment: equipment,
                ),
                EquipmentDetailError(:final message) =>
                  CompendiumFeedbackState.error(
                    key: const ValueKey('error'),
                    message: message,
                  ),
              },
            ),
          );
        },
      ),
    );
  }
}

/// Corpo da tela com todos os detalhes do equipamento.
class _EquipmentDetailBody extends StatelessWidget {
  final EquipmentDetail equipment;

  const _EquipmentDetailBody({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(equipment.equipmentCategory),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 16),

          // ── Atributos rápidos ────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                iconAsset: 'assets/icons/entity/loot.svg',
                label: 'Custo',
                value: '${equipment.cost.quantity} ${equipment.cost.unit}',
              ),
              _StatCard(
                iconAsset: 'assets/icons/entity/pack.svg',
                label: 'Peso',
                value: '${equipment.weight} lb',
              ),
              if (equipment.damage case final damage?)
                _StatCard(
                  iconAsset: 'assets/icons/damage/${damage.damageTypeIndex}.svg',
                  label: 'Dano',
                  value: '${damage.dice} ${damage.damageTypeName}',
                ),
              if (equipment.range case final range?)
                _StatCard(
                  iconAsset: 'assets/icons/attribute/range.svg',
                  label: 'Alcance',
                  value: range.long != null
                      ? '${range.normal}/${range.long} pés'
                      : '${range.normal} pés',
                ),
              if (equipment.armorClass case final armorClass?)
                _StatCard(
                  iconAsset: 'assets/icons/attribute/ac.svg',
                  label: 'CA',
                  value: '$armorClass',
                ),
            ],
          ),

          // ── Descrição ─────────────────────────────────────────────────
          if (equipment.desc.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Descrição', style: theme.textTheme.titleMedium),
            const Divider(),
            const SizedBox(height: 4),
            ...equipment.desc.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(paragraph, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Esqueleto de carregamento que imita o layout de detalhes do equipamento:
/// chip de categoria, blocos de status e linhas de descrição.
class _EquipmentDetailSkeleton extends StatelessWidget {
  const _EquipmentDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBones.rect(width: 100, height: 26, borderRadius: 14),
            const SizedBox(height: 16),
            Row(
              children: const [
                SkeletonBones.rect(width: 96, height: 52, borderRadius: 12),
                SizedBox(width: 12),
                SkeletonBones.rect(width: 96, height: 52, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonBones.rect(width: 100, height: 16),
            const SizedBox(height: 12),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SkeletonBones.rect(
                  width: index == 3 ? 150 : double.infinity,
                  height: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card compacto que exibe um atributo do equipamento com ícone temático.
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
