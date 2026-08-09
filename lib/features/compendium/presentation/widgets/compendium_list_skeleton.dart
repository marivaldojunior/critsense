import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/skeleton_bones.dart';

/// Esqueleto de carregamento para as listagens do Compêndio (Magias,
/// Equipamentos, Bestiário).
///
/// Reaproveitado pelas três telas porque todas compartilham a mesma
/// silhueta de [ListTile] — ícone circular à esquerda, título e subtítulo
/// empilhados e, opcionalmente, um elemento à direita — construída com o
/// próprio [ListTile] para garantir o mesmo espaçamento/altura do item real.
class CompendiumListSkeleton extends StatelessWidget {
  const CompendiumListSkeleton({
    super.key,
    this.itemCount = 7,
    this.hasTrailing = false,
  });

  /// Quantidade de itens fantasma exibidos (6 a 8 recomendado).
  final int itemCount;

  /// Se `true`, reserva o espaço do elemento à direita do [ListTile]
  /// (ex: chevron ou botão de ação) presente na tela real.
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => ListTile(
          leading: const SkeletonBones.circle(size: 26),
          title: const Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBones.rect(width: 160, height: 14),
          ),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 6),
            child: SkeletonBones.rect(width: 90, height: 11),
          ),
          trailing: hasTrailing
              ? const SkeletonBones.circle(size: 22)
              : null,
        ),
      ),
    );
  }
}
