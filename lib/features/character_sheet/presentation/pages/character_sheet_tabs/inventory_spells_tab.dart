import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/di/injection_container.dart';

import '../../../domain/entities/inventory_item.dart';
import '../../../domain/usecases/get_character_inventory_usecase.dart';

/// Aba "Inventário & Magias" da ficha.
///
/// O inventário já é uma feature persistida ([InventoryItem]/
/// [GetCharacterInventoryUseCase]), então esta aba o carrega e exibe. Magias
/// por personagem ainda não existem no domínio — só o compêndio de magias
/// (feature `compendium`), sem vínculo com a ficha — por isso a seção
/// "Magias" é, por ora, um estado informativo, e não uma lista vazia
/// disfarçada de "carregando".
class InventorySpellsTab extends StatefulWidget {
  const InventorySpellsTab({super.key, required this.characterId});

  final String characterId;

  @override
  State<InventorySpellsTab> createState() => _InventorySpellsTabState();
}

class _InventorySpellsTabState extends State<InventorySpellsTab> {
  final _getInventory = sl<GetCharacterInventoryUseCase>();

  late Future<List<InventoryItem>> _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _getInventory(widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Inventário', style: theme.textTheme.titleMedium),
        const Divider(),
        FutureBuilder<List<InventoryItem>>(
          future: _inventoryFuture,
          builder: (context, snapshot) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildInventoryBody(snapshot),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('Magias', style: theme.textTheme.titleMedium),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              DnDIcon(
                assetPath: 'assets/icons/game/spell.svg',
                size: 22,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'A vinculação de magias por personagem ainda não está '
                  'disponível — consulte o Compêndio de Magias na tela '
                  'inicial para pesquisar magias.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Resolve o corpo da seção de Inventário a partir do [snapshot] do
  /// [FutureBuilder] — usado como `child` do [AnimatedSwitcher] em [build],
  /// daí cada branch carregar uma [ValueKey] distinta para o Flutter
  /// detectar a troca e disparar o fade de 300ms.
  Widget _buildInventoryBody(AsyncSnapshot<List<InventoryItem>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const _InventorySkeleton(key: ValueKey('loading'));
    }

    final items = snapshot.data ?? const [];
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
        for (final item in items) _InventoryItemTile(item: item),
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
  const _InventoryItemTile({required this.item});

  final InventoryItem item;

  /// Ícone temático por categoria de equipamento; `entity/pack.svg` cobre
  /// categorias sem ícone dedicado (ex: "Adventuring Gear", "Tool").
  String get _iconAsset => switch (item.equipmentCategory.toLowerCase()) {
    'weapon' => 'assets/icons/entity/weapon.svg',
    'armor' => 'assets/icons/entity/armor.svg',
    _ => 'assets/icons/entity/pack.svg',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: DnDIcon(assetPath: _iconAsset, size: 24),
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(item.equipmentCategory),
      ),
    );
  }
}
