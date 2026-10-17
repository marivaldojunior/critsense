import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/core/theme/theme_cubit.dart';

/// Botão de AppBar que alterna entre os temas claro e escuro via
/// [ThemeCubit]. O ícone mostra o tema que será ativado ao tocar.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: () => context.read<ThemeCubit>().toggle(),
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      tooltip: isDark ? 'Ativar tema claro' : 'Ativar tema escuro',
    );
  }
}
