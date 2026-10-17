import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

/// Duração da animação implícita de preenchimento/cor da barra.
const _hpBarAnimationDuration = Duration(milliseconds: 500);

/// Barra horizontal de Pontos de Vida com animação implícita de largura e cor.
///
/// A largura preenchida reflete `currentHitPoints / maxHitPoints`; qualquer
/// mudança nesses valores (ex: dano ou cura aplicados pelo `CharacterBloc`)
/// faz a barra animar suavemente até a nova proporção via
/// [TweenAnimationBuilder] — sem precisar de um [AnimationController]
/// manual, já que a própria variação do `currentHitPoints` entre rebuilds
/// dirige a transição.
///
/// A cor acompanha a proporção a cada frame da animação (verde > 50%,
/// amarelo entre 25% e 50%, vermelho < 25%), então a troca de cor ocorre de
/// forma gradual ao longo do preenchimento/esvaziamento da barra, e não
/// como uma troca abrupta.
class AnimatedHpBar extends StatelessWidget {
  const AnimatedHpBar({
    super.key,
    required this.currentHitPoints,
    required this.maxHitPoints,
    this.temporaryHitPoints = 0,
  });

  final int currentHitPoints;
  final int maxHitPoints;
  final int temporaryHitPoints;

  /// Verde acima de 50% de PV, amarelo entre 25% e 50%, vermelho abaixo de 25%.
  static Color _colorForRatio(double ratio) {
    if (ratio > 0.5) return Colors.green;
    if (ratio >= 0.25) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = maxHitPoints > 0
        ? (currentHitPoints / maxHitPoints).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const DnDIcon(assetPath: 'assets/icons/hp/full.svg', size: 24),
            const SizedBox(width: 10),
            Text('Pontos de Vida', style: theme.textTheme.labelMedium),
            const Spacer(),
            Text(
              '$currentHitPoints / $maxHitPoints',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: ratio),
                duration: _hpBarAnimationDuration,
                curve: Curves.easeOutCubic,
                builder: (context, animatedRatio, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedRatio,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _colorForRatio(animatedRatio),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (temporaryHitPoints > 0) ...[
          const SizedBox(height: 4),
          Text(
            '+$temporaryHitPoints temporário',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
