import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../bloc/compendium_bloc.dart';
import '../widgets/compendium_feedback_state.dart';
import '../widgets/compendium_list_skeleton.dart';
import '../widgets/compendium_search_bar.dart';
import '../widgets/filter_chip_row.dart';
import 'spell_detail_screen.dart';

/// Opções do filtro rápido de nível — Truque (nível 0) até nível 9.
const _levelOptions = [
  FilterChipOption(label: 'Truque', value: 0),
  FilterChipOption(label: 'Nível 1', value: 1),
  FilterChipOption(label: 'Nível 2', value: 2),
  FilterChipOption(label: 'Nível 3', value: 3),
  FilterChipOption(label: 'Nível 4', value: 4),
  FilterChipOption(label: 'Nível 5', value: 5),
  FilterChipOption(label: 'Nível 6', value: 6),
  FilterChipOption(label: 'Nível 7', value: 7),
  FilterChipOption(label: 'Nível 8', value: 8),
  FilterChipOption(label: 'Nível 9', value: 9),
];

/// Tela de listagem de magias do compêndio do D&D 5e, com busca por nome e
/// filtro rápido de nível.
///
/// [StatefulWidget] apenas para possuir e descartar o [TextEditingController]
/// da [CompendiumSearchBar] — todo o resto do estado vive no [CompendiumBloc].
class SpellsScreen extends StatefulWidget {
  const SpellsScreen({super.key});

  @override
  State<SpellsScreen> createState() => _SpellsScreenState();
}

class _SpellsScreenState extends State<SpellsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            final bloc = context.read<CompendiumBloc>();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: CompendiumSearchBar(
                    controller: _searchController,
                    hintText: 'Buscar magias...',
                    onChanged: (query) =>
                        bloc.add(SearchQueryChanged(query)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FilterChipRow(
                    filterType: 'level',
                    options: _levelOptions,
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
                      CompendiumStatus.initial ||
                      CompendiumStatus.loading => const CompendiumListSkeleton(
                        key: ValueKey('loading'),
                        hasTrailing: true,
                      ),
                      CompendiumStatus.success when state.spells.isEmpty =>
                        const CompendiumFeedbackState.empty(
                          key: ValueKey('empty'),
                          message: 'Nenhuma magia encontrada.',
                        ),
                      CompendiumStatus.success => ListView.builder(
                        key: const ValueKey('loaded'),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: state.spells.length,
                        itemBuilder: (context, index) {
                          final spell = state.spells[index];
                          return ListTile(
                            leading: const DnDIcon(
                              assetPath: 'assets/icons/game/spell.svg',
                              size: 26,
                            ),
                            title: Text(
                              spell.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                      CompendiumStatus.failure => CompendiumFeedbackState.error(
                        key: const ValueKey('error'),
                        message: state.errorMessage ?? 'Erro ao carregar magias.',
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
