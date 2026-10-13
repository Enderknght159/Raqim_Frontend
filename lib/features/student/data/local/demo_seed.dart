import 'package:drift/drift.dart';

import 'student_database.dart' as db;

/// Seeds the local database with one demo student's full dataset. Idempotent —
/// runs only once (guarded by a marker row in `AppMeta`).
Future<void> seedDemoDataIfNeeded(db.StudentDatabase database) async {
  final marker = await (database.select(database.appMeta)
        ..where((t) => t.key.equals('seeded')))
      .getSingleOrNull();
  if (marker != null) return;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // ── Student + profile ──────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
      database.students,
      db.StudentsCompanion.insert(
        id: const Value(1),
        name: 'عبد الرحمن محمود',
        fatherName: const Value('محمود'),
        yearOfBirth: const Value(2012),
        barcode: 'st-532',
        lastSeenAt: Value(now.subtract(const Duration(hours: 6))),
      ),
    );
    b.insert(
      database.phones,
      db.PhonesCompanion.insert(
        id: const Value(1),
        studentId: 1,
        phone: '+201001112233',
        type: 'parent',
      ),
    );
    b.insert(
      database.phones,
      db.PhonesCompanion.insert(
        id: const Value(2),
        studentId: 1,
        phone: '+201009998877',
        type: 'student',
      ),
    );
  });

  // ── Teams + peers ──────────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
      database.teams,
      db.TeamsCompanion.insert(
        id: const Value(1),
        name: 'حلقة القرآن - أ',
        typeName: 'قرآن',
        teacherName: const Value('أ. محمود عبد الله'),
      ),
    );
    b.insert(
      database.teams,
      db.TeamsCompanion.insert(
        id: const Value(2),
        name: 'حلقة المستوى العام',
        typeName: 'عام',
        teacherName: const Value('أ. سامي حسن'),
      ),
    );
    b.insert(
      database.studentTeams,
      db.StudentTeamsCompanion.insert(
        id: const Value(1),
        studentId: 1,
        teamId: 1,
        date: Value(today.subtract(const Duration(days: 28))),
      ),
    );
    b.insert(
      database.studentTeams,
      db.StudentTeamsCompanion.insert(
        id: const Value(2),
        studentId: 1,
        teamId: 2,
        date: Value(today.subtract(const Duration(days: 28))),
      ),
    );

    const peers = [
      'يوسف أحمد',
      'خالد إبراهيم',
      'عمر مصطفى',
      'زياد طارق',
      'بلال أنس',
    ];
    for (var i = 0; i < peers.length; i++) {
      final id = 10 + i;
      b.insert(
        database.students,
        db.StudentsCompanion.insert(
          id: Value(id),
          name: peers[i],
          yearOfBirth: Value(2012 + i),
          barcode: 'st-$id',
        ),
      );
      b.insert(
        database.studentTeams,
        db.StudentTeamsCompanion.insert(
          id: Value(10 + i),
          studentId: id,
          teamId: 1,
          date: Value(today.subtract(const Duration(days: 28))),
        ),
      );
    }
  });

  // ── Course + sessions ──────────────────────────────────────────────────
  final courseStart = today.subtract(const Duration(days: 28));
  final courseEnd = today.add(const Duration(days: 28));
  await database.into(database.courses).insert(
        db.CoursesCompanion.insert(
          id: const Value(1),
          name: 'دورة الحفظ الصيفية',
          startDate: courseStart,
          endDate: courseEnd,
          goodPoints: const Value(1),
          veryGoodPoints: const Value(2),
          excellentPoints: const Value(3),
          certificatePoints: const Value(10),
        ),
      );

  final sessionCount = 14;
  for (var i = 0; i < sessionCount; i++) {
    final date = courseStart.add(Duration(days: i * 2));
    await database.into(database.sessions).insert(
          db.SessionsCompanion.insert(
            id: Value(100 + i),
            courseId: 1,
            date: DateTime(date.year, date.month, date.day, 16),
            orderInCourse: Value(i + 1),
          ),
        );
  }

  // ── Attendance (varied categories + a few absences) ────────────────────
  final attendancePattern = <int>[
    0, 0, 1, 0, 2, 0, 0, 1, 0, 0, 2, 0, 0, 1,
  ];
  for (var i = 0; i < sessionCount; i++) {
    final day = courseStart.add(Duration(days: i * 2));
    // Skip attendance for two sessions (absence).
    if (i == 5 || i == 10) continue;
    final category = attendancePattern[i];
    final hour = switch (category) {
      0 => 15, // early (<= 16:00)
      2 => 16, // late (>= 16:30)
      _ => 16, // on time (16:15)
    };
    final minute = switch (category) {
      0 => 45,
      2 => 40,
      _ => 15,
    };
    await database.into(database.attendances).insert(
          db.AttendancesCompanion.insert(
            id: Value(200 + i),
            studentId: 1,
            sessionId: 100 + i,
            arrivalTime: Value(DateTime(day.year, day.month, day.day, hour, minute)),
          ),
        );
  }

  // ── Memorization (juz 30 pages) ────────────────────────────────────────
  var memId = 300;
  final pages = [581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592];
  for (var i = 0; i < pages.length; i++) {
    final day = courseStart.add(Duration(days: i * 2));
    await database.into(database.memorizations).insert(
          db.MemorizationsCompanion.insert(
            id: Value(memId++),
            studentId: 1,
            sessionId: 100 + i,
            page: pages[i],
            partIndex: const Value(1),
            parts: const Value(1),
            surah: const Value('عمّ'),
            rating: 1 + (i % 3),
            reciterName: const Value('أ. محمود عبد الله'),
            date: DateTime(day.year, day.month, day.day, 16, 30),
          ),
        );
  }

  // ── Transactions (all 5 types) ─────────────────────────────────────────
  final txDay = courseStart.add(const Duration(days: 6));
  await database.batch((b) {
    b.insert(
      database.transactions,
      db.TransactionsCompanion.insert(
        id: const Value(400),
        studentId: 1,
        sessionId: 103,
        type: 'reward',
        pointsValue: 5,
        date: txDay,
        description: const Value('مكافأة انتظام'),
      ),
    );
    b.insert(
      database.transactions,
      db.TransactionsCompanion.insert(
        id: const Value(401),
        studentId: 1,
        sessionId: 105,
        type: 'penalty',
        pointsValue: 2,
        date: txDay.add(const Duration(days: 4)),
        description: const Value('خصم تأخير'),
      ),
    );
    b.insert(
      database.transactions,
      db.TransactionsCompanion.insert(
        id: const Value(402),
        studentId: 1,
        sessionId: 107,
        type: 'purchase',
        pointsValue: 3,
        date: txDay.add(const Duration(days: 8)),
        description: const Value('شراء من المتجر'),
      ),
    );
    b.insert(
      database.transactions,
      db.TransactionsCompanion.insert(
        id: const Value(403),
        studentId: 1,
        sessionId: 109,
        type: 'collection',
        pointsValue: 4,
        date: txDay.add(const Duration(days: 12)),
        description: const Value('تحصيل نقاط سابقة'),
      ),
    );
    b.insert(
      database.transactions,
      db.TransactionsCompanion.insert(
        id: const Value(404),
        studentId: 1,
        sessionId: 111,
        type: 'incomeExpense',
        pointsValue: 6,
        date: txDay.add(const Duration(days: 14)),
        description: const Value('دخل وصرف في عملية واحدة'),
      ),
    );
  });

  // ── Exams + submissions ────────────────────────────────────────────────
  await database.batch((b) {
    b.insert(
      database.exams,
      db.ExamsCompanion.insert(
        id: const Value(500),
        courseId: 1,
        subjectName: 'القرآن الكريم',
        date: courseStart.add(const Duration(days: 10)),
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
        date: courseStart.add(const Duration(days: 16)),
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
        date: courseStart.add(const Duration(days: 22)),
        type: 'final',
        maxMark: 100,
        minSuccessMark: 50,
        points: const Value(40),
      ),
    );
    b.insert(
      database.examSubmissions,
      db.ExamSubmissionsCompanion.insert(
        id: const Value(600),
        studentId: 1,
        examId: 500,
        mark: 44.0,
        date: courseStart.add(const Duration(days: 10)),
      ),
    );
    b.insert(
      database.examSubmissions,
      db.ExamSubmissionsCompanion.insert(
        id: const Value(601),
        studentId: 1,
        examId: 501,
        mark: 18.0,
        date: courseStart.add(const Duration(days: 16)),
      ),
    );
    b.insert(
      database.examSubmissions,
      db.ExamSubmissionsCompanion.insert(
        id: const Value(602),
        studentId: 1,
        examId: 502,
        mark: 88.0,
        date: courseStart.add(const Duration(days: 22)),
      ),
    );
  });

  // ── Certificate ────────────────────────────────────────────────────────
  await database.into(database.certificates).insert(
        db.CertificatesCompanion.insert(
          id: const Value(700),
          studentId: 1,
          courseId: 1,
          startJuz: 30,
          endJuz: 30,
          mark: 95,
          byHeart: const Value(true),
          date: courseStart.add(const Duration(days: 20)),
        ),
      );

  // ── Matn + recitations ─────────────────────────────────────────────────
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
      database.matnRecitations,
      db.MatnRecitationsCompanion.insert(
        id: const Value(900),
        studentId: 1,
        matnId: 800,
        lastVerse: 30,
        teacherName: const Value('أ. سامي حسن'),
        sessionId: 110,
      ),
    );
    b.insert(
      database.matnRecitations,
      db.MatnRecitationsCompanion.insert(
        id: const Value(901),
        studentId: 1,
        matnId: 801,
        lastVerse: 40,
        teacherName: const Value('أ. سامي حسن'),
        sessionId: 112,
      ),
    );
  });

  // ── Peer points (leaderboard demo data) ────────────────────────────────
  // Peers have varying attendance/memorization/rewards so the course
  // leaderboard ("الطلاب الأوائل") ranks realistically.
  final peerProfiles = <int, ({int sessions, int mem, int reward, int late})>{
    10: (sessions: 10, mem: 10, reward: 12, late: 1),
    11: (sessions: 8, mem: 7, reward: 8, late: 2),
    12: (sessions: 6, mem: 4, reward: 5, late: 1),
    13: (sessions: 3, mem: 2, reward: 2, late: 2),
    14: (sessions: 1, mem: 0, reward: 0, late: 0),
  };
  var peerTxId = 1000;
  var peerMemId = 2000;
  for (final entry in peerProfiles.entries) {
    final peerId = entry.key;
    final profile = entry.value;
    final attended =
        profile.sessions < sessionCount ? profile.sessions : sessionCount;
    for (var i = 0; i < attended; i++) {
      if (i == 5 || i == 10) continue; // mirror absences
      final day = courseStart.add(Duration(days: i * 2));
      final isLate = profile.late > 0 && (i % profile.late) == 0 && i != 0;
      await database.into(database.attendances).insert(
            db.AttendancesCompanion.insert(
              id: Value(2000 + peerId * 100 + i),
              studentId: peerId,
              sessionId: 100 + i,
              arrivalTime: Value(
                DateTime(day.year, day.month, day.day,
                    isLate ? 16 : 15, isLate ? 40 : 45),
              ),
            ),
          );
    }
    for (var k = 0; k < profile.mem; k++) {
      final day = courseStart.add(Duration(days: k * 2));
      await database.into(database.memorizations).insert(
            db.MemorizationsCompanion.insert(
              id: Value(peerMemId++),
              studentId: peerId,
              sessionId: 100 + k,
              page: 550 + k,
              partIndex: const Value(1),
              parts: const Value(1),
              surah: const Value('عمّ'),
              rating: 1 + (k % 3),
              reciterName: const Value('أ. محمود عبد الله'),
              date: DateTime(day.year, day.month, day.day, 16, 30),
            ),
          );
    }
    if (profile.reward > 0) {
      await database.into(database.transactions).insert(
            db.TransactionsCompanion.insert(
              id: Value(peerTxId++),
              studentId: peerId,
              sessionId: 100,
              type: 'reward',
              pointsValue: profile.reward,
              date: courseStart,
              description: const Value('مكافأة'),
            ),
          );
    }
  }

  // ── Mark as seeded ─────────────────────────────────────────────────────
  await database.into(database.appMeta).insert(
        db.AppMetaCompanion.insert(key: 'seeded', value: '1'),
      );
}
