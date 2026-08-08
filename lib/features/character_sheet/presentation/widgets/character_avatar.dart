import 'dart:io';

import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../domain/entities/character.dart';

/// Classes com ícone dedicado em `assets/icons/class/` — mesma lista usada
/// pelo dropdown de criação em [CharacterFormScreen], mantida aqui para que
/// o avatar de fallback (sem foto) só aponte para assets que existem.
const _knownClassIcons = {
  'artificer',
  'barbarian',
  'bard',
  'cleric',
  'druid',
  'fighter',
  'monk',
  'paladin',
  'ranger',
  'rogue',
  'sorcerer',
  'warlock',
  'wizard',
};

String? _classIconAsset(String characterClass) {
  final key = characterClass.toLowerCase();
  if (!_knownClassIcons.contains(key)) return null;
  return 'assets/icons/class/$key.svg';
}

/// Avatar de um personagem, compartilhado entre a listagem e a ficha para
/// habilitar a transição [Hero] `'character-avatar-${character.id}'` entre
/// as duas telas.
///
/// Exibe a foto do personagem quando [Character.avatarPath] está definido;
/// caso contrário, cai no ícone temático da classe (ou um ícone genérico de
/// pessoa, se a classe não tiver asset dedicado).
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.character, this.radius = 22});

  final Character character;

  /// Raio do [CircleAvatar]; controla também o tamanho do ícone interno.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarPath = character.avatarPath;
    final classIconAsset = _classIconAsset(character.characterClass);

    return Hero(
      tag: 'character-avatar-${character.id}',
      child: CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: avatarPath != null
            ? FileImage(File(avatarPath))
            : null,
        child: avatarPath != null
            ? null
            : (classIconAsset != null
                  ? DnDIcon(
                      assetPath: classIconAsset,
                      size: radius,
                      color: theme.colorScheme.primary,
                    )
                  : Icon(Icons.person, size: radius, color: theme.colorScheme.primary)),
      ),
    );
  }
}
