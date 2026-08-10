import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/auth/presentation/screens/login_screen.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_list_screen.dart';
import 'package:crit_sense/features/compendium/presentation/pages/bestiary_screen.dart';
import 'package:crit_sense/features/compendium/presentation/pages/equipments_screen.dart';
import 'package:crit_sense/features/compendium/presentation/pages/spells_screen.dart';
import 'package:crit_sense/features/dice_roller/presentation/pages/dice_screen.dart';

/// Menu lateral global do CritSense.
///
/// Espelha exatamente os cards de feature definidos em `_features` na
/// `HomeScreen` (mesmo título, mesmo asset SVG e mesma tela de destino) —
/// qualquer feature nova adicionada lá deve ganhar uma entrada aqui também,
/// já que as duas listas são mantidas separadas propositalmente (a Home usa
/// cards em grid com subtítulo; o Drawer usa uma lista compacta).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _items = [
    _DrawerItem(
      title: 'Dados',
      iconAsset: 'assets/icons/dice/d20.svg',
      builder: DiceScreen.new,
    ),
    _DrawerItem(
      title: 'Personagens',
      iconAsset: 'assets/icons/game/character.svg',
      builder: CharacterListScreen.new,
    ),
    _DrawerItem(
      title: 'Bestiário',
      iconAsset: 'assets/icons/game/monster.svg',
      builder: BestiaryScreen.new,
    ),
    _DrawerItem(
      title: 'Equipamentos',
      iconAsset: 'assets/icons/entity/weapon.svg',
      builder: EquipmentsScreen.new,
    ),
    _DrawerItem(
      title: 'Magias',
      iconAsset: 'assets/icons/entity/spellbook.svg',
      builder: SpellsScreen.new,
    ),
  ];

  /// Fecha o drawer e volta até a primeira rota da pilha (a `HomeScreen`
  /// pós-login) em vez de um `pushReplacement`/`pushAndRemoveUntil` que a
  /// recriaria — a `HomeScreen` exige `onToggleTheme`, callback que o
  /// Drawer não recebe. Voltar até a rota original reaproveita a instância
  /// já existente, com o callback correto, e ainda assim "não empilha
  /// telas infinitamente": o efeito prático é o mesmo de um
  /// `popUntil` + replace.
  void _goHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _navigateTo(BuildContext context, WidgetBuilder builder) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  void _logout(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const DnDIcon(assetPath: 'assets/icons/dice/d20.svg', size: 48),
                const SizedBox(height: 12),
                Text('CritSense', style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          ListTile(
            leading: const DnDIcon(
              assetPath: 'assets/icons/location/tavern.svg',
              size: 28,
            ),
            title: const Text('Início'),
            onTap: () => _goHome(context),
          ),
          for (final item in _items)
            ListTile(
              leading: DnDIcon(assetPath: item.iconAsset, size: 28),
              title: Text(item.title),
              onTap: () => _navigateTo(context, (_) => item.builder()),
            ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Sair',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

/// Descreve uma entrada do Drawer que espelha um card da `HomeScreen`.
class _DrawerItem {
  final String title;
  final String iconAsset;
  final Widget Function() builder;

  const _DrawerItem({
    required this.title,
    required this.iconAsset,
    required this.builder,
  });
}
