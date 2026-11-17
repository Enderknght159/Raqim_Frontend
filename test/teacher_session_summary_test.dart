import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/utils/identity_code.dart';
import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';
import 'package:raqim/features/teacher/domain/teacher_models.dart';

AdminSessionRecord _record({
  required String kind,
  required String title,
  String subtitle = '',
  required DateTime when,
}) {
  return AdminSessionRecord(
    id: when.microsecondsSinceEpoch,
    kind: kind,
    studentId: 7,
    studentName: 'حمزة فؤاد',
    title: title,
    subtitle: subtitle,
    when: when,
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('mosque-scoped identity', () {
    test('the mosque code is the only prefix for barcodes and usernames', () {
      expect(mosqueScopedCode('aby', 532), 'aby-532');
      expect(ensureMosqueUsername('aby', 'ali'), 'aby-ali');
      expect(ensureMosqueUsername('aby', 'aby-ali'), 'aby-ali');
      expect(hasMosquePrefix('aby', 'aby-ali'), isTrue);
      expect(hasMosquePrefix('aby', 'st-ali'), isFalse);
    });

    test(
      'new students and seed data use the mosque code, never st-*',
      () async {
        final db = StudentDatabase.forTesting(NativeDatabase.memory());
        await seedDemoDataIfNeeded(db);
        final repo = AdminLocalRepository(db);

        final seeded = await repo.students();
        expect(seeded, isNotEmpty);
        expect(seeded.every((row) => row.barcode.startsWith('frq-')), isTrue);

        final id = await repo.addStudent(name: 'طالب جديد');
        final rows = await repo.students();
        final created = rows.where((row) => row.id == id).single;
        expect(created.barcode, 'frq-$id');
      },
    );
  });

  group('TeacherSessionSummary', () {
    test('summarises pages, last matn and net points', () {
      final base = DateTime(2026, 11, 14, 17);
      final records = [
        _record(
          kind: 'memorization',
          title: 'حفظ صفحة 12 — يوسف',
          when: base.add(const Duration(minutes: 5)),
        ),
        _record(
          kind: 'memorization',
          title: 'حفظ صفحة 13 — الرعد',
          when: base.add(const Duration(minutes: 4)),
        ),
        _record(
          kind: 'memorization',
          title: 'حفظ صفحة 12 — يوسف',
          when: base.add(const Duration(minutes: 3)),
        ),
        _record(
          kind: 'matn',
          title: 'متن الأجرومية — البيت الأخير 12',
          when: base.add(const Duration(minutes: 2)),
        ),
        _record(
          kind: 'transaction',
          title: 'مكافأة · 5 نقطة',
          when: base.add(const Duration(minutes: 1)),
        ),
        _record(kind: 'transaction', title: 'عقوبة · 3 نقطة', when: base),
      ];

      final summary = TeacherSessionSummary.fromRecords(records);
      expect(summary.pages, 2, reason: 'repeated page 12 counts once');
      expect(summary.lastMatn, 'متن الأجرومية');
      expect(summary.lastVerse, 12);
      expect(summary.points, 2);
      expect(summary.pointsLabel, '+2 نقطة');
    });

    test('empty records produce an empty summary', () {
      final summary = TeacherSessionSummary.fromRecords(const []);
      expect(summary.isEmpty, isTrue);
      expect(summary.matnLabel, isNull);
      expect(summary.pointsLabel, isNull);
    });
  });
}
