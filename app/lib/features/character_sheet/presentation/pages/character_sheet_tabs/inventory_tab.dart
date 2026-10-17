import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';
import 'package:crit_sense/features/compendium/presentation/pages/equipments_screen.dart';

import '../../../domain/entities/character.dart';
import '../../../domain/entities/coins.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../../domain/rules/equipment_rules.dart';
import '../../bloc/character_bloc.dart';
import '../../bloc/inventory_bloc.dart';
import '../../widgets/number_edit_dialog.dart';

/// Aba "Inventário" da ficha: carga, moedas e itens (quantidade, peso,
/// equipado e sintonia).
///
/// Os itens ficam no [InventoryBloc], criado pela tela da ficha (a aba
/// Status & Combate também usa os itens equipados). As moedas ficam no
/// [Character] ([CharacterBloc]).
class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      buildWhen: (previous, current) => !identical(
        previous.findCharacter(character.id),
        current.findCharacter(character.id),
      ),
      builder: (context, characterState) {
        final live = characterState.findCharacter(character.id) ?? character;
        return BlocConsumer<InventoryBloc, InventoryState>(
          listenWhen: (previous, current) =>
              current.errorMessage != null &&
              current.status != InventoryStatus.failure,
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
          builder: (context, state) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LoadCard(character: live, items: state.items),
              const SizedBox(height: 10),
              _CoinsCard(character: live),
              const SizedBox(height: 16),
              _ItemsHeader(character: live, items: state.items),
              const Divider(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildItems(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItems(BuildContext context, InventoryState state) {
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
                  LoadInventoryEvent(character.id),
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      case InventoryStatus.success:
        if (state.items.isEmpty) {
          return const Padding(
            key: ValueKey('empty'),
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Nenhum item no inventário.'),
          );
        }
        return Column(
          key: const ValueKey('loaded'),
          children: [
            for (final item in state.items) _InventoryItemTile(item: item),
          ],
        );
    }
  }
}

String _formatWeight(double pounds) {
  final rounded = pounds.toStringAsFixed(pounds % 1 == 0 ? 0 : 1);
  return '$rounded lb';
}

class _LoadCard extends StatelessWidget {
  const _LoadCard({required this.character, required this.items});

  final Character character;
  final List<InventoryItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carried = carriedWeight(items, character.coins);
    final capacity = carryingCapacity(character);
    final ratio = capacity == 0 ? 1.0 : (carried / capacity).clamp(0.0, 1.0);
    final overloaded = carried > capacity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const DnDIcon(
                  assetPath: 'assets/icons/entity/pack.svg',
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Carga', style: theme.textTheme.titleSmall),
                ),
                Text(
                  '${_formatWeight(carried)} / ${_formatWeight(capacity.toDouble())}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: overloaded ? theme.colorScheme.error : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ratio,
              color: overloaded ? theme.colorScheme.error : null,
            ),
            if (overloaded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Acima da capacidade de carga (FOR × 15).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoinsCard extends StatelessWidget {
  const _CoinsCard({required this.character});

  final Character character;

  Future<void> _edit(BuildContext context, Coin coin) async {
    final bloc = context.read<CharacterBloc>();
    final amount = await showNumberEditDialog(
      context,
      title: '${coin.label} (${coin.abbreviation})',
      initialValue: character.coins.of(coin),
    );
    if (amount != null) bloc.add(SetCoinsEvent(character.id, coin, amount));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = character.coins.totalInGold;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Moedas', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final coin in Coin.values.reversed)
                  ActionChip(
                    tooltip: 'Editar ${coin.label}',
                    label: Text(
                      '${character.coins.of(coin)} ${coin.abbreviation}',
                    ),
                    onPressed: () => _edit(context, coin),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${total.toStringAsFixed(total % 1 == 0 ? 0 : 2)} PO',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsHeader extends StatelessWidget {
  const _ItemsHeader({required this.character, required this.items});

  final Character character;
  final List<InventoryItem> items;

  void _openCompendium(BuildContext context) {
    final bloc = context.read<InventoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EquipmentsScreen()),
    ).then((_) => bloc.add(LoadInventoryEvent(character.id)));
  }

  Future<void> _addCustom(BuildContext context) async {
    final bloc = context.read<InventoryBloc>();
    final item = await showDialog<InventoryItem>(
      context: context,
      builder: (_) => _CustomItemDialog(characterId: character.id),
    );
    if (item != null) bloc.add(SaveInventoryItemEvent(item));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Itens', style: theme.textTheme.titleMedium)),
            Text(
              'Sintonia: ${attunedCount(items)}/$maxAttunedItems',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _openCompendium(context),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Do compêndio'),
            ),
            OutlinedButton.icon(
              onPressed: () => _addCustom(context),
              icon: const Icon(Icons.add),
              label: const Text('Item personalizado'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Formulário de item criado à mão (fora do compêndio).
class _CustomItemDialog extends StatefulWidget {
  const _CustomItemDialog({required this.characterId});

  final String characterId;

  @override
  State<_CustomItemDialog> createState() => _CustomItemDialogState();
}

class _CustomItemDialogState extends State<_CustomItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _weight = TextEditingController(text: '0');
  bool _requiresAttunement = false;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final id = const Uuid().v4();
    Navigator.pop(
      context,
      InventoryItem(
        id: id,
        characterId: widget.characterId,
        itemIndex: '${InventoryItem.customIndexPrefix}$id',
        name: _name.text.trim(),
        equipmentCategory: 'Personalizado',
        quantity: int.parse(_quantity.text),
        weight: double.parse(_weight.text.replaceAll(',', '.')),
        requiresAttunement: _requiresAttunement,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Item personalizado'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório.'
                    : null,
              ),
              TextFormField(
                controller: _quantity,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1
                    ? 'Informe 1 ou mais.'
                    : null,
              ),
              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(
                  labelText: 'Peso de cada unidade (lb)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final value = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return value == null || value < 0 ? 'Informe o peso.' : null;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Exige sintonia'),
                value: _requiresAttunement,
                onChanged: (value) =>
                    setState(() => _requiresAttunement = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Adicionar')),
      ],
    );
  }
}

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

  /// Ícone temático do item; `entity/loot.svg` cobre o que não tem ícone
  /// próprio.
  String get _iconAsset {
    if (item.isWeapon) return 'assets/icons/entity/weapon.svg';
    if (item.armorCategory != null) return 'assets/icons/entity/armor.svg';
    if (item.requiresAttunement) return 'assets/icons/entity/magic-item.svg';
    return switch (item.equipmentCategory.toLowerCase()) {
      'weapon' => 'assets/icons/entity/weapon.svg',
      'armor' => 'assets/icons/entity/armor.svg',
      'tools' => 'assets/icons/entity/tool.svg',
      _ => 'assets/icons/entity/loot.svg',
    };
  }

  String get _details {
    final parts = <String>[
      if (item.quantity > 1) '×${item.quantity}',
      if (item.weight > 0) _formatWeight(item.totalWeight),
      if (item.isWeapon)
        '${item.damageDice} ${damageTypeLabel(item.damageType)}',
      if (item.armorCategory != null)
        item.isShield
            ? 'Escudo (+${item.armorBase ?? 2})'
            : 'CA ${item.armorBase}',
      if (!item.detailsLoaded) 'dados do compêndio pendentes',
    ];
    return parts.isEmpty ? item.equipmentCategory : parts.join(' · ');
  }

  void _showActions(BuildContext context) {
    final bloc = context.read<InventoryBloc>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                item.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(_details),
            ),
            if (item.isEquippable)
              ListTile(
                leading: Icon(
                  item.equipped ? Icons.back_hand_outlined : Icons.back_hand,
                ),
                title: Text(item.equipped ? 'Desequipar' : 'Equipar'),
                onTap: () {
                  bloc.add(ToggleEquippedEvent(item));
                  Navigator.pop(sheetContext);
                },
              ),
            if (item.requiresAttunement)
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(item.attuned ? 'Desfazer sintonia' : 'Sintonizar'),
                onTap: () {
                  bloc.add(ToggleAttunedEvent(item));
                  Navigator.pop(sheetContext);
                },
              ),
            ListTile(
              leading: const Icon(Icons.numbers),
              title: const Text('Quantidade'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Diminuir',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      bloc.add(SetItemQuantityEvent(item, item.quantity - 1));
                      Navigator.pop(sheetContext);
                    },
                  ),
                  Text('${item.quantity}'),
                  IconButton(
                    tooltip: 'Aumentar',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      bloc.add(SetItemQuantityEvent(item, item.quantity + 1));
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Remover do inventário'),
              onTap: () {
                bloc.add(DeleteInventoryItemEvent(item));
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: DnDIcon(assetPath: _iconAsset, size: 24),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_details, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (item.equipped)
              Tooltip(
                message: 'Equipado',
                child: Icon(Icons.back_hand, color: theme.colorScheme.primary),
              ),
            if (item.attuned)
              Tooltip(
                message: 'Sintonizado',
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.tertiary,
                ),
              ),
          ],
        ),
        onTap: () => _showActions(context),
      ),
    );
  }
}

/// Nome em português dos tipos de dano das armas do SRD.
String damageTypeLabel(String? type) => switch (type?.toLowerCase()) {
  'slashing' => 'cortante',
  'piercing' => 'perfurante',
  'bludgeoning' => 'contundente',
  null => '',
  _ => type!.toLowerCase(),
};
