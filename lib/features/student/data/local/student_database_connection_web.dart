import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web connection backed by drift's WASM SQLite implementation.
///
/// `web/sqlite3.wasm` and `web/drift_worker.js` are bundled with the app.
QueryExecutor openStudentDatabaseConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'raqim_student',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
