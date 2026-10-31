import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Mobile/desktop cache connection (SQLite file in app support storage).
QueryExecutor openAppDatabaseConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'raqim_cache.sqlite'));
    return NativeDatabase(file);
  });
}
