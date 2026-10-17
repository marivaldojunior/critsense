import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o [ThemeMode] escolhido pelo usuário e o salva entre aberturas do
/// app.
///
/// Fica na raiz do app (`main.dart`), acima do `Navigator`: qualquer tela
/// alterna o tema com `context.read<ThemeCubit>().toggle()`, sem receber um
/// callback pelo construtor — inclusive a `LoginScreen` recriada no logout.
class ThemeCubit extends Cubit<ThemeMode> {
  /// Chave do tema salvo no [SharedPreferences].
  static const storageKey = 'theme_mode';

  final SharedPreferences _preferences;

  /// Lê o tema salvo de forma síncrona: o [SharedPreferences] já foi
  /// carregado em `injection_container.dart`, então o primeiro frame já usa
  /// o tema certo, sem piscar o tema claro antes.
  ThemeCubit(SharedPreferences preferences)
    : _preferences = preferences,
      super(_read(preferences));

  /// Alterna entre claro e escuro e salva a escolha.
  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    await _preferences.setString(storageKey, next.name);
  }

  /// Tema claro é o padrão quando nada foi salvo ou o valor salvo é inválido.
  static ThemeMode _read(SharedPreferences preferences) {
    final saved = preferences.getString(storageKey);
    return saved == ThemeMode.dark.name ? ThemeMode.dark : ThemeMode.light;
  }
}
