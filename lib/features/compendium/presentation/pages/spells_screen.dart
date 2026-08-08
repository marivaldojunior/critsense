import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../bloc/compendium_bloc.dart';
import 'spell_detail_screen.dart';

/// Tela de listagem de magias do compêndio do D&D 5e.
class SpellsScreen extends StatelessWidget {
  const SpellsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // O operador de cascata `..` do Dart permite encadear chamadas no mesmo
      // objeto sem quebrá-lo em variável separada. Aqui cria o BLoC e já
      // dispara LoadSpellsEvent na mesma expressão — equivalente ao padrão
      // builder/fluent do C#: `new CompendiumBloc().Also { it.add(...) }`.
      create: (_) => sl<CompendiumBloc>()..add(const LoadSpellsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Compêndio de Magias')),
        body: BlocBuilder<CompendiumBloc, CompendiumState>(
          builder: (context, state) {
            return switch (state) {
              CompendiumInitial() => const SizedBox.shrink(),
              CompendiumLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              CompendiumLoaded(:final spells) when spells.isEmpty =>
                const Center(child: Text('Nenhuma magia encontrada.')),
              CompendiumLoaded(:final spells) => ListView.builder(
                itemCount: spells.length,
                itemBuilder: (context, index) {
                  final spell = spells[index];
                  return ListTile(
                    leading: const DnDIcon(
                      assetPath: 'assets/icons/game/spell.svg',
                      size: 26,
                    ),
                    title: Text(spell.name),
                    subtitle: Text(
                      spell.index,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SpellDetailScreen(spellIndex: spell.index),
                      ),
                    ),
                  );
                },
              ),
              CompendiumError(:final message) => Center(
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
