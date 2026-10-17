import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crit_sense/di/injection_container.dart';
import 'package:crit_sense/features/character_sheet/presentation/bloc/character_bloc.dart';
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
    subclassFeatures: [],
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

  testWidgets('escolher a subclasse do SRD mostra as características dela', (
    tester,
  ) async {
    when(
      () => getFeatures(classIndex: 'fighter', raceIndex: 'dwarf', level: 4),
    ).thenAnswer((_) async => features);
    when(
      () => getFeatures(
        classIndex: 'fighter',
        raceIndex: 'dwarf',
        level: 4,
        subclassIndex: 'champion',
      ),
    ).thenAnswer(
      (_) async => (
        classFeatures: features.classFeatures,
        subclassFeatures: const [
          ClassLevelFeatures(
            level: 3,
            features: [
              ApiReference(
                index: 'improved-critical',
                name: 'Improved Critical',
              ),
            ],
          ),
        ],
        racialTraits: features.racialTraits,
      ),
    );
    sl.registerFactory<FeaturesBloc>(
      () => FeaturesBloc(getFeatures, getDetail),
    );
    addTearDown(sl.reset);
    final character = buildTestCharacter();
    final (:bloc, saveCharacter: _) =
        await tester.runAsync(() => loadedCharacterBloc([character])) ??
        (throw StateError('bloc não carregou'));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: SingleChildScrollView(
              child: BlocBuilder<CharacterBloc, CharacterState>(
                builder: (context, state) => FeaturesSection(
                  character: state.findCharacter('c1') ?? character,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Escolha a subclasse.'), findsOneWidget);

    await tester.tap(find.text('Escolher'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Campeão'));
    await tester.runAsync(
      () => bloc.stream
          .firstWhere((s) => s.findCharacter('c1')?.subclass == 'champion')
          .timeout(const Duration(seconds: 5)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Campeão'), findsOneWidget);
    expect(find.text('Campeão — nível 3'), findsOneWidget);
    expect(find.text('Improved Critical'), findsOneWidget);
  });

  test('a subclasse vem no nível certo de cada classe', () {
    expect(buildTestCharacter(level: 2).canChooseSubclass, isFalse);
    expect(buildTestCharacter(level: 3).canChooseSubclass, isTrue);
    expect(
      buildTestCharacter(characterClass: 'Cleric', level: 1).canChooseSubclass,
      isTrue,
    );
    final homebrew = buildTestCharacter().copyWith(
      subclass: 'Cavaleiro Rúnico',
    );
    expect(homebrew.srdSubclassIndex, isNull);
    expect(homebrew.subclassName, 'Cavaleiro Rúnico');
    expect(homebrew.copyWith(clearSubclass: true).subclass, isNull);
  });
}
