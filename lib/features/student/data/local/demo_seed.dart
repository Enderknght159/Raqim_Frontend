import 'package:drift/drift.dart';

import '../../domain/quran_units.dart';
import 'student_database.dart' as db;

/// Seeds the local database with a full mosque demo dataset:
/// - 3 courses (نشطة / منتهية / قادمة)
/// - 40 students across 5 teams (4 types, 4 teachers)
/// - rich records: attendance, memorization (incl. multi-unit pages),
///   matn recitations, transactions, exams, certificates, distributions.
/// Idempotent — runs only once (guarded by a marker row in `AppMeta`).
Future<void> seedDemoDataIfNeeded(db.StudentDatabase database) async {
  final marker = await (database.select(database.appMeta)
        ..where((t) => t.key.equals('seeded')))
      .getSingleOrNull();
  if (marker != null) return;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // ── Teams + team types ─────────────────────────────────────────────────
  const teams = [
    (id: 1, name: 'حلقة القرآن - أ', type: 'قرآن', teacher: 'أ. محمود عبد الله'),
    (id: 2, name: 'حلقة المستوى العام', type: 'عام', teacher: 'أ. سامي حسن'),
    (id: 3, name: 'حلقة القرآن - ب', type: 'قرآن', teacher: 'أ. خالد الراجحي'),
    (id: 4, name: 'حلقة التلاوة', type: 'مستوى', teacher: 'أ. إبراهيم صالح'),
    (id: 5, name: 'حلقة القرآن - ج', type: 'قرآن', teacher: ''),
  ];
  await database.batch((b) {
    for (final t in teams) {
      b.insert(
        database.teams,
        db.TeamsCompanion.insert(
          id: Value(t.id),
          name: t.name,
          typeName: t.type,
          teacherName: Value(t.teacher),
        ),
      );
    }
    for (final t in const [
      (id: 1, name: 'قرآن', note: null),
      (id: 2, name: 'عام', note: null),
      (id: 3, name: 'مستوى', note: 'مؤجّل'),
      (id: 4, name: 'تلاوة', note: null),
    ]) {
      b.insert(
        database.teamTypes,
        db.TeamTypesCompanion.insert(
          id: Value(t.id),
          name: t.name,
          note: Value(t.note),
        ),
      );
    }
  });

  // ── Students (40) + team links + phones ────────────────────────────────
  // Team assignment rotates deterministically; a student may belong to two
  // teams of different types (BR-604).
  const names = [
    'عبد الرحمن محمود', // demo student (id 1)
    'يوسف أحمد', 'خالد إبراهيم', 'عمر مصطفى', 'زياد طارق',
    'بلال أنس', 'حمزة فؤاد', 'أحمد سمير', 'سيف الدين ماجد', 'معاذ توفيق',
    'عبد الله هشام', 'مصعب وليد', 'أنس جمال', 'محمد رشاد', 'إياد كامل',
    'فارس عماد', 'أيوب نادر', 'زيد الهادي', 'هشام عبد القادر', 'رامي سعيد',
    'طلحة منير', 'بدر فتحي', 'إبراهيم نبيل', 'كريم عادل', 'مازن عاطف',
    'صهيب رامي', 'قتيبة شاكر', 'عامر زياد', 'وليد قاسم', 'يحيى رمضان',
    'أسامة ناجي', 'عمار خليل', 'جهاد سميح', 'سامي طلال', 'محمود سراج',
    'نور الدين صابر', 'علي رضا', 'صالح أمين', 'طه مازن', 'أوس غالب',
  ];
  const teamPool = [1, 1, 3, 1, 2, 4, 3, 5, 2, 4]; // balanced-ish
  var linkId = 1000;
  var phoneId = 100;
  await database.batch((b) {
    for (var i = 0; i < names.length; i++) {
      final id = i + 1;
      final teamId = teamPool[i % teamPool.length];
      // Legacy barcode for a few existing students (BR-625/707), custom
      // mosque-code barcode for the rest.
      final barcode = (id == 1 || id == 3 || id == 7)
          ? 'st-${530 + id}'
          : 'frq-$id';
      b.insert(
        database.students,
        db.StudentsCompanion.insert(
          id: Value(id),
          name: names[i],
          fatherName: Value('أب ${names[i].split(' ').last}'),
          yearOfBirth: Value(2009 + (i % 8)),
          barcode: barcode,
          lastSeenAt: Value(now.subtract(Duration(hours: i % 48))),
        ),
      );
      b.insert(
        database.studentTeams,
        db.StudentTeamsCompanion.insert(
          id: Value(linkId++),
          studentId: id,
          teamId: teamId,
          date: Value(today.subtract(const Duration(days: 40))),
        ),
      );
      // Every third student is in a second team (different type).
      if (i % 3 == 0) {
        final second = teamId == 2 ? 1 : 2;
        b.insert(
          database.studentTeams,
          db.StudentTeamsCompanion.insert(
            id: Value(linkId++),
            studentId: id,
            teamId: second,
            date: Value(today.subtract(const Duration(days: 40))),
          ),
        );
      }
      // Two phones for the demo student, one parent phone per ~half.
      if (id == 1) {
        b.insert(
          database.phones,
          db.PhonesCompanion.insert(
            id: Value(phoneId++),
            studentId: id,
            phone: '+201001112233',
            type: 'parent',
          ),
        );
        b.insert(
          database.phones,
          db.PhonesCompanion.insert(
            id: Value(phoneId++),
            studentId: id,
            phone: '+201009998877',
            type: 'student',
          ),
        );
      } else if (i.isEven) {
        b.insert(
          database.phones,
          db.PhonesCompanion.insert(
            id: Value(phoneId++),
            studentId: id,
            phone: '+2010${10000000 + i * 137}',
            type: 'parent',
          ),
        );
      }
    }
  });

  // ── Courses ─────────────────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
      database.courses,
      db.CoursesCompanion.insert(
        id: const Value(1),
        name: 'دورة الحفظ الصيفية',
        startDate: today.subtract(const Duration(days: 28)),
        endDate: today.add(const Duration(days: 28)),
        goodPoints: const Value(1),
        veryGoodPoints: const Value(2),
        excellentPoints: const Value(3),
        certificatePoints: const Value(10),
      ),
    );
    b.insert(
      database.courses,
      db.CoursesCompanion.insert(
        id: const Value(2),
        name: 'دورة رمضانية',
        startDate: today.subtract(const Duration(days: 90)),
        endDate: today.subtract(const Duration(days: 35)),
        goodPoints: const Value(1),
        veryGoodPoints: const Value(2),
        excellentPoints: const Value(3),
        certificatePoints: const Value(10),
      ),
    );
    b.insert(
      database.courses,
      db.CoursesCompanion.insert(
        id: const Value(3),
        name: 'دورة التجويد المكثفة',
        startDate: today.add(const Duration(days: 10)),
        endDate: today.add(const Duration(days: 40)),
      ),
    );
  });

  // ── Sessions ────────────────────────────────────────────────────────────
  // Course 1 (active): 14 sessions every 2 days — ids 100..113.
  final c1Start = today.subtract(const Duration(days: 28));
  for (var i = 0; i < 14; i++) {
    final date = c1Start.add(Duration(days: i * 2));
    await database.into(database.sessions).insert(
          db.SessionsCompanion.insert(
            id: Value(100 + i),
            courseId: 1,
            date: DateTime(date.year, date.month, date.day, 16),
            orderInCourse: Value(i + 1),
          ),
        );
  }
  // Course 2 (ended): 17 sessions every 3 days — ids 120..136.
  final c2Start = today.subtract(const Duration(days: 90));
  for (var i = 0; i < 17; i++) {
    final date = c2Start.add(Duration(days: i * 3));
    await database.into(database.sessions).insert(
          db.SessionsCompanion.insert(
            id: Value(120 + i),
            courseId: 2,
            date: DateTime(date.year, date.month, date.day, 17),
            orderInCourse: Value(i + 1),
          ),
        );
  }

  // ── Attendance ──────────────────────────────────────────────────────────
  // Deterministic per-student attendance: everyone attends most sessions;
  // some arrive early/late; a few absences sprinkled per student.
  Future<void> seedAttendance({
    required int courseId,
    required int sessionBase,
    required int sessionCount,
    required int idBase,
    required List<int> courseStudentIds,
  }) async {
    var nextId = idBase;
    for (var i = 0; i < sessionCount; i++) {
      for (final studentId in courseStudentIds) {
        final absences = studentId % 7;
        if (i % 7 == absences) continue; // deterministic absence slot
        final lateEvery = 5 + (studentId % 3);
        final early = studentId % 2 == 0;
        final isLate = lateEvery > 0 && i % lateEvery == 0 && i != 0;
        final day = switch (courseId) {
          1 => c1Start.add(Duration(days: i * 2)),
          _ => c2Start.add(Duration(days: i * 3)),
        };
        final hour = isLate ? 16 : (early ? 15 : 16);
        final minute = isLate ? 40 : (early ? 45 : 5 + (studentId % 20));
        await database.into(database.attendances).insert(
              db.AttendancesCompanion.insert(
                id: Value(nextId++),
                studentId: studentId,
                sessionId: sessionBase + i,
                arrivalTime: Value(
                    DateTime(day.year, day.month, day.day, hour, minute)),
              ),
            );
      }
    }
  }

  final allStudentIds = List.generate(names.length, (i) => i + 1);
  await seedAttendance(
    courseId: 1,
    sessionBase: 100,
    sessionCount: 14,
    idBase: 10000,
    courseStudentIds: allStudentIds,
  );
  await seedAttendance(
    courseId: 2,
    sessionBase: 120,
    sessionCount: 17,
    idBase: 30000,
    courseStudentIds: allStudentIds,
  );

  // ── Memorization (with multi-unit page distribution, BR-513) ────────────
  var memId = 20000;
  Future<void> seedMemorization({
    required int courseId,
    required int sessionBase,
    required int sessionCount,
    required int studentId,
    required int firstPage,
    required int count,
  }) async {
    for (var k = 0; k < count; k++) {
      final i = k % sessionCount;
      final day = courseId == 1
          ? c1Start.add(Duration(days: i * 2))
          : c2Start.add(Duration(days: i * 3));
      final page = firstPage + k;
      final units = quranUnitsOfPage(page);
      // Record every unit of split pages; single pages get one record.
      for (final unit in units) {
        await database.into(database.memorizations).insert(
              db.MemorizationsCompanion.insert(
                id: Value(memId++),
                studentId: studentId,
                sessionId: sessionBase + i,
                page: unit.page,
                partIndex: Value(unit.partIndex),
                parts: Value(units.length),
                surah: Value(unit.surah),
                rating: 1 + (k + studentId) % 3,
                reciterName: const Value('أ. محمود عبد الله'),
                date: DateTime(day.year, day.month, day.day, 16, 30),
              ),
            );
      }
    }
  }

  // Demo student: juz-30 pages 581..592 (incl. split pages 583/587/589/591/592).
  await seedMemorization(
    courseId: 1, sessionBase: 100, sessionCount: 14,
    studentId: 1, firstPage: 581, count: 12,
  );
  // Demo student: a few pages in the ended course.
  await seedMemorization(
    courseId: 2, sessionBase: 120, sessionCount: 17,
    studentId: 1, firstPage: 540, count: 5,
  );
  // Every other student memorizes a stretch of pages in course 1.
  for (var s = 2; s <= names.length; s++) {
    await seedMemorization(
      courseId: 1, sessionBase: 100, sessionCount: 14,
      studentId: s,
      firstPage: 470 + (s % 8) * 15 + (s % 3),
      count: 6 + (s % 5),
    );
  }
  // Split-page (3-unit) samples: students 4, 11, 23 memorize all units of
  // the three-part pages 596 and 599.
  for (final (s, page) in [(4, 596), (11, 596), (23, 599)]) {
    final units = quranUnitsOfPage(page);
    for (var u = 0; u < units.length; u++) {
      final unit = units[u];
      final day = c1Start.add(const Duration(days: 20));
      await database.into(database.memorizations).insert(
            db.MemorizationsCompanion.insert(
              id: Value(memId++),
              studentId: s,
              sessionId: 110,
              page: unit.page,
              partIndex: Value(unit.partIndex),
              parts: Value(units.length),
              surah: Value(unit.surah),
              rating: 2 + (u % 2),
              reciterName: const Value('أ. محمود عبد الله'),
              date: DateTime(day.year, day.month, day.day, 16, 40),
            ),
          );
    }
  }

  // ── Transactions (all 5 types) ──────────────────────────────────────────
  var txId = 400;
  Future<void> seedTx(int studentId, String type, int value,
      {int sessionId = 103, String? description}) async {
    await database.into(database.transactions).insert(
          db.TransactionsCompanion.insert(
            id: Value(txId++),
            studentId: studentId,
            sessionId: sessionId,
            type: type,
            pointsValue: value,
            date: c1Start.add(Duration(days: txId % 20)),
            description: Value(description),
          ),
        );
  }

  await seedTx(1, 'reward', 5, description: 'مكافأة انتظام');
  await seedTx(1, 'penalty', 2, sessionId: 105, description: 'خصم تأخير');
  await seedTx(1, 'purchase', 3, sessionId: 107, description: 'شراء من المتجر');
  await seedTx(1, 'collection', 4, sessionId: 109, description: 'تحصيل نقاط سابقة');
  await seedTx(1, 'incomeExpense', 6, sessionId: 111, description: 'دخل وصرف');
  for (var s = 2; s <= names.length; s++) {
    if (s % 2 == 0) {
      await seedTx(s, 'reward', 3 + (s % 5), sessionId: 100 + (s % 14));
    }
    if (s % 3 == 0) {
      await seedTx(s, 'penalty', 1 + (s % 2), sessionId: 101 + (s % 12));
    }
    if (s % 5 == 0) {
      await seedTx(s, 'purchase', 2, sessionId: 102 + (s % 11));
    }
  }

  // ── Exams + submissions ─────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
      database.exams,
      db.ExamsCompanion.insert(
        id: const Value(500),
        courseId: 1,
        subjectName: 'القرآن الكريم',
        date: c1Start.add(const Duration(days: 10)),
        type: 'oral',
        maxMark: 50,
        minSuccessMark: 25,
        points: const Value(20),
      ),
    );
    b.insert(
      database.exams,
      db.ExamsCompanion.insert(
        id: const Value(501),
        courseId: 1,
        subjectName: 'التجويد',
        date: c1Start.add(const Duration(days: 16)),
        type: 'writtenProbe',
        maxMark: 20,
        minSuccessMark: 10,
        points: const Value(10),
      ),
    );
    b.insert(
      database.exams,
      db.ExamsCompanion.insert(
        id: const Value(502),
        courseId: 1,
        subjectName: 'الحفظ',
        date: c1Start.add(const Duration(days: 22)),
        type: 'final',
        maxMark: 100,
        minSuccessMark: 50,
        points: const Value(40),
      ),
    );
    b.insert(
      database.exams,
      db.ExamsCompanion.insert(
        id: const Value(503),
        courseId: 2,
        subjectName: 'الحفظ',
        date: c2Start.add(const Duration(days: 40)),
        type: 'final',
        maxMark: 100,
        minSuccessMark: 50,
        points: const Value(40),
      ),
    );
  });

  var subId = 600;
  Future<void> seedSubmission(int studentId, int examId, double mark,
      {DateTime? date}) async {
    await database.into(database.examSubmissions).insert(
          db.ExamSubmissionsCompanion.insert(
            id: Value(subId++),
            studentId: studentId,
            examId: examId,
            mark: mark,
            date: date ?? c1Start.add(const Duration(days: 10)),
          ),
        );
  }

  await seedSubmission(1, 500, 44.0, date: c1Start.add(const Duration(days: 10)));
  await seedSubmission(1, 501, 18.0, date: c1Start.add(const Duration(days: 16)));
  await seedSubmission(1, 502, 88.0, date: c1Start.add(const Duration(days: 22)));
  await seedSubmission(1, 503, 74.0, date: c2Start.add(const Duration(days: 40)));
  for (var s = 2; s <= 10; s++) {
    await seedSubmission(s, 502, 40.0 + (s * 5) % 55,
        date: c1Start.add(const Duration(days: 22)));
  }

  // ── Certificates ────────────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
      database.certificates,
      db.CertificatesCompanion.insert(
        id: const Value(700),
        studentId: 1,
        courseId: 1,
        startJuz: 30,
        endJuz: 30,
        mark: 95,
        byHeart: const Value(true),
        date: c1Start.add(const Duration(days: 20)),
      ),
    );
    b.insert(
      database.certificates,
      db.CertificatesCompanion.insert(
        id: const Value(701),
        studentId: 2,
        courseId: 1,
        startJuz: 30,
        endJuz: 30,
        mark: 88,
        byHeart: const Value(true),
        date: c1Start.add(const Duration(days: 18)),
      ),
    );
    b.insert(
      database.certificates,
      db.CertificatesCompanion.insert(
        id: const Value(702),
        studentId: 9,
        courseId: 2,
        startJuz: 29,
        endJuz: 29,
        mark: 82,
        byHeart: const Value(false),
        date: c2Start.add(const Duration(days: 44)),
      ),
    );
  });

  // ── Matns + recitations ─────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
      database.matns,
      db.MatnsCompanion.insert(
        id: const Value(800),
        name: 'الأربعين النووية',
        pointsPerVerse: 2,
        totalVerses: 42,
      ),
    );
    b.insert(
      database.matns,
      db.MatnsCompanion.insert(
        id: const Value(801),
        name: 'متن الجزرية',
        pointsPerVerse: 3,
        totalVerses: 100,
      ),
    );
    b.insert(
      database.matns,
      db.MatnsCompanion.insert(
        id: const Value(802),
        name: 'تحفة الأطفال',
        pointsPerVerse: 1,
        totalVerses: 61,
      ),
    );
  });
  var matnRecId = 900;
  Future<void> seedMatnRec(int studentId, int matnId, int lastVerse,
      {int? sessionId}) async {
    await database.into(database.matnRecitations).insert(
          db.MatnRecitationsCompanion.insert(
            id: Value(matnRecId++),
            studentId: studentId,
            matnId: matnId,
            lastVerse: lastVerse,
            teacherName: const Value('أ. سامي حسن'),
            sessionId: sessionId ?? 110,
          ),
        );
  }

  await seedMatnRec(1, 800, 30);
  await seedMatnRec(1, 801, 40, sessionId: 112);
  for (var s = 2; s <= 12; s++) {
    await seedMatnRec(s, 800, 5 + (s % 30), sessionId: 104 + (s % 9));
    if (s % 2 == 0) {
      await seedMatnRec(s, 801, 10 + (s % 50), sessionId: 106 + (s % 7));
    }
  }

  // ── Admin content (subjects + distributables + distributions) ───────────
  await database.batch((b) {
    b.insert(database.subjects,
        db.SubjectsCompanion.insert(
            id: const Value(1), name: 'القرآن الكريم', book: const Value('المصحف')));
    b.insert(database.subjects,
        db.SubjectsCompanion.insert(
            id: const Value(2), name: 'التجويد', book: const Value('الجزرية')));
    b.insert(database.subjects,
        db.SubjectsCompanion.insert(id: const Value(3), name: 'الحفظ'));
    b.insert(database.subjects,
        db.SubjectsCompanion.insert(
            id: const Value(4), name: 'الفقه', book: const Value('الفقه الميسر')));

    b.insert(database.distributables,
        db.DistributablesCompanion.insert(id: const Value(1), name: 'مصحف'));
    b.insert(database.distributables,
        db.DistributablesCompanion.insert(
            id: const Value(2), name: 'دفتر', note: const Value('A5')));
    b.insert(database.distributables,
        db.DistributablesCompanion.insert(
            id: const Value(3), name: 'بطاقة مكافأة'));
  });
  var distId = 1;
  for (var s = 1; s <= names.length; s++) {
    await database.into(database.distributions).insert(
          db.DistributionsCompanion.insert(
            id: Value(distId++),
            studentId: s,
            distributableId: 1,
            count: const Value(1),
            date: c1Start,
          ),
        );
    if (s.isEven) {
      await database.into(database.distributions).insert(
            db.DistributionsCompanion.insert(
              id: Value(distId++),
              studentId: s,
              distributableId: 2,
              count: Value(1 + (s % 3)),
              date: c1Start,
            ),
          );
    }
  }

  // ── Change requests ─────────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
        database.changeRequests,
        db.ChangeRequestsCompanion.insert(
            id: const Value(1),
            studentId: 1,
            field: 'phoneNumber',
            currentValue: const Value('+201001112233'),
            requestedValue: '+201005554433',
            createdAt: Value(now.subtract(const Duration(days: 1)))));
    b.insert(
        database.changeRequests,
        db.ChangeRequestsCompanion.insert(
            id: const Value(2),
            studentId: 2,
            field: 'fatherName',
            currentValue: const Value('أب يوسف'),
            requestedValue: 'أحمد محمود',
            createdAt: Value(now.subtract(const Duration(days: 3)))));
    b.insert(
        database.changeRequests,
        db.ChangeRequestsCompanion.insert(
            id: const Value(3),
            studentId: 15,
            field: 'yearOfBirth',
            currentValue: const Value('2013'),
            requestedValue: '2012',
            createdAt: Value(now.subtract(const Duration(days: 5)))));
  });

  // ── Mark as seeded ─────────────────────────────────────────────────────
  await database.into(database.appMeta).insert(
        db.AppMetaCompanion.insert(key: 'seeded', value: '2'),
      );
}
