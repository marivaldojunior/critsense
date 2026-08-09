import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../bloc/monster_bloc.dart';
import '../widgets/compendium_feedback_state.dart';
import '../widgets/compendium_list_skeleton.dart';
import '../widgets/compendium_search_bar.dart';
import '../widgets/filter_chip_row.dart';
import 'monster_detail_screen.dart';

/// Opções do filtro rápido de CR (Classe de Desafio) — valores comuns,
/// aceitos pela API como `double` direto (sem precisar formatar como fração).
const _challengeRatingOptions = [
  FilterChipOption(label: 'CR 1/8', value: 0.125),
  FilterChipOption(label: 'CR 1/4', value: 0.25),
  FilterChipOption(label: 'CR 1/2', value: 0.5),
  FilterChipOption(label: 'CR 1', value: 1),
  FilterChipOption(label: 'CR 2', value: 2),
  FilterChipOption(label: 'CR 5', value: 5),
  FilterChipOption(label: 'CR 10', value: 10),
  FilterChipOption(label: 'CR 15', value: 15),
  FilterChipOption(label: 'CR 20', value: 20),
];

/// Tela do Bestiário com scroll infinito paginado.
///
/// Usa [StatefulWidget] para gerenciar o ciclo de vida do [ScrollController],
/// cujo listener precisa ser registrado e liberado manualmente.
class BestiaryScreen extends StatefulWidget {
  const BestiaryScreen({super.key});

  @override
  State<BestiaryScreen> createState() => _BestiaryScreenState();
}

class _BestiaryScreenState extends State<BestiaryScreen> {
  /// Instância própria do BLoC — necessária porque [BlocProvider.value]
  /// não fecha o BLoC automaticamente; quem cria é quem descarta.
  late final MonsterBloc _bloc;

  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cria o BLoC via Service Locator e dispara o primeiro carregamento
    // com o operador de cascata `..` — equivalente ao encadeamento fluente
    // `builder.SetX().SetY()` do padrão Fluent Builder do C#.
    _bloc = sl<MonsterBloc>()..add(const FetchMonstersEvent());
    _scrollController.addListener(_onScroll);
  }

  /// Dispara [FetchMonstersEvent] ao atingir 90% do extent máximo da lista.
  ///
  /// `context.read<MonsterBloc>()` exigiria o [BuildContext] de um descendente
  /// do [BlocProvider]; como o provider é fornecido abaixo de [this.context]
  /// neste StatefulWidget, usamos a referência direta [_bloc] — semanticamente
  /// equivalente, sem a limitação de contexto de ancestral.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.9) {
      _bloc.add(const FetchMonstersEvent());
    }
  }

  /// Libera o controller e fecha o BLoC ao desmontar a tela.
  ///
  /// O `dispose` do [StatefulWidget] é análogo à interface `IDisposable` do C#
  /// e ao bloco `using` / `Dispose()`: ambos garantem a liberação determinística
  /// de recursos nativos quando o objeto sai de escopo. Omitir
  /// `_scrollController.dispose()` equivale a nunca chamar `Dispose()` em um
  /// `IDisposable` — o listener permanece ativo na engine, podendo disparar
  /// callbacks sobre um widget já desmontado e causar memory leaks e exceções
  /// `setState called after dispose`.
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Bestiário')),
        body: BlocBuilder<MonsterBloc, MonsterState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: CompendiumSearchBar(
                    controller: _searchController,
                    hintText: 'Buscar monstros...',
                    onChanged: (query) => _bloc.add(SearchQueryChanged(query)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FilterChipRow(
                    filterType: 'challengeRating',
                    options: _challengeRatingOptions,
                    activeFilters: state.activeFilters,
                    onToggle: (type, value) =>
                        _bloc.add(FilterToggled(type, value)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: switch (state.status) {
                      MonsterStatus.initial || MonsterStatus.loading =>
                        const CompendiumListSkeleton(key: ValueKey('loading')),
                      MonsterStatus.failure =>
                        const CompendiumFeedbackState.error(
                          key: ValueKey('error'),
                          message: 'Erro ao carregar o Bestiário.',
                        ),
                      MonsterStatus.success when state.monsters.isEmpty =>
                        const CompendiumFeedbackState.empty(
                          key: ValueKey('empty'),
                          message: 'Nenhum monstro encontrado.',
                        ),
                      MonsterStatus.success => ListView.builder(
                        key: const ValueKey('loaded'),
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        // +1 reserva espaço para o BottomLoader enquanto há mais páginas.
                        itemCount:
                            state.monsters.length +
                            (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= state.monsters.length) {
                            return const _BottomLoader();
                          }
                          final monster = state.monsters[index];
                          return ListTile(
                            leading: Hero(
                              tag: 'monster-icon-${monster.index}',
                              child: const DnDIcon(
                                assetPath: 'assets/icons/game/monster.svg',
                                size: 26,
                              ),
                            ),
                            title: Text(
                              monster.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              monster.index,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MonsterDetailScreen(
                                  monsterIndex: monster.index,
                                ),
                              ),
                            ),
                          );
                        },
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

/// Indicador de carregamento exibido na base da lista durante a paginação.
class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
