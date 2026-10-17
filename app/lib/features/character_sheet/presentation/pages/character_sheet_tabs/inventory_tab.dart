import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/di/injection_container.dart';

import '../../../domain/entities/inventory_item.dart';
import '../../bloc/inventory_bloc.dart';

/// Aba "Inventário" da ficha.
///
/// O inventário é persistido em sua própria tabela relacional
/// ([InventoryItem]), com o estado no [InventoryBloc] criado por esta aba.
/// As magias ficam na aba "Magias" (`SpellsTab`).
class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<InventoryBloc>(
      create: (_) => sl<InventoryBloc>()..add(LoadInventoryEvent(characterId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Inventário', style: theme.textTheme.titleMedium),
          const Divider(),
          BlocConsumer<InventoryBloc, InventoryState>(
            listenWhen: (previous, current) =>
                current.errorMessage != null &&
                current.status != InventoryStatus.failure,
            listener: (context, state) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            },
            builder: (context, state) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildInventoryBody(context, state),
            ),
          ),
        ],
      ),
    );
  }

  /// Resolve o corpo da seção de Inventário a partir do [state] — usado
  /// como `child` do [AnimatedSwitcher] em [build], daí cada branch carregar
  /// uma [ValueKey] distinta para o Flutter detectar a troca e disparar o
  /// fade de 300ms.
  Widget _buildInventoryBody(BuildContext context, InventoryState state) {
    switch (state.status) {
      case InventoryStatus.initial:
      case InventoryStatus.loading:
        return const _InventorySkeleton(key: ValueKey('loading'));
      case InventoryStatus.failure:
        return Padding(
          key: const ValueKey('failure'),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Não foi possível carregar o inventário.'),
              ),
              TextButton(
                onPressed: () => context.read<InventoryBloc>().add(
                  LoadInventoryEvent(characterId),
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      case InventoryStatus.success:
        break;
    }

    final items = state.items;
    if (items.isEmpty) {
      return const Padding(
        key: ValueKey('empty'),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Nenhum item no inventário.'),
      );
    }

    return Column(
      key: const ValueKey('loaded'),
      children: [
        for (final item in items)
          _InventoryItemTile(
            item: item,
            onDelete: () => context.read<InventoryBloc>().add(
              DeleteInventoryItemEvent(item),
            ),
          ),
      ],
    );
  }
}

/// Esqueleto de carregamento que imita a silhueta de [_InventoryItemTile]:
/// mesmo [Card]/[ListTile] real, só trocando o conteúdo por [SkeletonBones].
class _InventorySkeleton extends StatelessWidget {
  const _InventorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          3,
          (_) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const SkeletonBones.circle(size: 24),
              title: const Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBones.rect(width: 140, height: 13),
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: SkeletonBones.rect(width: 80, height: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  const _InventoryItemTile({required this.item, required this.onDelete});

  final InventoryItem item;
  final VoidCallback onDelete;

  /// Ícone temático por categoria de equipamento; `entity/pack.svg` cobre
  /// categorias sem ícone dedicado (ex: "Adventuring Gear", "Tool").
  String get _iconAsset => switch (item.equipmentCategory.toLowerCase()) {
    'weapon' => 'assets/icons/entity/weapon.svg',
    'armor' => 'assets/icons/entity/armor.svg',
    _ => 'assets/icons/entity/loot.svg',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: DnDIcon(assetPath: _iconAsset, size: 24),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item.equipmentCategory),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remover do inventário',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
