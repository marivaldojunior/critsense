import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Estado físico de um dado individual na simulação: posição, velocidade
/// (em pixels/segundo) e rotação atual — tudo mutável, atualizado a cada
/// frame pelo game loop de [AnimatedRollingDice].
class DiceObject {
  DiceObject({
    required this.type,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.size,
  });

  final DiceType type;
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  final double size;
}

/// Simulação física 2D dos dados do pool: eles se movem em linha reta,
/// quicam nas bordas do tabuleiro e colidem uns com os outros sem se
/// sobrepor, enquanto o [DiceBloc] está no status `rolling`.
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
  /// Limite visual: mais que isso polui o tabuleiro sem agregar à sensação
  /// de rolagem — o valor real do pool continua sendo o do BLoC.
  static const _maxVisibleDice = 6;

  /// Dimensão (largura e altura) do tabuleiro quadrado onde os dados se
  /// movem e quicam.
  static const _boardSize = 250.0;

  /// Tamanho de cada dado renderizado (usado tanto no layout quanto como
  /// diâmetro aproximado nas colisões círculo-círculo).
  static const _diceSize = 40.0;

  /// Velocidade máxima inicial, em pixels/segundo, sorteada com sinal
  /// aleatório para os eixos X e Y de cada dado.
  static const _maxSpeed = 140.0;

  final _random = Random();

  late final Ticker _ticker;

  /// Estado físico de cada dado visível, sorteado uma única vez em
  /// [initState] e mutado a cada frame por [_updatePhysics].
  late final List<DiceObject> _dice;

  /// Timestamp do frame anterior, para calcular o `dt` (delta time) do
  /// frame atual — o [Ticker] entrega o tempo acumulado desde o início,
  /// não o intervalo entre frames.
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _dice = _createDiceObjects();
    _ticker = createTicker(_updatePhysics)..start();
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  /// Desdobra o mapa `tipo -> quantidade` em uma lista plana, truncada em
  /// [_maxVisibleDice] — mesma abordagem de `SelectedDiceRow._flatten`.
  List<DiceType> _flattenPool() {
    final dice = [
      for (final entry in widget.pool.entries)
        for (var i = 0; i < entry.value; i++) entry.key,
    ];
    return dice.take(_maxVisibleDice).toList();
  }

  /// Sorteia posição e velocidade inicial de cada dado. Usa rejection
  /// sampling simples (tenta algumas posições e fica com a primeira sem
  /// sobreposição) para garantir que nenhum par nasça já colidindo.
  List<DiceObject> _createDiceObjects() {
    final objects = <DiceObject>[];

    for (final type in _flattenPool()) {
      var x = 0.0;
      var y = 0.0;
      var attempts = 0;
      const maxAttempts = 30;

      do {
        x = _random.nextDouble() * (_boardSize - _diceSize);
        y = _random.nextDouble() * (_boardSize - _diceSize);
        attempts++;
      } while (attempts < maxAttempts &&
          objects.any(
            (other) => _distanceBetween(x, y, other.x, other.y) < _diceSize,
          ));

      objects.add(
        DiceObject(
          type: type,
          x: x,
          y: y,
          // `* 2 - 1` mapeia [0, 1) para [-1, 1): metade dos dados começa
          // indo para cada lado, em vez de todos na mesma direção.
          vx: (_random.nextDouble() * 2 - 1) * _maxSpeed,
          vy: (_random.nextDouble() * 2 - 1) * _maxSpeed,
          rotation: _random.nextDouble() * 2 * pi,
          size: _diceSize,
        ),
      );
    }

    return objects;
  }

  double _distanceBetween(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  /// Game loop: chamado a cada frame pelo [Ticker], avança a posição de
  /// cada dado e resolve colisões com as bordas e entre os próprios dados.
  void _updatePhysics(Duration elapsed) {
    final dt =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    // Primeiro frame do Ticker chega com `elapsed` zerado (dt == 0) — não
    // há o que mover ainda.
    if (dt <= 0) return;

    for (final dice in _dice) {
      _moveAndBounceOffWalls(dice, dt);
    }
    _resolveDiceCollisions();

    setState(() {});
  }

  /// Avança a posição do dado pela velocidade atual e o "quica" nas 4
  /// bordas do tabuleiro: ao ultrapassar um limite, inverte a velocidade
  /// daquele eixo e prende (clamp) a posição dentro da área visível.
  void _moveAndBounceOffWalls(DiceObject dice, double dt) {
    dice.x += dice.vx * dt;
    dice.y += dice.vy * dt;

    final maxX = _boardSize - dice.size;
    final maxY = _boardSize - dice.size;

    if (dice.x < 0) {
      dice.x = 0;
      dice.vx = -dice.vx;
    } else if (dice.x > maxX) {
      dice.x = maxX;
      dice.vx = -dice.vx;
    }

    if (dice.y < 0) {
      dice.y = 0;
      dice.vy = -dice.vy;
    } else if (dice.y > maxY) {
      dice.y = maxY;
      dice.vy = -dice.vy;
    }

    // Rotação proporcional à velocidade atual: dado se movendo rápido gira
    // mais rápido, e desacelera visualmente junto com o próprio movimento.
    final speed = sqrt(dice.vx * dice.vx + dice.vy * dice.vy);
    dice.rotation += speed * dt * 0.05;
  }

  /// Detecção e resolução de colisão entre todos os pares de dados,
  /// aproximando cada um por um círculo do seu próprio tamanho — O(n²),
  /// aceitável para o número reduzido de dados visíveis ([_maxVisibleDice]).
  void _resolveDiceCollisions() {
    for (var i = 0; i < _dice.length; i++) {
      for (var j = i + 1; j < _dice.length; j++) {
        final a = _dice[i];
        final b = _dice[j];

        final dx = b.x - a.x;
        final dy = b.y - a.y;
        final distance = sqrt(dx * dx + dy * dy);

        // `distance == 0`: centros exatamente sobrepostos (raro, mas
        // indefiniria a normal abaixo) — ignora esse frame e deixa a
        // repulsão dos frames seguintes (posições já levemente diferentes
        // por causa do movimento) resolver naturalmente.
        if (distance == 0 || distance >= a.size) continue;

        // Empurra os dois dados para fora, cada um pela metade da
        // sobreposição, ao longo da reta que une seus centros — evita que
        // fiquem "grudados" reprocessando a mesma colisão a cada frame.
        final overlap = a.size - distance;
        final normalX = dx / distance;
        final normalY = dy / distance;

        a.x -= normalX * overlap / 2;
        a.y -= normalY * overlap / 2;
        b.x += normalX * overlap / 2;
        b.y += normalY * overlap / 2;

        // Troca simples de velocidades: aproxima um choque elástico entre
        // massas iguais, suficiente para o efeito visual de "batida" sem
        // exigir cálculo real de massa/impulso.
        final tempVx = a.vx;
        final tempVy = a.vy;
        a.vx = b.vx;
        a.vy = b.vy;
        b.vx = tempVx;
        b.vy = tempVy;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    if (_dice.isEmpty) {
      // Sem dados no pool (não deveria ocorrer com o CTA desabilitado, mas
      // evita uma tela em branco caso o estado mude entre um rebuild e outro).
      return const SizedBox(height: _boardSize);
    }

    return SizedBox(
      width: _boardSize,
      height: _boardSize,
      child: Stack(
        children: [
          for (final dice in _dice)
            Positioned(
              left: dice.x,
              top: dice.y,
              child: Transform.rotate(
                angle: dice.rotation,
                child: DnDIcon(
                  assetPath: dice.type.iconAsset,
                  size: dice.size,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
