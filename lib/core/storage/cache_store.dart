import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// Read-only offline cache backed by the local drift database.
///
/// Keys are namespaced by [scope] (the active account) so one account never
/// reads another account's cached data. Cache failures are ignored; the app
/// continues to work online.
class CacheStore {
  CacheStore(this._db);

  final AppDatabase _db;

  /// Active account namespace, e.g. `user:29` or `anon`.
  String scope = 'anon';

  static Future<CacheStore> open() async => CacheStore(AppDatabase());

  String _key(String key) => '$scope::$key';

  Future<void> writeJson(
    String key,
    Object data, {
    String entityType = 'json',
  }) async {
    try {
      await _db
          .into(_db.cacheEntries)
          .insertOnConflictUpdate(
            CacheEntriesCompanion.insert(
              cacheKey: _key(key),
              scope: scope,
              entityType: entityType,
              jsonData: jsonEncode(data),
              cachedAt: Value(DateTime.now()),
            ),
          );
    } catch (_) {
      // Best-effort: a cache write must never break a successful request.
    }
  }

  /// Profile cache is global (not account-scoped) so an offline restart can
  /// restore the last active account.
  Future<void> writeAuthJson(String key, Object data) async {
    final previous = scope;
    scope = 'auth';
    try {
      await writeJson(key, data, entityType: 'profile');
    } finally {
      scope = previous;
    }
  }

  Future<Object?> readAuthJson(String key) async {
    final previous = scope;
    scope = 'auth';
    try {
      return await readJson(key);
    } finally {
      scope = previous;
    }
  }

  Future<Object?> readJson(String key) async {
    try {
      final row = await (_db.select(
        _db.cacheEntries,
      )..where((t) => t.cacheKey.equals(_key(key)))).getSingleOrNull();
      if (row == null) return null;
      return jsonDecode(row.jsonData);
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      await (_db.delete(
        _db.cacheEntries,
      )..where((t) => t.cacheKey.equals(_key(key)))).go();
    } catch (_) {}
  }

  Future<void> clearScope() async {
    try {
      await (_db.delete(
        _db.cacheEntries,
      )..where((t) => t.scope.equals(scope))).go();
    } catch (_) {}
  }
}
