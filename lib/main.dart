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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CritSense',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DiceScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
