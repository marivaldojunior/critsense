import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/features_bloc.dart';
import 'package:crit_sense/features/character_sheet/presentation/widgets/features_section.dart';
import 'package:crit_sense/features/compendium/domain/entities/api_reference.dart';
import 'package:crit_sense/features/compendium/domain/entities/rule_feature.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_character_features_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_rule_feature_detail_usecase.dart';

import '../../../../helpers/character_test_helpers.dart';

class _MockGetFeatures extends Mock implements GetCharacterFeaturesUseCase {}

class _MockGetDetail extends Mock implements GetRuleFeatureDetailUseCase {}

/// Testa as características de classe e os traços raciais da ficha.
void main() {
  late _MockGetFeatures getFeatures;
  late _MockGetDetail getDetail;

  const CharacterFeatures features = (
    classFeatures: [
      ClassLevelFeatures(
        level: 1,
        features: [ApiReference(index: 'second-wind', name: 'Second Wind')],
      ),
    ],
    racialTraits: [ApiReference(index: 'darkvision', name: 'Darkvision')],
  );

  setUpAll(() => registerFallbackValue(RuleFeatureKind.classFeature));

  setUp(() {
    getFeatures = _MockGetFeatures();
    getDetail = _MockGetDetail();
  });

  test('carrega as características até o nível do personagem', () async {
    when(
      () => getFeatures(classIndex: 'fighter', raceIndex: 'dwarf', level: 4),
    ).thenAnswer((_) async => features);
    final bloc = FeaturesBloc(getFeatures, getDetail);
    addTearDown(bloc.close);

    bloc.add(
      const LoadFeaturesEvent(
        classIndex: 'fighter',
        raceIndex: 'dwarf',
        level: 4,
      ),
    );
    final state = await bloc.stream.firstWhere(
      (s) => s.status == FeaturesStatus.success,
    );

    expect(state.classFeatures.single.features.single.name, 'Second Wind');
    expect(state.racialTraits.single.name, 'Darkvision');
  });

  test('sem internet: status failure', () async {
    when(
      () => getFeatures(
        classIndex: any(named: 'classIndex'),
        raceIndex: any(named: 'raceIndex'),
        level: any(named: 'level'),
      ),
    ).thenThrow(Exception('sem rede'));
    final bloc = FeaturesBloc(getFeatures, getDetail);
    addTearDown(bloc.close);

    bloc.add(
      const LoadFeaturesEvent(classIndex: 'fighter', raceIndex: null, level: 1),
    );

    expect(
      (await bloc.stream.firstWhere(
        (s) => s.status == FeaturesStatus.failure,
      )).status,
      FeaturesStatus.failure,
    );
  });

  test('o texto da característica é buscado uma vez e guardado', () async {
    when(
      () => getDetail('second-wind', RuleFeatureKind.classFeature),
    ).thenAnswer(
      (_) async => const RuleFeatureDetail(
        index: 'second-wind',
        name: 'Second Wind',
        desc: ['Recupera PV.'],
      ),
    );
    final bloc = FeaturesBloc(getFeatures, getDetail);
    addTearDown(bloc.close);

    bloc.add(
      const LoadFeatureDetailEvent('second-wind', RuleFeatureKind.classFeature),
    );
    await bloc.stream.firstWhere((s) => s.details.containsKey('second-wind'));
    bloc.add(
      const LoadFeatureDetailEvent('second-wind', RuleFeatureKind.classFeature),
    );
    await Future<void>.delayed(Duration.zero);

    verify(
      () => getDetail('second-wind', RuleFeatureKind.classFeature),
    ).called(1);
  });

  testWidgets('a seção mostra as características e o texto ao tocar', (
    tester,
  ) async {
    when(
      () => getFeatures(classIndex: 'fighter', raceIndex: 'dwarf', level: 4),
    ).thenAnswer((_) async => features);
    when(() => getDetail('darkvision', RuleFeatureKind.racialTrait)).thenAnswer(
      (_) async => const RuleFeatureDetail(
        index: 'darkvision',
        name: 'Darkvision',
        desc: ['Enxerga no escuro.'],
      ),
    );
    sl.registerFactory<FeaturesBloc>(
      () => FeaturesBloc(getFeatures, getDetail),
    );
    addTearDown(sl.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FeaturesSection(character: buildTestCharacter()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fighter — nível 1'), findsOneWidget);
    expect(find.text('Second Wind'), findsOneWidget);
    expect(find.text('Traços de Dwarf'), findsOneWidget);

    await tester.tap(find.text('Darkvision'));
    await tester.pumpAndSettle();
    expect(find.text('Enxerga no escuro.'), findsOneWidget);
  });
}
