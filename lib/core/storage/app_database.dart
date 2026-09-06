import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Local cache of recent network reads (students by scope, session
/// attendance). Network-first with cache fallback when offline.
class CacheEntries extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get scope => text()();
  TextColumn get entityType => text()();
  TextColumn get jsonData => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

/// Field-level offline write queue (BR-713): every write is enqueued, then
/// flushed to the server immediately when online or kept pending otherwise.
class ChangeQueueEntries extends Table {
  IntColumn get changeId => integer().autoIncrement()();
  TextColumn get entity => text()();
  IntColumn get objectId => integer()();
  TextColumn get field => text()();
  TextColumn get value => text()();
  DateTimeColumn get clientTs => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
}

/// Log of accepted/pending/rejected changes for the sync UI.
class SyncLogEntries extends Table {
  IntColumn get syncId => integer().autoIncrement()();
  IntColumn get changeId => integer().nullable()();
  TextColumn get entity => text()();
  IntColumn get objectId => integer()();
  TextColumn get status => text()(); // accepted | pending | rejected
  TextColumn get message => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [CacheEntries, ChangeQueueEntries, SyncLogEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'raqim.sqlite'));
      return NativeDatabase(file);
    });
  }
}