import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/di/injection_container.dart';

import '../bloc/roll_history_cubit.dart';

/// Abre a lista das últimas rolagens.
Future<void> showRollHistory(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider<RollHistoryCubit>.value(
      value: sl<RollHistoryCubit>(),
      child: const RollHistorySheet(),
    ),
  );
}

/// Botão da AppBar que abre o histórico de rolagens.
class RollHistoryButton extends StatelessWidget {
  const RollHistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Histórico de rolagens',
      icon: const Icon(Icons.history),
      onPressed: () => showRollHistory(context),
    );
  }
}

/// Últimas rolagens do rolador e da ficha, da mais nova para a mais antiga.
class RollHistorySheet extends StatelessWidget {
  const RollHistorySheet({super.key});

  static String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: BlocBuilder<RollHistoryCubit, List<RollHistoryEntry>>(
          builder: (context, entries) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Histórico de rolagens',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      if (entries.isNotEmpty)
                        TextButton(
                          onPressed: context.read<RollHistoryCubit>().clear,
                          child: const Text('Limpar'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma rolagem ainda.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final e = entries[index];
                            final color = switch (e.critical) {
                              true => Colors.green.shade700,
                              false => theme.colorScheme.error,
                              null => null,
                            };
                            return ListTile(
                              title: Text(e.label),
                              subtitle: Text(
                                '${_time(e.rolledAt)} · ${e.detail}',
                              ),
                              trailing: Text(
                                '${e.total}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
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
