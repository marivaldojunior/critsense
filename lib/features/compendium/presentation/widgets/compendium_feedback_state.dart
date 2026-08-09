import 'package:flutter/material.dart';

import 'package:crit_sense/core/presentation/widgets/dnd_icon.dart';

/// Ilustração amigável para os estados de "Erro" ou "Vazio" das telas do
/// Compêndio, usando um [DnDIcon] temático em vez de um `Icon` genérico do
/// Material isolado.
class CompendiumFeedbackState extends StatelessWidget {
  const CompendiumFeedbackState.error({super.key, required this.message})
    : iconAsset = 'assets/icons/util/not-applicable.svg',
      isError = true;

  const CompendiumFeedbackState.empty({super.key, required this.message})
    : iconAsset = 'assets/icons/util/search.svg',
      isError = false;

  final String iconAsset;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : theme.colorScheme.outline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DnDIcon(assetPath: iconAsset, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
