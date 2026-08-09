import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../../../character_sheet/domain/entities/inventory_item.dart';
import '../../../character_sheet/presentation/bloc/character_bloc.dart';
import '../../domain/entities/equipment_summary.dart';
import '../bloc/equipment_bloc.dart';
import '../widgets/compendium_feedback_state.dart';
import '../widgets/compendium_list_skeleton.dart';
import '../widgets/compendium_search_bar.dart';
import '../widgets/filter_chip_row.dart';
import 'equipment_detail_screen.dart';

/// Opções do filtro rápido de categoria — slugs reais de
/// `/api/equipment-categories` da API do D&D 5e.
const _categoryOptions = [
  FilterChipOption(label: 'Arma', value: 'weapon'),
  FilterChipOption(label: 'Armadura', value: 'armor'),
  FilterChipOption(label: 'Equip. de Aventureiro', value: 'adventuring-gear'),
  FilterChipOption(label: 'Ferramentas', value: 'tools'),
  FilterChipOption(label: 'Poções', value: 'potion'),
];

/// Tela de listagem de equipamentos do compêndio.
///
/// Comunicação Cross-Feature: ao tocar em um equipamento e selecionar um
/// personagem, esta tela do `compendium` dispara um [AddInventoryItemEvent]
/// diretamente no [CharacterBloc] da feature `character_sheet`.
///
/// No .NET com CQRS/MediatR, o equivalente seria publicar um Command:
/// `await _mediator.Send(new AddInventoryItemCommand(characterId, item))`.
/// O MediatR despacha o comando ao handler correto sem que o chamador
/// conheça a implementação — o mesmo princípio se aplica aqui: a tela de
/// equipamentos não sabe *como* o item é salvo, apenas envia o evento ao
/// BLoC responsável pelo estado de personagens.
class EquipmentsScreen extends StatefulWidget {
  const EquipmentsScreen({super.key});

  @override
  State<EquipmentsScreen> createState() => _EquipmentsScreenState();
}

class _EquipmentsScreenState extends State<EquipmentsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EquipmentBloc>()..add(const LoadEquipmentsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Equipamentos')),
        body: BlocBuilder<EquipmentBloc, EquipmentState>(
          builder: (context, state) {
            final bloc = context.read<EquipmentBloc>();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: CompendiumSearchBar(
                    controller: _searchController,
                    hintText: 'Buscar equipamentos...',
                    onChanged: (query) =>
                        bloc.add(SearchQueryChanged(query)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FilterChipRow(
                    filterType: 'equipmentCategory',
                    options: _categoryOptions,
                    activeFilters: state.activeFilters,
                    onToggle: (type, value) =>
                        bloc.add(FilterToggled(type, value)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: switch (state.status) {
                      EquipmentStatus.initial ||
                      EquipmentStatus.loading => const CompendiumListSkeleton(
                        key: ValueKey('loading'),
                        hasTrailing: true,
                      ),
                      EquipmentStatus.success when state.equipments.isEmpty =>
                        const CompendiumFeedbackState.empty(
                          key: ValueKey('empty'),
                          message: 'Nenhum equipamento encontrado.',
                        ),
                      EquipmentStatus.success => ListView.builder(
                        key: const ValueKey('loaded'),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: state.equipments.length,
                        itemBuilder: (context, index) {
                          final equipment = state.equipments[index];
                          return _EquipmentTile(equipment: equipment);
                        },
                      ),
                      EquipmentStatus.failure => CompendiumFeedbackState.error(
                        key: const ValueKey('error'),
                        message:
                            state.errorMessage ??
                            'Erro ao carregar equipamentos.',
                      ),
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ListTile de equipamento com BottomSheet de seleção de personagem.
class _EquipmentTile extends StatelessWidget {
  final EquipmentSummary equipment;

  const _EquipmentTile({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const DnDIcon(
        assetPath: 'assets/icons/entity/weapon.svg',
        size: 26,
      ),
      title: Text(
        equipment.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        equipment.index,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        tooltip: 'Adicionar a um personagem',
        onPressed: () => _showCharacterPicker(context),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EquipmentDetailScreen(equipmentIndex: equipment.index),
        ),
      ),
    );
  }

  /// Abre um BottomSheet para escolher em qual personagem adicionar o item.
  void _showCharacterPicker(BuildContext context) {
    // Captura o CharacterBloc antes de entrar no showModalBottomSheet, pois
    // o contexto do modal não tem acesso direto à árvore de widgets pai.
    final characterBloc = context.read<CharacterBloc>();

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return BlocBuilder<CharacterBloc, CharacterState>(
          // Usa o BLoC já existente no contexto pai via bloc:, sem criar outro.
          bloc: characterBloc,
          builder: (_, state) {
            if (state is! CharacterLoaded || state.characters.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Nenhum personagem disponível.')),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Adicionar a qual personagem?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.characters.length,
                    itemBuilder: (_, index) {
                      final character = state.characters[index];
                      return ListTile(
                        leading: const DnDIcon(
                          assetPath: 'assets/icons/game/character.svg',
                          size: 26,
                        ),
                        title: Text(
                          character.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${character.characterClass} • Nível ${character.level}',
                        ),
                        onTap: () {
                          final item = InventoryItem(
                            id: const Uuid().v4(),
                            characterId: character.id,
                            itemIndex: equipment.index,
                            name: equipment.name,
                            // A API de listagem não fornece categoria; valor
                            // padrão substituível ao buscar detalhes futuramente.
                            equipmentCategory: 'Unknown',
                          );

                          // Cross-feature: dispara o Command no BLoC de
                          // character_sheet a partir da feature compendium,
                          // sem acoplamento direto entre as duas features.
                          characterBloc.add(AddInventoryItemEvent(item));

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${equipment.name} adicionado a ${character.name}.',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
