import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Mobile/desktop connection backed by a SQLite file in app support storage.
QueryExecutor openStudentDatabaseConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'raqim_student.sqlite'));
    return NativeDatabase(file);
  });
}
