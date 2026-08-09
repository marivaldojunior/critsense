import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/di/injection_container.dart';

import '../../../domain/entities/inventory_item.dart';
import '../../../domain/usecases/delete_inventory_item_usecase.dart';
import '../../../domain/usecases/get_character_inventory_usecase.dart';
import '../../bloc/character_bloc.dart';

/// Aba "Inventário & Magias" da ficha.
///
/// O inventário é uma feature persistida em sua própria tabela relacional
/// ([InventoryItem]/[GetCharacterInventoryUseCase], carregada localmente
/// via [FutureBuilder] e recarregada após cada remoção). Já as magias
/// vivem diretamente no [Character] (`character.spells`), então essa
/// seção escuta o [CharacterBloc] para refletir em tempo real qualquer
/// magia vinculada pelo Compêndio, sem precisar sair e voltar à ficha.
class InventorySpellsTab extends StatefulWidget {
  const InventorySpellsTab({super.key, required this.characterId});

  final String characterId;

  @override
  State<InventorySpellsTab> createState() => _InventorySpellsTabState();
}

class _InventorySpellsTabState extends State<InventorySpellsTab> {
  final _getInventory = sl<GetCharacterInventoryUseCase>();
  final _deleteInventoryItem = sl<DeleteInventoryItemUseCase>();

  late Future<List<InventoryItem>> _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _getInventory(widget.characterId);
  }

  /// Remove [item] do inventário e recarrega a lista para refletir a
  /// exclusão — mesmo padrão usado para excluir notas de sessão.
  Future<void> _removeInventoryItem(InventoryItem item) async {
    await _deleteInventoryItem(item.id);
    if (!mounted) return;
    setState(() {
      _inventoryFuture = _getInventory(widget.characterId);
    });
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
        _SpellsSection(characterId: widget.characterId),
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
        for (final item in items)
          _InventoryItemTile(
            item: item,
            onDelete: () => _removeInventoryItem(item),
          ),
      ],
    );
  }
}

/// Seção "Magias": lê `character.spells` ao vivo do [CharacterBloc] — os
/// nomes de magias vinculadas via Compêndio (ver [SpellDetailScreen])
/// aparecem aqui assim que persistidos, sem recarregar a tela.
class _SpellsSection extends StatelessWidget {
  const _SpellsSection({required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      buildWhen: (previous, current) => !identical(
        previous.findCharacter(characterId),
        current.findCharacter(characterId),
      ),
      builder: (context, state) {
        final spells = state.findCharacter(characterId)?.spells ?? const [];

        if (spells.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Nenhuma magia vinculada ainda.'),
          );
        }

        return Column(
          children: [
            for (final spell in spells)
              _SpellTile(
                name: spell,
                onDelete: () => context.read<CharacterBloc>().add(
                  RemoveSpellFromCharacterEvent(characterId, spell),
                ),
              ),
          ],
        );
      },
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

/// Item da lista de magias vinculadas ao personagem.
class _SpellTile extends StatelessWidget {
  const _SpellTile({required this.name, required this.onDelete});

  final String name;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const DnDIcon(
          assetPath: 'assets/icons/spell/evocation.svg',
          size: 24,
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remover magia',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
