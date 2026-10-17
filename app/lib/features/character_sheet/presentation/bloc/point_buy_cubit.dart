import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crit_sense/features/character_sheet/domain/entities/attribute.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/attribute_type.dart';
import 'package:crit_sense/features/character_sheet/domain/entities/point_buy_rules.dart';

part 'point_buy_state.dart';

/// Gerencia a alocação dos 27 pontos de Compra de Pontos entre os seis
/// atributos base do formulário de criação de personagem.
///
/// `Cubit` (em vez de `Bloc`) porque cada transição é uma chamada de método
/// direta e síncrona (incrementar/decrementar um atributo) — não há eventos
/// distintos disparados por múltiplas origens que justifiquem a indireção
/// de um `Event` sealed.
class PointBuyCubit extends Cubit<PointBuyState> {
  PointBuyCubit() : super(const PointBuyState());

  void increment(AttributeType type) {
    if (!state.canIncrement(type)) return;
    final newValue = state.attributes.valueOf(type) + 1;
    emit(state.copyWith(attributes: state.attributes.withValue(type, newValue)));
  }

  void decrement(AttributeType type) {
    if (!state.canDecrement(type)) return;
    final newValue = state.attributes.valueOf(type) - 1;
    emit(state.copyWith(attributes: state.attributes.withValue(type, newValue)));
  }

  void reset() => emit(const PointBuyState());
}
