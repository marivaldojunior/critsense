import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/character.dart';
import '../bloc/character_bloc.dart';
import '../widgets/character_avatar.dart';
import 'character_sheet_tabs/inventory_spells_tab.dart';
import 'character_sheet_tabs/status_combat_tab.dart';
import 'character_sheet_tabs/traits_lore_tab.dart';
import 'session_notes_screen.dart';

/// Percentual de PV (PV atual / PV máximo) em ou abaixo do qual a ficha
/// entra em estado "Low HP" e ganha o tema vermelho de alerta.
const _lowHpThreshold = 0.10;

/// Ficha completa de um personagem: as três abas espelham os blocos da
/// primeira página da ficha oficial de D&D 5e — Status & Combate,
/// Características & Lore e Inventário & Magias.
///
/// [StatelessWidget]: a única fonte de estado mutável é o `CharacterBloc`
/// (via os eventos de alternar proficiência e salvar personagem) e o
/// estado interno de cada aba; esta tela em si só monta o
/// [DefaultTabController] e passa o [character] recebido adiante — nunca
/// precisa se reconstruir sozinha.
///
/// A única exceção é o tema "Low HP": um [BlocBuilder] escuta o PV corrente
/// do personagem só para decidir se a ficha inteira (AppBar, FAB, bordas)
/// deve ganhar a paleta vermelha de alerta — as abas continuam recebendo o
/// [character] "congelado" que já recebiam, sem risco de resetar rascunhos
/// locais (ex: os campos de texto da aba Características & Lore).
class CharacterSheetScreen extends StatelessWidget {
  const CharacterSheetScreen({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      buildWhen: (previous, current) => !identical(
        previous.findCharacter(character.id),
        current.findCharacter(character.id),
      ),
      builder: (context, state) {
        final liveCharacter = state.findCharacter(character.id) ?? character;
        final hpRatio = liveCharacter.maxHitPoints > 0
            ? liveCharacter.currentHitPoints / liveCharacter.maxHitPoints
            : 1.0;
        final isLowHp =
            liveCharacter.maxHitPoints > 0 && hpRatio <= _lowHpThreshold;

        final sheet = _buildSheet(context);
        if (!isLowHp) return sheet;

        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: sheet,
        );
      },
    );
  }

  Widget _buildSheet(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CharacterAvatar(character: character, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  character.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
