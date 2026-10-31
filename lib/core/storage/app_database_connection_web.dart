import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web cache connection backed by drift's WASM SQLite implementation.
QueryExecutor openAppDatabaseConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'raqim_cache',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
