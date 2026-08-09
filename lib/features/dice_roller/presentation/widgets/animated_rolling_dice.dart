import 'dart:math';

import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Simula fisicamente os dados do pool girando e quicando sobre a mesa
/// enquanto o [DiceBloc] está no status `rolling`.
///
/// Cada dado gira em velocidade e sentido próprios e mantém um deslocamento
/// (X/Y) fixo sorteado uma única vez, dando a sensação de dados espalhados
/// em vez de sobrepostos no centro da tela.
class AnimatedRollingDice extends StatefulWidget {
  const AnimatedRollingDice({super.key, required this.pool});

  /// Pool atual de dados; apenas a composição (tipos), não a quantidade
  /// exata, importa para a animação — ver [_maxVisibleDice].
  final Map<DiceType, int> pool;

  @override
  State<AnimatedRollingDice> createState() => _AnimatedRollingDiceState();
}

class _AnimatedRollingDiceState extends State<AnimatedRollingDice>
    with SingleTickerProviderStateMixin {
  /// Limite visual: mais que isso polui a tela sem agregar à sensação de
  /// rolagem — o valor real do pool continua sendo o do BLoC.
  static const _maxVisibleDice = 6;

  late final AnimationController _controller;
  final _random = Random();

  /// Offsets/velocidades sorteados uma única vez em [initState], para que
  /// cada dado mantenha sua posição e giro ao longo de toda a animação em
  /// vez de "pular" a cada rebuild.
  late final List<_DiceMotion> _motions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();

    _motions = List.generate(_maxVisibleDice, (_) {
      return _DiceMotion(
        offsetX: _random.nextDouble() * 80 - 40,
        offsetY: _random.nextDouble() * 60 - 30,
        spinDirection: _random.nextBool() ? 1 : -1,
        speedFactor: 0.7 + _random.nextDouble() * 0.6,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Desdobra o mapa `tipo -> quantidade` em uma lista plana, truncada em
  /// [_maxVisibleDice] — mesma abordagem de `SelectedDiceRow._flatten`.
  List<DiceType> _flatten() {
    final dice = [
      for (final entry in widget.pool.entries)
        for (var i = 0; i < entry.value; i++) entry.key,
    ];
    return dice.take(_maxVisibleDice).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dice = _flatten();
    final color = Theme.of(context).colorScheme.primary;

    if (dice.isEmpty) {
      // Sem dados no pool (não deveria ocorrer com o CTA desabilitado, mas
      // evita uma tela em branco caso o estado mude entre um rebuild e outro).
      return const SizedBox(height: 96);
    }

    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < dice.length; i++)
            _buildAnimatedDie(dice[i], _motions[i], color),
        ],
      ),
    );
  }

  Widget _buildAnimatedDie(DiceType type, _DiceMotion motion, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle =
            2 *
            pi *
            _controller.value *
            motion.spinDirection *
            motion.speedFactor;
        return Transform.translate(
          offset: Offset(motion.offsetX, motion.offsetY),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: DnDIcon(assetPath: type.iconAsset, size: 40, color: color),
    );
  }
}

/// Parâmetros de deslocamento/rotação de um dado individual, sorteados uma
/// única vez para toda a duração da animação.
class _DiceMotion {
  const _DiceMotion({
    required this.offsetX,
    required this.offsetY,
    required this.spinDirection,
    required this.speedFactor,
  });

  final double offsetX;
  final double offsetY;
  final int spinDirection;
  final double speedFactor;
}
