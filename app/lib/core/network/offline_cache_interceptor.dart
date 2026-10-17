import 'dart:convert';

import 'package:dio/dio.dart';

/// Onde o [OfflineCacheInterceptor] guarda as respostas.
abstract interface class ApiCacheStore {
  /// Corpo JSON guardado para [key], ou `null`.
  Future<String?> read(String key);

  /// Guarda [body] para [key] (substitui o anterior).
  Future<void> write(String key, String body);
}

/// Guarda no aparelho as respostas GET do compêndio e as usa quando não há
/// rede.
///
/// A ordem é "rede primeiro": com internet, a resposta sempre vem da API e
/// atualiza a cópia guardada. Sem internet (erro de conexão ou timeout), a
/// requisição recebe a última cópia guardada, com `extra['fromCache']` =
/// `true`. Erros da API (ex: 404) não usam a cópia: eles passam adiante.
class OfflineCacheInterceptor extends Interceptor {
  OfflineCacheInterceptor(this._store);

  /// Chave de `RequestOptions.extra`/`Response.extra` que marca uma resposta
  /// vinda da cópia guardada.
  static const fromCacheKey = 'fromCache';

  final ApiCacheStore _store;

  static String keyFor(RequestOptions options) => options.uri.toString();

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    if (options.method == 'GET' &&
        response.statusCode == 200 &&
        response.data != null) {
      try {
        await _store.write(keyFor(options), jsonEncode(response.data));
      } catch (_) {
        // Falhar ao guardar a cópia não pode quebrar a resposta da API.
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (options.method != 'GET' || !_isNetworkFailure(err)) {
      handler.next(err);
      return;
    }
    String? cached;
    try {
      cached = await _store.read(keyFor(options));
    } catch (_) {
      cached = null;
    }
    if (cached == null) {
      handler.next(err);
      return;
    }
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        data: jsonDecode(cached),
        statusCode: 200,
        extra: {fromCacheKey: true},
      ),
    );
  }

  /// Sem conexão ou sem resposta a tempo. Erros com resposta da API (4xx,
  /// 5xx) não contam: a cópia guardada não resolve um pedido errado.
  static bool _isNetworkFailure(DioException err) => switch (err.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => true,
    DioExceptionType.unknown => err.response == null,
    _ => false,
  };
}
