import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/hardware_bridge/hardware_bridge.dart';
import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_result.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_bloc.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_event.dart';
import 'package:crit_sense/features/dice_roller/presentation/bloc/dice_state.dart';

/// Tela principal do CritSense.
///
/// Responsabilidade única: fornecer o [DiceBloc] à subárvore de widgets
/// via [BlocProvider]. Não contém lógica de UI nem de estado — delega
/// tudo ao [_DiceView] privado.
///
/// Manter esta classe como [StatelessWidget] preserva a API pública limpa:
/// quem navegar para `DiceScreen` não precisa saber que internamente há
/// um gerenciador de stream e subscriptions de ciclo de vida.
class DiceScreen extends StatelessWidget {
  const DiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // `sl<DiceBloc>()` é `Factory` no get_it: cria uma nova instância
      // para este BlocProvider, que a descartará via `bloc.close()` no dispose.
      create: (_) => sl<DiceBloc>(),
      child: const _DiceView(),
    );
  }
}

/// Implementação visual e de ciclo de vida da tela de dados.
///
/// É [StatefulWidget] porque precisa gerenciar o [StreamSubscription] do
/// acelerômetro: registrar em [initState] e cancelar em [dispose] para
/// evitar vazamento de memória e eventos após o widget ser removido da árvore.
class _DiceView extends StatefulWidget {
  const _DiceView();

  @override
  State<_DiceView> createState() => _DiceViewState();
}

class _DiceViewState extends State<_DiceView> {
  // Referência ao subscription permite cancelamento preciso no dispose.
  StreamSubscription<void>? _shakeSub;

  @override
  void initState() {
    super.initState();

    // Conecta o stream nativo ao BLoC: cada evento de shake do hardware
    // é traduzido em um DiceShakeDetected, que o BLoC re-despacha como
    // DiceRollRequested — mantendo a lógica de rolagem centralizada no BLoC.
    _shakeSub = HardwareBridge.onShakeDetected.listen((_) {
      // `mounted` evita chamar `context.read` após o widget ter sido descartado
      // (situação possível durante testes ou navegação rápida).
      if (!mounted) return;
      context.read<DiceBloc>().add(const DiceShakeDetected());
    });
  }

  @override
  void dispose() {
    // Cancela o subscription antes do dispose para desregistrar o StreamHandler
    // nativo e interromper o consumo do acelerômetro.
    _shakeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CritSense')),
      body: BlocBuilder<DiceBloc, DiceState>(
        builder: (context, state) {
          // Switch expression com pattern matching (Dart 3): cada braço
          // testa o tipo do estado sem necessidade de cast explícito.
          return switch (state) {
            DiceInitial() => _buildInitial(),
            DiceRolling() => _buildRolling(),
            DiceRolled(:final result) => _buildRolled(result),
            // Wildcard obrigatório pois DiceState não é `sealed`.
            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        // FAB serve como fallback para emuladores sem acelerômetro físico.
        onPressed: () =>
            context.read<DiceBloc>().add(const DiceRollRequested()),
        tooltip: 'Rolar o dado',
        child: const Icon(Icons.casino_outlined),
      ),
    );
  }

  // ─── Builders de Estado ────────────────────────────────────────────────────

  /// Estado inicial: orienta o usuário sobre como interagir.
  Widget _buildInitial() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'Chacoalhe o celular\npara rolar o d20!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, height: 1.5),
        ),
      ),
    );
  }

  /// Estado de rolagem: feedback visual enquanto o delay de animação transcorre.
  Widget _buildRolling() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Rolando...', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  /// Estado final: exibe o resultado com cor semântica para o tipo de crítico.
  ///
  /// Cores derivadas do tema global (definido em [CritSenseApp._buildTheme]):
  /// - Dourado → acerto crítico (sucesso máximo).
  /// - Vermelho → falha crítica (pior resultado possível).
  /// - Branco   → resultado neutro.
  Widget _buildRolled(DiceResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    final valueColor = result.isCriticalSuccess
        ? colorScheme
              .secondary // dourado
        : result.isCriticalFailure
        ? colorScheme
              .primary // vermelho
        : Colors.white;

    final label = result.isCriticalSuccess
        ? 'ACERTO CRÍTICO!'
        : result.isCriticalFailure
        ? 'FALHA CRÍTICA!'
        : 'd20';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${result.value}',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: valueColor,
              // Sombra sutil aumenta legibilidade sobre fundo escuro.
              shadows: [
                Shadow(color: valueColor.withAlpha(120), blurRadius: 24),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              color: valueColor,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
