import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/compendium/domain/entities/api_reference.dart';
import 'package:crit_sense/features/compendium/domain/entities/rule_feature.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_character_features_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_rule_feature_detail_usecase.dart';

sealed class FeaturesEvent {
  const FeaturesEvent();
}

/// Carrega as características da classe [classIndex] até o [level] e os
/// traços da raça [raceIndex]. Índices `null` = classe ou raça fora do SRD.
final class LoadFeaturesEvent extends FeaturesEvent {
  final String? classIndex;
  final String? raceIndex;
  final int level;

  /// Subclasse do SRD; `null` = sem subclasse ou fora do SRD.
  final String? subclassIndex;

  const LoadFeaturesEvent({
    required this.classIndex,
    required this.raceIndex,
    required this.level,
    this.subclassIndex,
  });
}

/// Busca o texto da característica [index] (uma vez; depois fica guardado).
final class LoadFeatureDetailEvent extends FeaturesEvent {
  final String index;
  final RuleFeatureKind kind;

  const LoadFeatureDetailEvent(this.index, this.kind);
}

enum FeaturesStatus { initial, loading, success, failure }

class FeaturesState extends Equatable {
  final FeaturesStatus status;
  final List<ClassLevelFeatures> classFeatures;
  final List<ClassLevelFeatures> subclassFeatures;
  final List<ApiReference> racialTraits;

  /// Textos já buscados, por índice.
  final Map<String, RuleFeatureDetail> details;

  /// Índices cujo texto não pôde ser buscado (ex: sem internet).
  final Set<String> failedDetails;

  const FeaturesState({
    this.status = FeaturesStatus.initial,
    this.classFeatures = const [],
    this.subclassFeatures = const [],
    this.racialTraits = const [],
    this.details = const {},
    this.failedDetails = const {},
  });

  FeaturesState copyWith({
    FeaturesStatus? status,
    List<ClassLevelFeatures>? classFeatures,
    List<ClassLevelFeatures>? subclassFeatures,
    List<ApiReference>? racialTraits,
    Map<String, RuleFeatureDetail>? details,
    Set<String>? failedDetails,
  }) {
    return FeaturesState(
      status: status ?? this.status,
      classFeatures: classFeatures ?? this.classFeatures,
      subclassFeatures: subclassFeatures ?? this.subclassFeatures,
      racialTraits: racialTraits ?? this.racialTraits,
      details: details ?? this.details,
      failedDetails: failedDetails ?? this.failedDetails,
    );
  }

  @override
  List<Object?> get props => [
    status,
    classFeatures,
    subclassFeatures,
    racialTraits,
    details,
    failedDetails,
  ];
}

/// Características de classe e traços raciais do SRD, vindos do compêndio.
class FeaturesBloc extends Bloc<FeaturesEvent, FeaturesState> {
  final GetCharacterFeaturesUseCase _getFeatures;
  final GetRuleFeatureDetailUseCase _getDetail;

  FeaturesBloc(this._getFeatures, this._getDetail)
    : super(const FeaturesState()) {
    on<LoadFeaturesEvent>(_onLoad);
    on<LoadFeatureDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoad(
    LoadFeaturesEvent event,
    Emitter<FeaturesState> emit,
  ) async {
    emit(state.copyWith(status: FeaturesStatus.loading));
    try {
      final features = await _getFeatures(
        classIndex: event.classIndex,
        raceIndex: event.raceIndex,
        level: event.level,
        subclassIndex: event.subclassIndex,
      );
      emit(
        state.copyWith(
          status: FeaturesStatus.success,
          classFeatures: features.classFeatures,
          subclassFeatures: features.subclassFeatures,
          racialTraits: features.racialTraits,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FeaturesStatus.failure));
    }
  }

  Future<void> _onLoadDetail(
    LoadFeatureDetailEvent event,
    Emitter<FeaturesState> emit,
  ) async {
    if (state.details.containsKey(event.index)) return;
    emit(
      state.copyWith(
        failedDetails: {...state.failedDetails}..remove(event.index),
      ),
    );
    try {
      final detail = await _getDetail(event.index, event.kind);
      emit(state.copyWith(details: {...state.details, event.index: detail}));
    } catch (_) {
      emit(
        state.copyWith(failedDetails: {...state.failedDetails, event.index}),
      );
    }
  }
}
