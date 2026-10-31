import 'package:drift/drift.dart';

/// Fallback for platforms without a local database implementation.
QueryExecutor openAppDatabaseConnection() {
  return LazyDatabase(
    () async => throw UnsupportedError(
      'The local cache database is not available on this platform.',
    ),
  );
}
