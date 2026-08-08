import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

import '../../../../di/injection_container.dart';
import '../bloc/monster_bloc.dart';

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
            return switch (state.status) {
              MonsterStatus.initial => const Center(
                child: CircularProgressIndicator(),
              ),
              MonsterStatus.failure => Center(
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
                      'Erro ao carregar o Bestiário.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              MonsterStatus.success => ListView.builder(
                controller: _scrollController,
                // +1 reserva espaço para o BottomLoader enquanto há mais páginas.
                itemCount:
                    state.monsters.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.monsters.length) {
                    return const _BottomLoader();
                  }
                  final monster = state.monsters[index];
                  return ListTile(
                    leading: const DnDIcon(
                      assetPath: 'assets/icons/game/monster.svg',
                      size: 26,
                    ),
                    title: Text(monster.name),
                    subtitle: Text(
                      monster.index,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            };
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
