import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone SVG temático de D&D (ver `assets/icons/`), substituindo os ícones
/// padrão do Material Design nas telas de rolagem de dados e ficha de
/// personagem.
///
/// Quando [color] não é informado, herda a cor de ícone do [IconTheme]
/// ancestral (ex: dentro de um [FilledButton]) ou, na ausência de um, a cor
/// primária de ícone do [Theme] atual — suportando Dark/Light mode sem
/// configuração extra.
class DnDIcon extends StatelessWidget {
  const DnDIcon({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.color,
  });

  /// Caminho do asset SVG, ex: `assets/icons/dice/d20.svg`.
  final String assetPath;

  /// Largura/altura do ícone.
  final double size;

  /// Cor de tingimento do SVG; se nula, usa a cor de ícone do tema.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
