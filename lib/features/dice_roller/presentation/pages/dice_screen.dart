import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/hardware_bridge/hardware_bridge.dart';
import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_bloc.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/d20_mode_selector.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/dice_type_button.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/modifier_control.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/roll_result_panel.dart';

/// Tela do rolador de dados: monta um pool de múltiplos tipos/quantidades,
/// aplica um modificador global e exibe o detalhamento da soma.
class DiceScreen extends StatelessWidget {
  const DiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DiceBloc>(),
      child: const _DiceView(),
    );
  }
}

class _DiceView extends StatefulWidget {
  const _DiceView();

  @override
  State<_DiceView> createState() => _DiceViewState();
}

class _DiceViewState extends State<_DiceView> {
  StreamSubscription<void>? _shakeSub;

  @override
  void initState() {
    super.initState();
    _shakeSub = HardwareBridge.onShakeDetected.listen((_) {
      if (!mounted) return;
      context.read<DiceBloc>().add(const DiceShakeDetected());
    });
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rolador de Dados')),
      body: BlocBuilder<DiceBloc, DiceState>(
        builder: (context, state) {
          final bloc = context.read<DiceBloc>();
          final isRolling = state.status == DiceRollStatus.rolling;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final type in DiceType.values)
                      DiceTypeButton(
                        type: type,
                        count: state.pool[type] ?? 0,
                        onAdd: () => bloc.add(DiceTypeAdded(type)),
                        onRemove: () => bloc.add(DiceTypeRemoved(type)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Modo do d20',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                D20ModeSelector(
                  mode: state.d20Mode,
                  onChanged: (mode) => bloc.add(D20ModeChanged(mode)),
                ),
                const SizedBox(height: 20),
                ModifierControl(
                  modifier: state.modifier,
                  onIncrement: () => bloc.add(const ModifierIncremented()),
                  onDecrement: () => bloc.add(const ModifierDecremented()),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.totalDiceCount == 0 || isRolling
                        ? null
                        : () => bloc.add(const DiceRollRequested()),
                    icon: const Icon(Icons.casino_outlined),
                    label: Text(isRolling ? 'Rolando...' : 'Rolar Dados'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed:
                      state.pool.isEmpty &&
                          state.modifier == 0 &&
                          state.d20Mode == D20RollMode.normal
                      ? null
                      : () => bloc.add(const PoolCleared()),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Pool'),
                ),
                const SizedBox(height: 20),
                _buildResultSection(context, state, isRolling),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultSection(
    BuildContext context,
    DiceState state,
    bool isRolling,
  ) {
    if (isRolling) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    }

    if (state.lastResult != null) {
      return RollResultPanel(result: state.lastResult!);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Monte seu pool de dados e toque em "Rolar Dados".',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
