import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/di/injection_container.dart' as di;
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/home/presentation/pages/home_screen.dart';

/// Ponto de entrada assíncrono: aguarda o `get_it` registrar todas as
/// dependências antes de renderizar qualquer widget.
///
/// `WidgetsFlutterBinding.ensureInitialized()` é obrigatório sempre que
/// `main()` for `async` — garante que o binding Flutter esteja pronto
/// para receber chamadas de plataforma antes do `runApp`.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(CritSenseApp());
}

/// Widget raiz do aplicativo.
///
/// Responsabilidade única: configurar o [MaterialApp] com temas e rota
/// inicial, e manter qual [ThemeMode] está ativo. Não contém lógica de
/// negócio — apenas o estado efêmero de UI do tema escolhido pelo usuário.
class CritSenseApp extends StatelessWidget {
  CritSenseApp({super.key});

  /// Tema claro é o padrão ao abrir o app; o usuário alterna via botão
  /// exposto na [HomeScreen]. `ValueNotifier` é suficiente aqui pois é
  /// estado de UI puro, sem persistência ou regra de negócio — não
  /// justifica um BLoC dedicado.
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharacterBloc>(
      // Provedor raiz, acima do Navigator: qualquer tela empurrada a partir
      // daqui (Personagens, Equipamentos) herda a mesma instância via
      // `context.read`, sem precisar redeclará-la a cada rota. Fica fora do
      // ValueListenableBuilder abaixo para que a troca de tema nunca recrie
      // o CharacterBloc.
      create: (_) => di.sl<CharacterBloc>()..add(const LoadCharactersEvent()),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, mode, _) => MaterialApp(
          title: 'CritSense',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: mode,
          home: HomeScreen(
            onToggleTheme: () => _themeMode.value =
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
          ),
        ),
      ),
    );
  }

  /// Constrói o tema claro com paleta de RPG de mesa: fundo em tom de
  /// pergaminho, vermelho sangue como cor primária e dourado escurecido
  /// para manter contraste legível sobre fundo claro.
  ThemeData _buildLightTheme() {
    const rpgParchment = Color(0xFFFBF5E9);
    const rpgSurfaceLight = Color(0xFFF0E6D2);
    const rpgRed = Color(0xFFB71C1C);
    const rpgGoldDark = Color(0xFF8A6D00);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: rpgParchment,
      colorScheme: const ColorScheme.light(
        primary: rpgRed,
        secondary: rpgGoldDark,
        surface: rpgSurfaceLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: rpgRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rpgRed,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Constrói o tema escuro com paleta de RPG de mesa.
  ///
  /// Cores escolhidas por associação semântica ao gênero:
  /// - Fundo quase-preto com tom azulado: ambientação de masmorra/noturna.
  /// - Vermelho sangue como cor primária: perigo, combate, críticos.
  /// - Dourado como cor secundária: sucesso, recompensa, raridade.
  ThemeData _buildDarkTheme() {
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
