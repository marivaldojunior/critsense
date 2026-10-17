import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/compendium/domain/entities/api_reference.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_classes_usecase.dart';
import 'package:crit_sense/features/compendium/domain/usecases/get_races_usecase.dart';

part 'form_options_event.dart';
part 'form_options_state.dart';

/// BLoC responsável por carregar em paralelo as listas de classes e raças
/// necessárias para popular os dropdowns do formulário de personagem.
class FormOptionsBloc extends Bloc<FormOptionsEvent, FormOptionsState> {
  final GetClassesUseCase _getClasses;
  final GetRacesUseCase _getRaces;

  /// Injeta os use cases e registra o handler de [LoadFormOptionsEvent].
  FormOptionsBloc(GetClassesUseCase getClasses, GetRacesUseCase getRaces)
    : _getClasses = getClasses,
      _getRaces = getRaces,
      super(FormOptionsLoading()) {
    on<LoadFormOptionsEvent>(_onLoad);
  }

  /// Carrega classes e raças em paralelo ao receber [LoadFormOptionsEvent].
  ///
  /// `Future.wait([])` é o equivalente Dart de `Task.WhenAll(...)` no C#:
  /// ambos disparam múltiplas operações assíncronas simultaneamente e aguardam
  /// a conclusão de **todas** antes de prosseguir. A diferença é que no Dart
  /// `Future.wait` retorna uma `List<T>` onde `T` é o tipo comum das futures
  /// (aqui, `List<ApiReference>`), enquanto `Task.WhenAll` retorna `Task<T[]>`.
  /// O ganho é real: em vez de ~600ms sequenciais (300ms + 300ms), obtemos
  /// ~300ms totais — o tempo do request mais lento.
  Future<void> _onLoad(
    LoadFormOptionsEvent event,
    Emitter<FormOptionsState> emit,
  ) async {
    emit(FormOptionsLoading());
    try {
      final results = await Future.wait([_getClasses(), _getRaces()]);
      emit(FormOptionsLoaded(classes: results[0], races: results[1]));
    } catch (e) {
      emit(FormOptionsError(e.toString()));
    }
  }
}
