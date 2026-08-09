import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';
import 'package:crit_sense/features/dice_roller/domain/entities/dice_type.dart';

/// Carrossel infinito com os tipos de dado disponíveis (d4 a d100).
///
/// `enableInfiniteScroll` (padrão do pacote) permite arrastar sem fim em
/// ambas as direções, e `enlargeCenterPage` escala visualmente o item mais
/// próximo do centro — é ele que fica "em foco" para o botão "Adicionar ao
/// Pool" logo abaixo, reportado via [onFocusChanged].
class DiceTypeCarousel extends StatelessWidget {
  const DiceTypeCarousel({super.key, required this.onFocusChanged});

  final ValueChanged<DiceType> onFocusChanged;

  static const _height = 108.0;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: DiceType.values.length,
      itemBuilder: (context, index, realIndex) =>
          _DieCard(type: DiceType.values[index]),
      options: CarouselOptions(
        height: _height,
        viewportFraction: 0.3,
        enlargeCenterPage: true,
        enlargeFactor: 0.35,
        // O pacote já resolve o índice "real" (0..length-1) mesmo em loop
        // infinito, então `DiceType.values[index]` é sempre seguro aqui.
        onPageChanged: (index, reason) =>
            onFocusChanged(DiceType.values[index]),
      ),
    );
  }
}

class _DieCard extends StatelessWidget {
  const _DieCard({required this.type});

  final DiceType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        DnDIcon(
          assetPath: type.iconAsset,
          size: 48,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 6),
        Text(
          type.label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
