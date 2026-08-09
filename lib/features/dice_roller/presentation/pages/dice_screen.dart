import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/hardware_bridge/hardware_bridge.dart';
import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/d20_roll_mode.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_bloc.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/d20_mode_selector.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/dice_type_carousel.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/modifier_control.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/roll_flow_dialog.dart';
import 'package:crit_sense/features/dice_roller/presentation/widgets/selected_dice_row.dart';

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

  /// Alimenta o [ConfettiWidget] sobreposto à tela; disparado pelo listener
  /// do BLoC sempre que a rolagem concluída contém um d20 crítico (natural 20).
  late final ConfettiController _confettiController;

  /// Tipo de dado atualmente centralizado no [DiceTypeCarousel] — é ele que
  /// o botão "Adicionar ao Pool" envia ao [DiceBloc].
  DiceType _focusedDiceType = DiceType.values.first;

  /// Status da última emissão, usado no `listener` para detectar a transição
  /// exata `idle -> rolling` (abrir o dialog) sem depender do parâmetro
  /// `previous`, que `BlocConsumer.listener` não expõe.
  DiceRollStatus? _previousStatus;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _shakeSub = HardwareBridge.onShakeDetected.listen((_) {
      if (!mounted) return;
      context.read<DiceBloc>().add(const DiceShakeDetected());
    });
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `BlocConsumer` já *é* um `BlocListener` + `BlocBuilder` combinados —
    // reaproveitado no nível do Scaffold (em vez de um `BlocListener`
    // redundante ao lado) porque tanto o corpo rolável quanto o CTA fixo em
    // `bottomNavigationBar` precisam do mesmo `state`/`bloc` do [DiceBloc].
    return BlocConsumer<DiceBloc, DiceState>(
      // Só dispara em mudanças de status — evita reagir a alterações de
      // pool, modificador ou modo do d20.
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final previousStatus = _previousStatus;
        _previousStatus = state.status;

        // idle -> rolling: abre o dialog único que acompanha toda a rolagem.
        if (previousStatus != DiceRollStatus.rolling &&
            state.status == DiceRollStatus.rolling) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => BlocProvider.value(
              value: context.read<DiceBloc>(),
              child: const RollFlowDialog(),
            ),
          );
          return;
        }

        // rolling -> idle: rolagem concluída, dispara o confete se crítico.
        // Reaproveita `hasCriticalSuccess` do domínio: já considera o valor
        // *mantido* de cada d20 (pós vantagem/desvantagem), não o descartado.
        if (previousStatus == DiceRollStatus.rolling &&
            state.status == DiceRollStatus.idle &&
            state.lastResult != null &&
            state.lastResult!.hasCriticalSuccess) {
          _confettiController.play();
        }
      },
      builder: (context, state) {
        final bloc = context.read<DiceBloc>();
        final isRolling = state.status == DiceRollStatus.rolling;

        return Scaffold(
          appBar: AppBar(title: const Text('Rolador de Dados')),
          body: Stack(
            alignment: Alignment.center,
            children: [
              _buildScrollableContent(context, state, bloc, isRolling),
              // `IgnorePointer` garante que o burst de confete, centralizado
              // na tela, nunca intercepte toques destinados aos controles
              // abaixo dele.
              IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 30,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  gravity: 0.3,
                  shouldLoop: false,
                  colors: const [Colors.green, Color(0xFFFFD700)],
                ),
              ),
            ],
          ),
          // CTA principal fixo na base da tela — fora da área rolável, para
          // que "Rolar Dados" fique sempre alcançável na thumb zone,
          // independente de quantos dados o usuário já adicionou ao pool.
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.totalDiceCount == 0 || isRolling
                      ? null
                      : () => bloc.add(const DiceRollRequested()),
                  icon: const DnDIcon(
                    assetPath: 'assets/icons/dice/roll.svg',
                    size: 24,
                  ),
                  label: Text(isRolling ? 'Rolando...' : 'Rolar Dados'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Conteúdo rolável da tela: tudo além do CTA "Rolar Dados", que agora
  /// vive fixo em `bottomNavigationBar`.
  Widget _buildScrollableContent(
    BuildContext context,
    DiceState state,
    DiceBloc bloc,
    bool isRolling,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DiceTypeCarousel(
            onFocusChanged: (type) => setState(() => _focusedDiceType = type),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => bloc.add(DiceTypeAdded(_focusedDiceType)),
            icon: const Icon(Icons.add),
            label: Text('Adicionar ${_focusedDiceType.label} ao Pool'),
          ),
          const SizedBox(height: 16),
          Text(
            'Dados selecionados',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SelectedDiceRow(
            pool: state.pool,
            d20Mode: state.d20Mode,
            onRemove: (type) => bloc.add(DiceTypeRemoved(type)),
          ),
          const SizedBox(height: 16),
          Text('Modo do d20', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          D20ModeSelector(
            mode: state.d20Mode,
            onChanged: (mode) => bloc.add(D20ModeChanged(mode)),
          ),
          const SizedBox(height: 16),
          ModifierControl(
            modifier: state.modifier,
            onIncrement: () => bloc.add(const ModifierIncremented()),
            onDecrement: () => bloc.add(const ModifierDecremented()),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed:
                state.pool.isEmpty &&
                    state.modifier == 0 &&
                    state.d20Mode == D20RollMode.normal
                ? null
                : () => bloc.add(const PoolCleared()),
            icon: const DnDIcon(
              assetPath: 'assets/icons/util/cross.svg',
              size: 20,
            ),
            label: const Text('Limpar Pool'),
          ),
          const SizedBox(height: 16),
          _buildResultSection(context, state),
        ],
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, DiceState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        state.lastResult != null
            ? 'Toque em "Rolar Dados" para rolar novamente.'
            : 'Monte seu pool de dados e toque em "Rolar Dados".',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
