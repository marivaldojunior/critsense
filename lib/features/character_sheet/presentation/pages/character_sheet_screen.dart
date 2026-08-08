import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/character.dart';
import '../widgets/character_avatar.dart';
import 'character_sheet_tabs/inventory_spells_tab.dart';
import 'character_sheet_tabs/status_combat_tab.dart';
import 'character_sheet_tabs/traits_lore_tab.dart';
import 'session_notes_screen.dart';

/// Ficha completa de um personagem: as três abas espelham os blocos da
/// primeira página da ficha oficial de D&D 5e — Status & Combate,
/// Características & Lore e Inventário & Magias.
///
/// [StatelessWidget]: a única fonte de estado mutável é o `CharacterBloc`
/// (via os eventos de alternar proficiência e salvar personagem) e o
/// estado interno de cada aba; esta tela em si só monta o
/// [DefaultTabController] e passa o [character] recebido adiante — nunca
/// precisa se reconstruir sozinha.
class CharacterSheetScreen extends StatelessWidget {
  const CharacterSheetScreen({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CharacterAvatar(character: character, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(character.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const DnDIcon(
                assetPath: 'assets/icons/entity/book.svg',
                size: 26,
              ),
              tooltip: 'Diário de Campanha',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionNotesScreen(
                    characterId: character.id,
                    characterName: character.name,
                    avatarPath: character.avatarPath,
                  ),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Status & Combate'),
              Tab(text: 'Características & Lore'),
              Tab(text: 'Inventário & Magias'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StatusCombatTab(character: character),
            TraitsLoreTab(character: character),
            InventorySpellsTab(characterId: character.id),
          ],
        ),
      ),
    );
  }
}
