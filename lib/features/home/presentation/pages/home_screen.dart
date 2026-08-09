import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/app_drawer.dart';
import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_list_screen.dart';
import 'package:crit_sense/features/compendium/presentation/pages/bestiary_screen.dart';
import 'package:crit_sense/features/compendium/presentation/pages/equipments_screen.dart';
import 'package:crit_sense/features/compendium/presentation/pages/spells_screen.dart';
import 'package:crit_sense/features/dice_roller/presentation/pages/dice_screen.dart';

/// Tela inicial (hub) do CritSense.
///
/// Ponto único de acesso a todas as features do app. Cada card navega para
/// a tela correspondente via [Navigator.push]. BLoCs compartilhados entre
/// features (ex: `CharacterBloc`, usado tanto em Personagens quanto em
/// Equipamentos) são fornecidos na raiz do app em `main.dart` — acima do
/// `Navigator` — então toda tela empurrada a partir daqui já os herda
/// automaticamente via `context.read`, sem precisar redeclará-los aqui.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onToggleTheme});

  /// Alterna entre os temas claro e escuro. Fornecido pela raiz do app
  /// ([CritSenseApp]), que é quem detém o [ThemeMode] atual.
  final VoidCallback onToggleTheme;

  static final List<_FeatureItem> _features = [
    _FeatureItem(
      title: 'Dados',
      subtitle: 'Monte um pool e role múltiplos dados',
      iconAsset: 'assets/icons/dice/d20.svg',
      builder: (_) => const DiceScreen(),
    ),
    _FeatureItem(
      title: 'Personagens',
      subtitle: 'Fichas, inventário e notas de sessão',
      iconAsset: 'assets/icons/game/character.svg',
      builder: (_) => const CharacterListScreen(),
    ),
    _FeatureItem(
      title: 'Bestiário',
      subtitle: 'Consulte monstros do compêndio',
      iconAsset: 'assets/icons/game/monster.svg',
      builder: (_) => const BestiaryScreen(),
    ),
    _FeatureItem(
      title: 'Equipamentos',
      subtitle: 'Adicione itens ao inventário',
      iconAsset: 'assets/icons/entity/weapon.svg',
      builder: (_) => const EquipmentsScreen(),
    ),
    _FeatureItem(
      title: 'Magias',
      subtitle: 'Explore o compêndio de magias',
      iconAsset: 'assets/icons/entity/spellbook.svg',
      builder: (_) => const SpellsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('CritSense'),
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: isDark ? 'Ativar tema claro' : 'Ativar tema escuro',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _features.length,
          itemBuilder: (context, index) =>
              _FeatureCard(feature: _features[index]),
        ),
      ),
    );
  }
}

/// Descreve um card de feature: rótulo, ícone e como construir sua tela.
class _FeatureItem {
  final String title;
  final String subtitle;
  final String iconAsset;
  final WidgetBuilder builder;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.builder,
  });
}

/// Card individual do grid da tela inicial.
class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: feature.builder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DnDIcon(
                assetPath: feature.iconAsset,
                size: 40,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                feature.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
