import 'package:flutter/material.dart';

import 'package:crit_sense/di/injection_container.dart' as di;
import 'package:crit_sense/features/dice_roller/presentation/pages/dice_screen.dart';

/// Ponto de entrada assíncrono: aguarda o `get_it` registrar todas as
/// dependências antes de renderizar qualquer widget.
///
/// `WidgetsFlutterBinding.ensureInitialized()` é obrigatório sempre que
/// `main()` for `async` — garante que o binding Flutter esteja pronto
/// para receber chamadas de plataforma antes do `runApp`.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const CritSenseApp());
}

/// Widget raiz do aplicativo.
///
/// Responsabilidade única: configurar o [MaterialApp] com tema e rota inicial.
/// Não contém lógica de negócio nem de estado.
class CritSenseApp extends StatelessWidget {
  const CritSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CritSense',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const DiceScreen(),
    );
  }

  /// Constrói o tema escuro com paleta de RPG de mesa.
  ///
  /// Cores escolhidas por associação semântica ao gênero:
  /// - Fundo quase-preto com tom azulado: ambientação de masmorra/noturna.
  /// - Vermelho sangue como cor primária: perigo, combate, críticos.
  /// - Dourado como cor secundária: sucesso, recompensa, raridade.
  ThemeData _buildTheme() {
    const rpgBackground = Color(0xFF0D0D1A);
    const rpgSurface = Color(0xFF1A1A2E);
    const rpgRed = Color(0xFFB71C1C);
    const rpgGold = Color(0xFFFFD700);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: rpgBackground,
      colorScheme: const ColorScheme.dark(
        primary: rpgRed,
        secondary: rpgGold,
        surface: rpgSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: rpgSurface,
        foregroundColor: rpgGold,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rpgRed,
        foregroundColor: Colors.white,
      ),
    );
  }
}
