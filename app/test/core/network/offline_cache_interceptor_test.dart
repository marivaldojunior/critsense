import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crit_sense/core/database/app_database.dart';
import 'package:crit_sense/core/network/drift_api_cache_store.dart';
import 'package:crit_sense/core/network/offline_cache_interceptor.dart';

/// Adaptador HTTP falso: responde [body] com [statusCode], ou falha como sem
/// rede quando [online] é `false`.
class _FakeAdapter implements HttpClientAdapter {
  bool online = true;
  int statusCode = 200;
  Object body = const {'results': []};
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (!online) throw const SocketException('sem rede');
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Testa o uso do compêndio sem internet.
void main() {
  late AppDatabase db;
  late _FakeAdapter adapter;
  late Dio dio;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    adapter = _FakeAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
      ..httpClientAdapter = adapter
      ..interceptors.add(OfflineCacheInterceptor(DriftApiCacheStore(db)));
  });

  tearDown(() => db.close());

  test('com rede a resposta vem da API e fica guardada', () async {
    adapter.body = {
      'results': [
        {'index': 'fireball'},
      ],
    };

    final response = await dio.get<Map<String, dynamic>>('spells');

    expect(response.data!['results'], hasLength(1));
    expect(response.extra[OfflineCacheInterceptor.fromCacheKey], isNot(true));
    expect(await db.select(db.apiCache).get(), hasLength(1));
  });

  test('sem rede devolve a última cópia guardada', () async {
    adapter.body = {'name': 'Fireball', 'level': 3};
    await dio.get<Map<String, dynamic>>('spells/fireball');

    adapter.online = false;
    final response = await dio.get<Map<String, dynamic>>('spells/fireball');

    expect(response.data!['level'], 3);
    expect(response.extra[OfflineCacheInterceptor.fromCacheKey], isTrue);
  });

  test('a cópia é por URL completa, incluindo os filtros', () async {
    adapter.body = {
      'results': ['a'],
    };
    await dio.get<Map<String, dynamic>>(
      'spells',
      queryParameters: {'level': 1},
    );

    adapter.online = false;
    await expectLater(
      dio.get<Map<String, dynamic>>('spells', queryParameters: {'level': 2}),
      throwsA(isA<DioException>()),
    );
    final cached = await dio.get<Map<String, dynamic>>(
      'spells',
      queryParameters: {'level': 1},
    );
    expect(cached.data!['results'], ['a']);
  });

  test('com rede a cópia é atualizada', () async {
    adapter.body = {'version': 1};
    await dio.get<Map<String, dynamic>>('classes');
    adapter.body = {'version': 2};
    await dio.get<Map<String, dynamic>>('classes');

    adapter.online = false;
    final response = await dio.get<Map<String, dynamic>>('classes');

    expect(response.data!['version'], 2);
  });

  test('sem rede e sem cópia, o erro de rede passa adiante', () async {
    adapter.online = false;

    await expectLater(
      dio.get<Map<String, dynamic>>('monsters'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          anyOf(DioExceptionType.connectionError, DioExceptionType.unknown),
        ),
      ),
    );
  });

  test('erro da API (404) não usa a cópia guardada', () async {
    adapter.body = {'name': 'Old'};
    await dio.get<Map<String, dynamic>>('spells/old');

    adapter
      ..statusCode = 404
      ..body = {'error': 'Not found'};
    await expectLater(
      dio.get<Map<String, dynamic>>('spells/old'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.badResponse,
        ),
      ),
    );
  });
}
