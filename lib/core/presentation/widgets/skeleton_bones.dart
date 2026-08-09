import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Forma base (círculo ou retângulo arredondado) usada para montar telas de
/// esqueleto ("skeleton loading") que imitam a silhueta do conteúdo real
/// antes dele chegar — substitui indicadores genéricos como
/// [CircularProgressIndicator] nos estados de carregamento.
///
/// Deve ser usado dentro de um [SkeletonShimmer]: a cor de preenchimento
/// aqui é só um placeholder opaco, repintado pelo `Shimmer.fromColors`
/// ancestral via `ShaderMask` — por isso não importa qual cor sólida é usada.
class SkeletonBones extends StatelessWidget {
  /// Osso circular, ideal para simular ícones e avatares.
  const SkeletonBones.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = size / 2;

  /// Osso retangular arredondado, ideal para simular texto, chips e cards.
  const SkeletonBones.rect({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Envolve uma árvore de [SkeletonBones] em um único `Shimmer.fromColors`,
/// com cores que respeitam `Theme.of(context).brightness` (claro/escuro).
///
/// Concentrar o shimmer em um único ancestral — em vez de um por osso —
/// evita dezenas de `AnimationController` simultâneos numa listagem e
/// mantém o brilho varrendo a tela em conjunto, como um único efeito.
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFE0D5C0),
      highlightColor: isDark
          ? const Color(0xFF3D3D3D)
          : const Color(0xFFF7F0E2),
      child: child,
    );
  }
}
