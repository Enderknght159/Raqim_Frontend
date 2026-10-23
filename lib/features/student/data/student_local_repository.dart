import 'package:drift/drift.dart';

import '../../../core/utils/date_time_utils.dart';
import '../domain/models/student_models.dart';
import '../domain/quran_units.dart';
import '../domain/student_stats.dart';
import 'local/student_database.dart' as db;

/// Local (drift-backed) student repository. Swap for a remote implementation
/// once the backend is ready — the screens depend on this interface shape.
class StudentLocalRepository {
  StudentLocalRepository(this._database);

  final db.StudentDatabase _database;

  Future<StudentProfileModel> profile() async {
    final row = await (_database.select(_database.students)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    final phones = await (_database.select(_database.phones)
          ..where((t) => t.studentId.equals(1)))
        .get();
    return StudentProfileModel(
      id: row.id,
      name: row.name,
      fatherName: row.fatherName,
      yearOfBirth: row.yearOfBirth,
      barcode: row.barcode,
      lastSeenAt: row.lastSeenAt,
      phones: [
        for (final p in phones)
          Phone(id: p.id, phone: p.phone, type: p.type),
      ],
    );
  }

  Future<List<Course>> courses() async {
    final rows = await _database.select(_database.courses).get();
    return rows.map(_mapCourse).toList();
  }

  /// Mosque display name (student profile header). Falls back to the demo
  /// mosque for databases seeded before the key existed.
  Future<String> mosqueName() async {
    final row = await (_database.select(_database.appMeta)
          ..where((t) => t.key.equals('mosque_name')))
        .getSingleOrNull();
    final value = row?.value.trim() ?? '';
    return value.isEmpty ? 'جامع الفرقان' : value;
  }

  Future<List<Team>> teams() async {
    final links = await (_database.select(_database.studentTeams)
          ..where((t) => t.studentId.equals(1)))
        .get();
    final teamIds = links.map((l) => l.teamId).toList();
    if (teamIds.isEmpty) return const [];
    final rows = await (_database.select(_database.teams)
          ..where((t) => t.id.isIn(teamIds)))
        .get();
    return rows
        .map((t) => Team(
              id: t.id,
              name: t.name,
              typeName: t.typeName,
              teacherName: t.teacherName,
            ))
        .toList();
  }

  Future<List<StudentBrief>> peersOfTeam(int teamId) async {
    final links = await (_database.select(_database.studentTeams)
          ..where((t) => t.teamId.equals(teamId) & t.studentId.isNotValue(1)))
        .get();
    final ids = links.map((l) => l.studentId).toList();
    if (ids.isEmpty) return const [];
    final rows = await (_database.select(_database.students)
          ..where((t) => t.id.isIn(ids)))
        .get();
    return rows
        .map((s) => StudentBrief(
              id: s.id,
              name: s.name,
              yearOfBirth: s.yearOfBirth,
            ))
        .toList();
  }

  /// Course leaderboard: every student with a record in the course (plus the
  /// current student), sorted by their points in this course (attendance +
  /// memorization + transactions).
  Future<List<StudentLeaderboardEntry>> leaderboard(int courseId) async {
    final course = await (_database.select(_database.courses)
          ..where((t) => t.id.equals(courseId)))
        .getSingle();
    final sessions = await (_database.select(_database.sessions)
          ..where((t) => t.courseId.equals(courseId)))
        .get();
    final sessionIds = sessions.map((s) => s.id).toList();
    if (sessionIds.isEmpty) return const [];

    final attendance = await (_database.select(_database.attendances)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .get();
    final mems = await (_database.select(_database.memorizations)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .get();
    final txs = await (_database.select(_database.transactions)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .get();

    // Candidates: current student + everyone with any record in the course.
    final ids = <int>{
      1,
      ...attendance.map((a) => a.studentId),
      ...mems.map((m) => m.studentId),
      ...txs.map((t) => t.studentId),
    };

    final entries = <StudentLeaderboardEntry>[];
    for (final id in ids) {
      final student = await (_database.select(_database.students)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (student == null) continue;
      final points = await _studentPoints(
          id,
          course: _mapCourse(course),
          sessionIds: sessionIds);
      entries.add(StudentLeaderboardEntry(
        rank: 0,
        student: StudentBrief(
          id: student.id,
          name: student.name,
          yearOfBirth: student.yearOfBirth,
        ),
        points: points,
      ));
    }

    entries.sort((a, b) => b.points.compareTo(a.points));
    for (var i = 0; i < entries.length; i++) {
      entries[i] = StudentLeaderboardEntry(
        rank: i + 1,
        student: entries[i].student,
        points: entries[i].points,
      );
    }
    return entries;
  }

  /// Points within a course for a given student: attendance + memorization
  /// (per page units) + total-affecting transactions.
  Future<int> _studentPoints(
    int studentId, {
    required Course course,
    required List<int> sessionIds,
  }) async {
    if (sessionIds.isEmpty) return 0;
    var points = 0;

    final sessions = await (_database.select(_database.sessions)
          ..where((t) => t.id.isIn(sessionIds)))
        .get()
        .then((rows) => rows
            .map((s) => Session(
                  id: s.id,
                  courseId: s.courseId,
                  date: s.date,
                  earlyPoints: s.earlyPoints,
                  midPoints: s.midPoints,
                  latePoints: s.latePoints,
                  earlyUntil: s.earlyUntil,
                  lateFrom: s.lateFrom,
                  orderInCourse: s.orderInCourse,
                ))
            .toList());
    final att = await (_database.select(_database.attendances)
          ..where((t) => t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
        .get();
    final attBySession = {for (final a in att) a.sessionId: a};
    for (final s in sessions) {
      final a = attBySession[s.id];
      if (a?.arrivalTime != null) {
        points += s.pointsFor(s.categoryFor(a!.arrivalTime!));
      }
    }

    final mems = await (_database.select(_database.memorizations)
          ..where((t) => t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
        .get();
    for (final m in mems) {
      final parts = m.parts <= 0 ? 1 : m.parts;
      points +=
          (course.memorizationPointsForRating(m.rating) / parts).round();
    }

    final txs = await (_database.select(_database.transactions)
          ..where((t) => t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
        .get();
    for (final t in txs) {
      final v = t.pointsValue.abs();
      switch (TransactionType.fromValue(t.type)) {
        case TransactionType.reward:
          points += v;
        case TransactionType.penalty:
          points -= v;
        case TransactionType.incomeExpense:
          points += v;
        default:
          break; // purchase / collection do not affect the total balance
      }
    }
    return points;
  }

  Future<List<CourseOverview>> courseOverviews() async {
    final courses = await this.courses();
    final overviews = <CourseOverview>[];
    for (final course in courses) {
      final bundle = await courseBundle(course.id);
      // Only courses the student has records in (BR-406: membership is
      // inferred from records; upcoming/empty courses are skipped).
      if (_hasNoRecords(bundle)) continue;
      final lastUpdated = _lastUpdated(bundle);
      // Real rank inside the course (self included) — never a fixed 1.
      final standings = await leaderboard(course.id);
      final selfRank = standings
          .where((e) => e.student.id == 1)
          .map((e) => e.rank)
          .firstOrNull;
      overviews.add(CourseOverview(
        course: course,
        points: bundle.breakdown,
        attendance: bundle.attendanceSummary,
        rank: selfRank,
        lastUpdated: lastUpdated,
      ));
    }
    overviews.sort((a, b) {
      final ad = a.lastUpdated ?? DateTime(2000);
      final bd = b.lastUpdated ?? DateTime(2000);
      return bd.compareTo(ad);
    });
    return overviews;
  }

  bool _hasNoRecords(StudentCourseBundle bundle) =>
      bundle.attendance.isEmpty &&
      bundle.memorizations.isEmpty &&
      bundle.transactions.isEmpty &&
      bundle.examSubmissions.isEmpty &&
      bundle.certificates.isEmpty &&
      bundle.matnRecitations.isEmpty;

  Future<StudentCourseBundle> courseBundle(
    int courseId, {
    int studentId = 1,
  }) async {
    final courseRow = await (_database.select(_database.courses)
          ..where((t) => t.id.equals(courseId)))
        .getSingle();
    final sessionRows = await (_database.select(_database.sessions)
          ..where((t) => t.courseId.equals(courseId)))
        .get();
    final sessionIds = sessionRows.map((s) => s.id).toList();

    final sessions = sessionRows
        .map((s) => Session(
              id: s.id,
              courseId: s.courseId,
              date: s.date,
              earlyPoints: s.earlyPoints,
              midPoints: s.midPoints,
              latePoints: s.latePoints,
              earlyUntil: s.earlyUntil,
              lateFrom: s.lateFrom,
              orderInCourse: s.orderInCourse,
            ))
        .toList()
      ..sort((a, b) => a.orderInCourse.compareTo(b.orderInCourse));

    final attendance = sessionIds.isEmpty
        ? <AttendanceRecord>[]
        : (await (_database.select(_database.attendances)
                ..where((t) =>
                    t.studentId.equals(studentId) &
                    t.sessionId.isIn(sessionIds)))
              .get())
            .map((a) =>
                AttendanceRecord(sessionId: a.sessionId, arrivalTime: a.arrivalTime))
            .toList();

    final memorizations = sessionIds.isEmpty
        ? <Memorization>[]
        : (await (_database.select(_database.memorizations)
                ..where((t) =>
                    t.studentId.equals(studentId) &
                    t.sessionId.isIn(sessionIds)))
              .get())
            .map(_mapMemorization)
            .toList();

    final transactions = sessionIds.isEmpty
        ? <StudentTransaction>[]
        : (await (_database.select(_database.transactions)
                ..where((t) =>
                    t.studentId.equals(studentId) &
                    t.sessionId.isIn(sessionIds)))
              .get())
            .map(_mapTransaction)
            .toList();

    final exams = (await (_database.select(_database.exams)
              ..where((t) => t.courseId.equals(courseId)))
          .get())
        .map(_mapExam)
        .toList();
    final examIds = exams.map((e) => e.id).toList();
    final examSubmissions = examIds.isEmpty
        ? <ExamSubmission>[]
        : (await (_database.select(_database.examSubmissions)
                ..where((t) =>
                    t.studentId.equals(studentId) & t.examId.isIn(examIds)))
              .get())
            .map((s) => ExamSubmission(examId: s.examId, mark: s.mark, date: s.date))
            .toList();

    final certificates = (await (_database.select(_database.certificates)
              ..where((t) =>
                  t.studentId.equals(studentId) & t.courseId.equals(courseId)))
          .get())
        .map(_mapCertificate)
        .toList();

    final matns = await this.matns();
    final matnRecitations = await this.matnRecitations(studentId: studentId);

    return StudentCourseBundle(
      course: _mapCourse(courseRow),
      sessions: sessions,
      attendance: attendance,
      memorizations: memorizations,
      exams: exams,
      examSubmissions: examSubmissions,
      certificates: certificates,
      matns: matns,
      matnRecitations: matnRecitations,
      transactions: transactions,
    );
  }

  Future<List<Memorization>> allMemorizations() async {
    final rows = await (_database.select(_database.memorizations)
          ..where((t) => t.studentId.equals(1)))
        .get();
    return rows.map(_mapMemorization).toList();
  }

  Future<List<Certificate>> certificates() async {
    final rows = await (_database.select(_database.certificates)
          ..where((t) => t.studentId.equals(1)))
        .get();
    return rows.map(_mapCertificate).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<Matn>> matns() async {
    final rows = await _database.select(_database.matns).get();
    return rows
        .map((m) => Matn(
              id: m.id,
              name: m.name,
              pointsPerVerse: m.pointsPerVerse,
              totalVerses: m.totalVerses,
            ))
        .toList();
  }

  Future<List<MatnRecitation>> matnRecitations({int studentId = 1}) async {
    final rows = await (_database.select(_database.matnRecitations)
          ..where((t) => t.studentId.equals(studentId)))
        .get();
    return rows
        .map((r) => MatnRecitation(
              matnId: r.matnId,
              lastVerse: r.lastVerse,
              teacherName: r.teacherName,
              sessionId: r.sessionId,
            ))
        .toList();
  }

  /// Latest matn recitation per matn (BR-555: latest wins).
  Future<Map<int, MatnRecitation>> latestMatnRecitations() async {
    final all = await matnRecitations();
    final result = <int, MatnRecitation>{};
    for (final r in all) {
      result[r.matnId] = r;
    }
    return result;
  }

  Future<List<({Exam exam, ExamSubmission? submission})>> examsWithSubmissions() async {
    final exams = (await _database.select(_database.exams).get())
        .map(_mapExam)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final submissions = (await (_database.select(_database.examSubmissions)
              ..where((t) => t.studentId.equals(1)))
            .get())
        .map((s) => ExamSubmission(examId: s.examId, mark: s.mark, date: s.date))
        .toList();
    final byExam = {for (final s in submissions) s.examId: s};
    return [
      for (final e in exams) (exam: e, submission: byExam[e.id]),
    ];
  }

  Future<QuranStats> quranStats() async =>
      computeQuranStats(await allMemorizations());

  // ── Notifications (activity feed) ───────────────────────────────────────

  /// All records ever added for the student — across all courses — turned
  /// into notifications, sorted by time (newest first).
  Future<List<StudentNotification>> notifications() async {
    final items = <StudentNotification>[];
    final teamByName = <int, String>{};

    final teams = await this.teams();
    for (final t in teams) {
      teamByName[t.id] = t.name;
    }

    // Administration notices (e.g. absence notices for a session).
    final notices = await (_database.select(_database.studentNotices)
          ..where((t) => t.studentId.equals(1) | t.studentId.equals(0)))
        .get();
    for (final n in notices) {
      items.add(StudentNotification(
        id: 'notice-${n.id}',
        when: n.date,
        kind: NotificationKind.notice,
        title: n.title,
        body: n.body,
      ));
    }

    // Team joins.
    final teamLinks = await (_database.select(_database.studentTeams)
          ..where((t) => t.studentId.equals(1)))
        .get();
    for (final link in teamLinks) {
      items.add(StudentNotification(
        id: 'team-${link.teamId}',
        when: link.date ?? DateTime.now(),
        kind: NotificationKind.team,
        title: 'الانضمام إلى حلقة',
        body: teamByName[link.teamId] ?? 'حلقة جديدة',
      ));
    }

    // Attendance (needs the session date range).
    final attendance = await (_database.select(_database.attendances)
          ..where((t) => t.studentId.equals(1)))
        .get();
    if (attendance.isNotEmpty) {
      final sessionIds = attendance.map((a) => a.sessionId).toList();
      final sessions = await (_database.select(_database.sessions)
            ..where((t) => t.id.isIn(sessionIds)))
          .get();
      final sessionMap = {for (final s in sessions) s.id: s};
      for (final a in attendance) {
        final session = sessionMap[a.sessionId];
        final arrival = a.arrivalTime;
        if (arrival == null) continue;
        final category = _categoryLabel(session, arrival);
        items.add(StudentNotification(
          id: 'att-${a.id}',
          when: arrival,
          kind: NotificationKind.attendance,
          title: 'تسجيل حضور',
          body: '$category — الساعة ${formatTime(arrival)}',
        ));
      }
    }

    // Memorization.
    final mems = await (_database.select(_database.memorizations)
          ..where((t) => t.studentId.equals(1)))
        .get();
    for (final m in mems) {
      items.add(StudentNotification(
        id: 'mem-${m.id}',
        when: m.date,
        kind: NotificationKind.memorization,
        title: 'تسجيل حفظ',
        body: 'صفحة ${m.page} · ${quranDisplaySurah(m.page, m.partIndex, m.surah)}'
            ' — تقييم ${m.rating} · المسمِّع: ${m.reciterName}',
      ));
    }

    // Transactions.
    final txs = await (_database.select(_database.transactions)
          ..where((t) => t.studentId.equals(1)))
        .get();
    for (final t in txs) {
      final type = TransactionType.fromValue(t.type);
      items.add(StudentNotification(
        id: 'tx-${t.id}',
        when: t.date,
        kind: NotificationKind.transaction,
        title: type.arabic,
        body:
            '${_txSigned(type, t.pointsValue)} نقطة'
            '${t.description == null || t.description!.isEmpty ? '' : ' · ${t.description}'}',
      ));
    }

    // Exam submissions.
    final submissions = await (_database.select(_database.examSubmissions)
          ..where((t) => t.studentId.equals(1)))
        .get();
    if (submissions.isNotEmpty) {
      final examIds = submissions.map((s) => s.examId).toSet().toList();
      final exams = await (_database.select(_database.exams)
            ..where((t) => t.id.isIn(examIds)))
          .get();
      final examMap = {
        for (final e in exams) e.id: e,
      };
      for (final s in submissions) {
        final exam = examMap[s.examId];
        items.add(StudentNotification(
          id: 'exam-${s.id}',
          when: s.date,
          kind: NotificationKind.exam,
          title: 'نتيجة امتحان',
          body:
              '${exam?.subjectName ?? 'مادة'} · ${ExamType.fromValue(exam?.type).arabic}'
              ' — الدرجة ${_fmtMark(s.mark)}',
        ));
      }
    }

    // Certificates.
    final certs = await (_database.select(_database.certificates)
          ..where((t) => t.studentId.equals(1)))
        .get();
    for (final c in certs) {
      items.add(StudentNotification(
        id: 'cert-${c.id}',
        when: c.date,
        kind: NotificationKind.certificate,
        title: 'شهادة قرآنية',
        body:
            'الجزء ${c.startJuz} – ${c.endJuz} · الدرجة ${c.mark}'
            '${c.byHeart ? ' · بالغيب' : ''}',
      ));
    }

    // Matn tasmi'.
    final matnRecs = await (_database.select(_database.matnRecitations)
          ..where((t) => t.studentId.equals(1)))
        .get();
    if (matnRecs.isNotEmpty) {
      final sessionIds =
          matnRecs.map((r) => r.sessionId).whereType<int>().toSet().toList();
      final sessions = sessionIds.isEmpty
          ? <db.Session>[]
          : await (_database.select(_database.sessions)
                ..where((t) => t.id.isIn(sessionIds)))
              .get();
      final sessionMap = {for (final s in sessions) s.id: s};
      final matns = await this.matns();
      final matnMap = {for (final m in matns) m.id: m};
      for (final r in matnRecs) {
        final session = sessionMap[r.sessionId];
        items.add(StudentNotification(
          id: 'matn-${r.id}',
          when: session?.date ?? DateTime.now(),
          kind: NotificationKind.matn,
          title: 'تسميع متن',
          body:
              '${matnMap[r.matnId]?.name ?? 'متن'} — البيت الأخير ${r.lastVerse}'
              ' · ${r.teacherName}',
        ));
      }
    }

    items.sort((a, b) => b.when.compareTo(a.when));
    return items;
  }

  Future<DateTime?> lastNotifRead() async {
    final row = await (_database.select(_database.appMeta)
          ..where((t) => t.key.equals('notif_last_read')))
        .getSingleOrNull();
    final raw = row?.value;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> markNotifRead() async {
    final now = DateTime.now();
    final existing = await (_database.select(_database.appMeta)
          ..where((t) => t.key.equals('notif_last_read')))
        .getSingleOrNull();
    if (existing == null) {
      await _database.into(_database.appMeta).insert(
            db.AppMetaCompanion.insert(
                key: 'notif_last_read', value: now.toIso8601String()),
          );
    } else {
      await (_database.update(_database.appMeta)
            ..where((t) => t.key.equals('notif_last_read')))
          .write(db.AppMetaCompanion(value: Value(now.toIso8601String())));
    }
  }

  Future<int> unreadNotifications() async {
    final all = await notifications();
    final lastRead = await lastNotifRead();
    if (lastRead == null) return all.length;
    return all.where((n) => n.when.isAfter(lastRead)).length;
  }

  String _categoryLabel(db.Session? row, DateTime arrival) {
    if (row == null) return 'وصل';
    final session = Session(
      id: row.id,
      courseId: row.courseId,
      date: row.date,
      earlyPoints: row.earlyPoints,
      midPoints: row.midPoints,
      latePoints: row.latePoints,
      earlyUntil: row.earlyUntil,
      lateFrom: row.lateFrom,
      orderInCourse: row.orderInCourse,
    );
    return switch (session.categoryFor(arrival)) {
      AttendanceCategory.early => 'وصل مبكرًا',
      AttendanceCategory.onTime => 'وصل في الوقت',
      AttendanceCategory.late => 'وصل متأخرًا',
      AttendanceCategory.absent => 'وصل',
    };
  }

  String _fmtMark(double mark) =>
      mark == mark.roundToDouble() ? '${mark.toInt()}' : '$mark';

  // ── Mappers ─────────────────────────────────────────────────────────────

  Course _mapCourse(db.Course r) => Course(
        id: r.id,
        name: r.name,
        startDate: r.startDate,
        endDate: r.endDate,
        goodPoints: r.goodPoints,
        veryGoodPoints: r.veryGoodPoints,
        excellentPoints: r.excellentPoints,
        certificatePoints: r.certificatePoints,
      );

  Memorization _mapMemorization(db.Memorization r) => Memorization(
        sessionId: r.sessionId,
        page: r.page,
        partIndex: r.partIndex,
        parts: r.parts,
        surah: r.surah,
        rating: r.rating,
        reciterName: r.reciterName,
        date: r.date,
      );

  StudentTransaction _mapTransaction(db.Transaction r) => StudentTransaction(
        sessionId: r.sessionId,
        type: TransactionType.fromValue(r.type),
        pointsValue: r.pointsValue,
        date: r.date,
        description: r.description,
      );

  Exam _mapExam(db.Exam r) => Exam(
        id: r.id,
        courseId: r.courseId,
        subjectName: r.subjectName,
        date: r.date,
        type: ExamType.fromValue(r.type),
        maxMark: r.maxMark,
        minSuccessMark: r.minSuccessMark,
        points: r.points,
      );

  Certificate _mapCertificate(db.Certificate r) => Certificate(
        courseId: r.courseId,
        startJuz: r.startJuz,
        endJuz: r.endJuz,
        mark: r.mark,
        byHeart: r.byHeart,
        date: r.date,
      );

  DateTime? _lastUpdated(StudentCourseBundle bundle) {
    DateTime? latest;
    void consider(DateTime d) {
      if (latest == null || d.isAfter(latest!)) latest = d;
    }

    for (final a in bundle.attendance) {
      if (a.arrivalTime != null) consider(a.arrivalTime!);
    }
    for (final m in bundle.memorizations) {
      consider(m.date);
    }
    for (final t in bundle.transactions) {
      consider(t.date);
    }
    return latest;
  }
}

String _txSigned(TransactionType type, int value) {
  final v = value.abs();
  return switch (type) {
    TransactionType.reward ||
    TransactionType.collection ||
    TransactionType.incomeExpense =>
      '+$v',
    _ => '-$v',
  };
}
