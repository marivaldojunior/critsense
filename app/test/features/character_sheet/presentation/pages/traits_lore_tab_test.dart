import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/features_bloc.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_character_features_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_rule_feature_detail_usecase.dart';

import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/pages/character_sheet_tabs/traits_lore_tab.dart';

import '../../../../helpers/character_test_helpers.dart';

class _MockGetFeatures extends Mock implements GetCharacterFeaturesUseCase {}

class _MockGetDetail extends Mock implements GetRuleFeatureDetailUseCase {}

/// Editar os textos da aba não pode desfazer o que mudou em outra aba.
void main() {
  setUp(() {
    // A seção de características busca no compêndio; aqui ela só falha.
    final getFeatures = _MockGetFeatures();
    when(
      () => getFeatures(
        classIndex: any(named: 'classIndex'),
        raceIndex: any(named: 'raceIndex'),
        level: any(named: 'level'),
        subclassIndex: any(named: 'subclassIndex'),
      ),
    ).thenThrow(Exception('sem rede'));
    sl.registerFactory<FeaturesBloc>(
      () => FeaturesBloc(getFeatures, _MockGetDetail()),
    );
  });

  tearDown(() => sl.reset());

  testWidgets('editar um traço depois de um dano mantém o PV novo', (
    tester,
  ) async {
    final character = buildTestCharacter(currentHitPoints: 30);
    final (:bloc, saveCharacter: _) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: TraitsLoreTab(character: character),
          ),
        ),
      ),
    );

    // Dano dado em outra aba depois que esta abriu.
    bloc.add(const ApplyDamageEvent('c1', 10));
    await tester.runAsync(
      () => bloc.stream
          .firstWhere((s) => s.findCharacter('c1')?.currentHitPoints == 20)
          .timeout(const Duration(seconds: 5)),
    );

    await tester.enterText(find.byType(TextField).first, 'Teimoso');
    // Passa o debounce de 500ms da aba.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(
      () => bloc.stream
          .firstWhere(
            (s) => s.findCharacter('c1')?.personalityTraits == 'Teimoso',
          )
          .timeout(const Duration(seconds: 5)),
    );

    final saved = bloc.state.findCharacter('c1')!;
    expect(saved.personalityTraits, 'Teimoso');
    expect(saved.currentHitPoints, 20);
  });
}
