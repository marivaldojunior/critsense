import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../../../character_sheet/domain/entities/inventory_item.dart';
import '../../../character_sheet/presentation/bloc/character_bloc.dart';
import '../../domain/entities/equipment_summary.dart';
import '../bloc/equipment_bloc.dart';

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
class EquipmentsScreen extends StatelessWidget {
  const EquipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EquipmentBloc>()..add(const LoadEquipmentsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Equipamentos')),
        body: BlocBuilder<EquipmentBloc, EquipmentState>(
          builder: (context, state) {
            return switch (state) {
              EquipmentInitial() => const SizedBox.shrink(),
              EquipmentLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              EquipmentLoaded(:final equipments) when equipments.isEmpty =>
                const Center(child: Text('Nenhum equipamento encontrado.')),
              EquipmentLoaded(:final equipments) => ListView.builder(
                itemCount: equipments.length,
                itemBuilder: (context, index) {
                  final equipment = equipments[index];
                  return _EquipmentTile(equipment: equipment);
                },
              ),
              EquipmentError(:final message) => Center(
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
            };
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
      title: Text(equipment.name),
      subtitle: Text(
        equipment.index,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: () => _showCharacterPicker(context),
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
                        title: Text(character.name),
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
