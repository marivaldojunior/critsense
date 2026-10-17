import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crit_sense/core/theme/theme_cubit.dart';

/// Testa a leitura e a gravação do tema escolhido no [ThemeCubit].
void main() {
  Future<SharedPreferences> preferencesWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('sem tema salvo, começa no tema claro', () async {
    final cubit = ThemeCubit(await preferencesWith({}));

    expect(cubit.state, ThemeMode.light);
    await cubit.close();
  });

  test('começa no tema salvo', () async {
    final cubit = ThemeCubit(
      await preferencesWith({ThemeCubit.storageKey: 'dark'}),
    );

    expect(cubit.state, ThemeMode.dark);
    await cubit.close();
  });

  test('um valor salvo inválido volta para o tema claro', () async {
    final cubit = ThemeCubit(
      await preferencesWith({ThemeCubit.storageKey: 'roxo'}),
    );

    expect(cubit.state, ThemeMode.light);
    await cubit.close();
  });

  test('toggle alterna o tema e salva a escolha', () async {
    final preferences = await preferencesWith({});
    final cubit = ThemeCubit(preferences);

    await cubit.toggle();
    expect(cubit.state, ThemeMode.dark);
    expect(preferences.getString(ThemeCubit.storageKey), 'dark');

    await cubit.toggle();
    expect(cubit.state, ThemeMode.light);
    expect(preferences.getString(ThemeCubit.storageKey), 'light');
    await cubit.close();
  });
}
