import 'package:drift/drift.dart';

/// Fallback for platforms without a local database implementation.
QueryExecutor openStudentDatabaseConnection() {
  return LazyDatabase(
    () async => throw UnsupportedError(
      'The local student database is not available on this platform.',
    ),
  );
}
