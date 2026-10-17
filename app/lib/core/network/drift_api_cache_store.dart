import '../database/app_database.dart';
import 'offline_cache_interceptor.dart';

/// [ApiCacheStore] na tabela `api_cache` do banco do app.
class DriftApiCacheStore implements ApiCacheStore {
  DriftApiCacheStore(this._db);

  final AppDatabase _db;

  @override
  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.apiCache,
    )..where((t) => t.requestKey.equals(key))).getSingleOrNull();
    return row?.body;
  }

  @override
  Future<void> write(String key, String body) async {
    await _db
        .into(_db.apiCache)
        .insertOnConflictUpdate(
          ApiCacheCompanion.insert(
            requestKey: key,
            body: body,
            fetchedAt: DateTime.now(),
          ),
        );
  }
}
