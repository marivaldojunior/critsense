import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

/// Transformer que cancela o processamento de um evento anterior sempre que
/// um novo evento do mesmo tipo chega, mantendo em andamento apenas a
/// resposta mais recente — evita que um toque duplo/rápido (ex: dois
/// `FilterToggled` seguidos) produza uma corrida entre duas respostas de
/// rede, deixando a mais antiga sobrescrever a mais nova.
EventTransformer<E> restartable<E>() {
  return (events, mapper) => events.switchMap(mapper);
}

/// Combina debounce com [restartable]: aguarda [duration] de silêncio entre
/// eventos antes de processar o mais recente, e ainda cancela o
/// processamento anterior se um novo evento (já fora da janela de debounce)
/// chegar antes dele terminar.
///
/// Uso típico: `SearchQueryChanged` de uma busca por texto — evita disparar
/// uma requisição a cada letra digitada.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}
