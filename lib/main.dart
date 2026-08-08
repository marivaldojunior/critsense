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
          // Envolve toda rota em um SafeArea: no Android com navegação por
          // gestos/botões, o conteúdo (ex: botões no fim da tela) fica sob
          // a barra do sistema sem isso, já que o Scaffold não aplica esse
          // inset sozinho. `top: false` porque o topo já é tratado pela
          // AppBar de cada tela — aplicar de novo aqui empurraria tudo
          // para baixo, deixando um espaço em branco acima da AppBar.
          builder: (context, child) =>
              SafeArea(top: false, child: child ?? const SizedBox.shrink()),
          home: HomeScreen(
            onToggleTheme: () => _themeMode.value = mode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark,
          ),
        ),
      ),
    );
  }

  /// Constrói o tema claro com paleta neutra de ficha de RPG: fundo em tom
  /// de pergaminho e acentos em marrom-acinzentado/sépia pastel.
  ///
  /// A paleta é deliberadamente restrita a branco, preto, cinzas e tons
  /// pastel — vermelho e verde ficam reservados para sinalizar sucesso e
  /// falha (crítico/falha crítica no d20, exclusão de itens, erros),
  /// nunca como cor decorativa de marca.
  ThemeData _buildLightTheme() {
    const rpgParchment = Color(0xFFFBF5E9);
    const rpgSurfaceLight = Color(0xFFF0E6D2);
    const rpgAccentPrimary = Color(0xFF6B5F4F);
    const rpgAccentSecondary = Color(0xFFC9B896);
    const rpgAccentTertiary = Color(0xFFA8998A);
    const rpgError = Color(0xFFB71C1C);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: rpgParchment,
      colorScheme: const ColorScheme.light(
        primary: rpgAccentPrimary,
        secondary: rpgAccentSecondary,
        tertiary: rpgAccentTertiary,
        surface: rpgSurfaceLight,
        error: rpgError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: rpgAccentPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rpgAccentPrimary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Constrói o tema escuro com a mesma paleta neutra, invertida em
  /// luminância: fundo cinza quase-preto (sem matiz de cor) e acentos em
  /// bege/sépia pastel claro para manter contraste legível.
  ThemeData _buildDarkTheme() {
    const rpgBackground = Color(0xFF121212);
    const rpgSurface = Color(0xFF1E1E1E);
    const rpgAccentPrimary = Color(0xFFD8CFC0);
    const rpgAccentSecondary = Color(0xFF9C8F76);
    const rpgAccentTertiary = Color(0xFFB0A99E);
    const rpgError = Color(0xFFEF5350);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: rpgBackground,
      colorScheme: const ColorScheme.dark(
        primary: rpgAccentPrimary,
        secondary: rpgAccentSecondary,
        tertiary: rpgAccentTertiary,
        surface: rpgSurface,
        error: rpgError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: rpgSurface,
        foregroundColor: rpgAccentPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: rpgAccentPrimary,
        unselectedLabelColor: rpgAccentPrimary.withValues(alpha: 0.7),
        indicatorColor: rpgAccentPrimary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rpgAccentPrimary,
        foregroundColor: rpgSurface,
      ),
    );
  }
}
