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
          title: 'Crit Sense',
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

  /// Semente única de matiz sépia/marrom-acinzentado a partir da qual o
  /// Material 3 deriva *todos* os roles tonais do [ColorScheme] — inclusive
  /// os que antes ficavam sem definição explícita (`surfaceContainerHighest`,
  /// `outline`, `outlineVariant` etc.) e por isso vazavam o roxo/cinza
  /// padrão do Material em vez de herdar o tom quente do app.
  ///
  /// Vermelho e verde continuam fora da semente — seguem reservados para
  /// sinalizar sucesso e falha (crítico/falha crítica no d20, exclusão de
  /// itens, erros), nunca como cor decorativa de marca.
  static const _rpgSeed = Color(0xFF6B5F4F);

  /// Constrói o tema claro: [ColorScheme.fromSeed] com `brightness: light`
  /// gera automaticamente uma paleta tonal inteira (fundo em tom de
  /// pergaminho, superfícies e acentos em sépia) coerente com a semente.
  ThemeData _buildLightTheme() {
    const rpgError = Color(0xFFB71C1C);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: _rpgSeed,
      brightness: Brightness.light,
    ).copyWith(error: rpgError);

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
        indicatorColor: colorScheme.onPrimary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  /// Constrói o tema escuro a partir da mesma semente sépia, apenas com
  /// `brightness: dark` — o Material 3 já inverte a luminância mantendo o
  /// mesmo matiz, sem precisar de uma segunda paleta mantida à mão.
  ThemeData _buildDarkTheme() {
    const rpgError = Color(0xFFEF5350);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: _rpgSeed,
      brightness: Brightness.dark,
    ).copyWith(error: rpgError);

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        centerTitle: true,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.primary.withValues(alpha: 0.7),
        indicatorColor: colorScheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
