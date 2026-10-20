import 'package:drift/drift.dart';

import '../../student/data/local/student_database.dart' as db;
import '../../student/data/student_local_repository.dart';
import '../../student/domain/models/student_models.dart';
import '../../student/domain/quran_units.dart';
import '../../student/domain/student_stats.dart';
import '../domain/admin_models.dart';

/// Admin/supervisor repository over the shared local database. Provides the
/// mosque-wide aggregates + management operations used by the admin shell.
class AdminLocalRepository {
  AdminLocalRepository(this._database)
      : _student = StudentLocalRepository(_database);

  final db.StudentDatabase _database;
  final StudentLocalRepository _student;

  // ── Aggregates ──────────────────────────────────────────────────────────

  Future<GeneralStats> generalStats() async {
    final students = await _database.select(_database.students).get();
    final teams = await _database.select(_database.teams).get();
    final courses = await _database.select(_database.courses).get();
    final teachers = teams
        .map((t) => t.teacherName)
        .where((n) => n.isNotEmpty)
        .toSet();
    final requests = await (_database.select(_database.changeRequests)
          ..where((t) => t.status.equals('pending')))
        .get();
    final mems = await _database.select(_database.memorizations).get();
    final pages = mems.map((m) => m.page).toSet().length;

    return GeneralStats(
      students: students.length,
      teams: teams.length,
      teachers: teachers.length,
      courses: courses.length,
      pendingRequests: requests.length,
      memorizedPages: pages,
    );
  }

  Future<List<AdminCourseSummary>> courses() async {
    final courseRows = await _database.select(_database.courses).get();
    final result = <AdminCourseSummary>[];
    for (final c in courseRows) {
      final sessions = await (_database.select(_database.sessions)
            ..where((t) => t.courseId.equals(c.id)))
          .get()
        ..sort((a, b) => a.orderInCourse.compareTo(b.orderInCourse));
      final sessionIds = sessions.map((s) => s.id).toList();
      final attendance = sessionIds.isEmpty
          ? const <db.Attendance>[]
          : await (_database.select(_database.attendances)
                ..where((t) => t.sessionId.isIn(sessionIds)))
              .get();
      final studentIds =
          attendance.map((a) => a.studentId).toSet();
      final today = _dateOnly(DateTime.now());
      final todaySessionIds = sessions
          .where((s) => _dateOnly(s.date) == today)
          .map((s) => s.id)
          .toSet();
      final todayPresent = attendance
          .where((a) => todaySessionIds.contains(a.sessionId) && a.arrivalTime != null)
          .length;

      final series = <double>[];
      for (final s in sessions) {
        final present = attendance
            .where((a) => a.sessionId == s.id && a.arrivalTime != null)
            .length;
        series.add(present.toDouble());
      }

      final expected = sessions.length * studentIds.length;
      final attended = attendance.where((a) => a.arrivalTime != null).length;

      result.add(AdminCourseSummary(
        id: c.id,
        name: c.name,
        startDate: c.startDate,
        endDate: c.endDate,
        isActive: !DateTime.now().isAfter(c.endDate),
        sessionsCount: sessions.length,
        studentsCount: studentIds.length,
        todayPresent: todayPresent,
        todayTotal: studentIds.length,
        attendancePercent:
            expected == 0 ? 0 : ((attended / expected) * 100).round(),
        series: series,
      ));
    }
    result.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return b.startDate.compareTo(a.startDate);
    });
    return result;
  }

  /// Full course bundle (records/points) reused from the student repository.
  Future<StudentCourseBundle> courseBundle(int courseId) =>
      _student.courseBundle(courseId);

  /// Full course bundle for one specific student (E7 → course achievement).
  Future<StudentCourseBundle> studentCourseBundle(
    int courseId,
    int studentId,
  ) =>
      _student.courseBundle(courseId, studentId: studentId);

  /// Mosque-wide leaderboard for a course: every student with any record in
  /// the course (attendance/memorization/transactions), ranked by points.
  Future<LeaderboardResult> leaderboard(int courseId) async {
    final course = await (_database.select(_database.courses)
          ..where((t) => t.id.equals(courseId)))
        .getSingle();
    final sessions = await (_database.select(_database.sessions)
          ..where((t) => t.courseId.equals(courseId)))
        .get();
    final sessionIds = sessions.map((s) => s.id).toList();
    if (sessionIds.isEmpty) return const LeaderboardResult([]);

    final attendance = await (_database.select(_database.attendances)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .get();
    final mems = await (_database.select(_database.memorizations)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .get();
    final txs = await (_database.select(_database.transactions)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .get();
    final ids = {
      ...attendance.map((a) => a.studentId),
      ...mems.map((m) => m.studentId),
      ...txs.map((t) => t.studentId),
    }.toList()..sort();
    final students = ids.isEmpty
        ? const <db.Student>[]
        : await (_database.select(_database.students)
              ..where((t) => t.id.isIn(ids)))
            .get();
    final byId = {for (final s in students) s.id: s};

    final entries = <StudentLeaderboardEntry>[];
    for (final id in ids) {
      final row = byId[id];
      if (row == null) continue;
      final points = await _studentPoints(
        id,
        course: _mapCourse(course),
        sessionIds: sessionIds,
      );
      entries.add(StudentLeaderboardEntry(
        rank: 0,
        student: StudentBrief(
          id: row.id,
          name: row.name,
          yearOfBirth: row.yearOfBirth,
        ),
        points: points,
      ));
    }
    entries.sort((a, b) => b.points.compareTo(a.points));
    return LeaderboardResult([
      for (var i = 0; i < entries.length; i++)
        StudentLeaderboardEntry(
          rank: i + 1,
          student: entries[i].student,
          points: entries[i].points,
        ),
    ]);
  }

  /// Most recent session across all courses (E1 quick shortcut).
  Future<AdminSessionRow?> lastSession() async {
    final sessions = await (_database.select(_database.sessions).get());
    if (sessions.isEmpty) return null;
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return _sessionRow(sessions.first);
  }

  Future<List<AdminSessionRow>> courseSessions(int courseId) async {
    final sessions = await (_database.select(_database.sessions)
          ..where((t) => t.courseId.equals(courseId)))
        .get()
      ..sort((a, b) => a.orderInCourse.compareTo(b.orderInCourse));
    final rows = <AdminSessionRow>[];
    for (final s in sessions) {
      rows.add(await _sessionRow(s));
    }
    return rows;
  }

  Future<AdminSessionRow> sessionRow(int sessionId) async {
    final s = await (_database.select(_database.sessions)
          ..where((t) => t.id.equals(sessionId)))
        .getSingle();
    return _sessionRow(s);
  }

  Future<AdminSessionRow> _sessionRow(db.Session s) async {
    final att = await (_database.select(_database.attendances)
          ..where((t) => t.sessionId.equals(s.id)))
        .get();
    final present = att.where((a) => a.arrivalTime != null).length;
    // Total = students who have any attendance in the course (member estimate).
    final sessionIds = await (_database.select(_database.sessions)
          ..where((t) => t.courseId.equals(s.courseId)))
        .get()
        .then((rows) => rows.map((r) => r.id).toList());
    final courseAtt = sessionIds.isEmpty
        ? const <db.Attendance>[]
        : await (_database.select(_database.attendances)
              ..where((t) => t.sessionId.isIn(sessionIds)))
            .get();
    final total = courseAtt.map((a) => a.studentId).toSet().length;
    return AdminSessionRow(
      id: s.id,
      index: s.orderInCourse,
      date: s.date,
      present: present,
      total: total,
      earlyPoints: s.earlyPoints,
      midPoints: s.midPoints,
      latePoints: s.latePoints,
      earlyUntil: s.earlyUntil,
      lateFrom: s.lateFrom,
    );
  }

  // ── Students ────────────────────────────────────────────────────────────

  Future<List<AdminStudentRow>> students({String? query, int? teamId}) async {
    var rowQuery = _database.select(_database.students);
    final rows = await rowQuery.get();
    final teamNames = await _teamNamesByStudent();

    var mapped = rows.map((s) {
      return AdminStudentRow(
        id: s.id,
        name: s.name,
        teamNames: (teamNames[s.id] ?? const <String>[]).join(' · '),
        barcode: s.barcode,
        yearOfBirth: s.yearOfBirth,
        active: s.active,
      );
    }).toList();

    if (query != null && query.trim().isNotEmpty) {
      mapped = mapped
          .where((r) => studentMatchesQuery(r, query))
          .toList();
    }
    if (teamId != null) {
      final ids = (await (_database.select(_database.studentTeams)
                ..where((t) => t.teamId.equals(teamId)))
              .get())
          .map((l) => l.studentId)
          .toSet();
      mapped = mapped.where((r) => ids.contains(r.id)).toList();
    }
    mapped.sort((a, b) => a.name.compareTo(b.name));
    return mapped;
  }

  Future<Map<int, List<String>>> _teamNamesByStudent() async {
    final links = await _database.select(_database.studentTeams).get();
    final teams = await _database.select(_database.teams).get();
    final nameById = {for (final t in teams) t.id: t.name};
    final result = <int, List<String>>{};
    for (final l in links) {
      final name = nameById[l.teamId];
      if (name == null) continue;
      result.putIfAbsent(l.studentId, () => []).add(name);
    }
    return result;
  }

  Future<AdminStudentProfile> studentProfile(int id) async {
    final s = await (_database.select(_database.students)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final phones = await (_database.select(_database.phones)
          ..where((t) => t.studentId.equals(id)))
        .get();
    final teamLinks = await (_database.select(_database.studentTeams)
          ..where((t) => t.studentId.equals(id)))
        .get();
    final teamIds = teamLinks.map((l) => l.teamId).toList();
    final teamRows = teamIds.isEmpty
        ? const <db.Team>[]
        : await (_database.select(_database.teams)
              ..where((t) => t.id.isIn(teamIds)))
            .get();

    final mems = await (_database.select(_database.memorizations)
          ..where((t) => t.studentId.equals(id)))
        .get();
    final pages = mems.map((m) => m.page).toSet().length;

    final certs = await (_database.select(_database.certificates)
          ..where((t) => t.studentId.equals(id)))
        .get();

    final submissions = await (_database.select(_database.examSubmissions)
          ..where((t) => t.studentId.equals(id)))
        .get();
    final examIds = submissions.map((s) => s.examId).toSet().toList();
    final exams = examIds.isEmpty
        ? const <db.Exam>[]
        : await (_database.select(_database.exams)
              ..where((t) => t.id.isIn(examIds)))
            .get();
    final examById = {for (final e in exams) e.id: e};
    final subjectBest = <String, int>{};
    for (final sub in submissions) {
      final exam = examById[sub.examId];
      if (exam == null) continue;
      if (exam.type == 'final') {
        final mark = sub.mark.round();
        final current = subjectBest[exam.subjectName];
        if (current == null || mark > current) {
          subjectBest[exam.subjectName] = mark;
        }
      }
    }

    final certificateRows = (
      [
        for (final c in certs)
          AdminCertificateRow(
            startJuz: c.startJuz,
            endJuz: c.endJuz,
            mark: c.mark,
            byHeart: c.byHeart,
            date: c.date,
          ),
      ]..sort((a, b) => b.date.compareTo(a.date))
    );
    final tested = <int>{};
    for (final c in certs) {
      for (var j = c.startJuz; j <= c.endJuz; j++) {
        tested.add(j);
      }
    }

    final matnRecs = await (_database.select(_database.matnRecitations)
          ..where((t) => t.studentId.equals(id)))
        .get();
    final matnRows = await _database.select(_database.matns).get();
    final matnById = {for (final m in matnRows) m.id: m};
    final latestByMatn = <int, db.MatnRecitation>{};
    for (final r in matnRecs) {
      final existing = latestByMatn[r.matnId];
      if (existing == null || r.id > existing.id) latestByMatn[r.matnId] = r;
    }
    final matnProgress = [
      for (final r in latestByMatn.values)
        if (matnById[r.matnId] != null)
          AdminMatnProgress(
            name: matnById[r.matnId]!.name,
            lastVerse: r.lastVerse,
            totalVerses: matnById[r.matnId]!.totalVerses,
          ),
    ];

    // Full matn recitation log (سجلات المتون) with the session date.
    final recSessionIds =
        matnRecs.map((r) => r.sessionId).toSet().toList();
    final recSessions = recSessionIds.isEmpty
        ? const <db.Session>[]
        : await (_database.select(_database.sessions)
              ..where((t) => t.id.isIn(recSessionIds)))
            .get();
    final recSessionById = {for (final s in recSessions) s.id: s};
    final matnRecitationLog = (
      [
        for (final r in matnRecs)
          if (matnById[r.matnId] != null)
            AdminMatnRecitation(
              matnName: matnById[r.matnId]!.name,
              lastVerse: r.lastVerse,
              teacherName: r.teacherName,
              date: recSessionById[r.sessionId]?.date,
            ),
      ]..sort((a, b) {
          final ad = a.date ?? DateTime(2000);
          final bd = b.date ?? DateTime(2000);
          return bd.compareTo(ad);
        })
    );

    final memorizations = (
      [
        for (final m in mems)
          Memorization(
            sessionId: m.sessionId,
            page: m.page,
            partIndex: m.partIndex,
            parts: m.parts,
            surah: m.surah,
            rating: m.rating,
            reciterName: m.reciterName,
            date: m.date,
          ),
      ]..sort((a, b) => b.date.compareTo(a.date))
    );

    final examResults = (
      [
        for (final sub in submissions)
          if (examById[sub.examId] != null)
            AdminExamResult(
              subject: examById[sub.examId]!.subjectName,
              typeLabel: _examTypeLabel(examById[sub.examId]!.type),
              mark: sub.mark,
              maxMark: examById[sub.examId]!.maxMark,
              passed:
                  sub.mark >= examById[sub.examId]!.minSuccessMark,
              date: sub.date,
            ),
      ]..sort((a, b) => b.date.compareTo(a.date))
    );

    return AdminStudentProfile(
      profile: StudentProfileModel(
        id: s.id,
        name: s.name,
        fatherName: s.fatherName,
        yearOfBirth: s.yearOfBirth,
        barcode: s.barcode,
        lastSeenAt: s.lastSeenAt,
        phones: [
          for (final p in phones)
            Phone(id: p.id, phone: p.phone, type: p.type),
        ],
      ),
      teams: [
        for (final t in teamRows)
          Team(
            id: t.id,
            name: t.name,
            typeName: t.typeName,
            teacherName: t.teacherName,
          ),
      ],
      pagesMemorized: pages,
      certificatesCount: certs.length,
      subjects: [
        for (final e in subjectBest.entries) (subject: e.key, result: e.value),
      ],
      certificates: certificateRows,
      testedJuz: tested.length,
      matnProgress: matnProgress,
      examResults: examResults,
      memorizations: memorizations,
      matnRecitationLog: matnRecitationLog,
    );
  }

  // ── Teams / teachers / content ─────────────────────────────────────────

  Future<List<AdminTeamRow>> teams() async {
    final rows = await _database.select(_database.teams).get();
    final links = await _database.select(_database.studentTeams).get();
    final counts = <int, int>{};
    for (final l in links) {
      counts[l.teamId] = (counts[l.teamId] ?? 0) + 1;
    }
    return [
      for (final t in rows)
        AdminTeamRow(
          id: t.id,
          name: t.name,
          typeName: t.typeName,
          teacherName: t.teacherName,
          studentsCount: counts[t.id] ?? 0,
        ),
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<AdminTeacherRow>> teachers() async {
    final rows = await _database.select(_database.teams).get();
    final counts = <String, int>{};
    for (final t in rows) {
      if (t.teacherName.isEmpty) continue;
      counts[t.teacherName] = (counts[t.teacherName] ?? 0) + 1;
    }
    return [
      for (final e in counts.entries)
        AdminTeacherRow(name: e.key, teamsCount: e.value),
    ]..sort((a, b) => b.teamsCount.compareTo(a.teamsCount));
  }

  Future<List<AdminContentItem>> teamTypes() async {
    final rows = await _database.select(_database.teamTypes).get();
    return [
      for (final r in rows)
        AdminContentItem(id: r.id, name: r.name, subtitle: r.note),
    ];
  }

  Future<List<AdminContentItem>> subjects() async {
    final rows = await _database.select(_database.subjects).get();
    return [
      for (final r in rows)
        AdminContentItem(id: r.id, name: r.name, subtitle: r.book),
    ];
  }

  Future<List<AdminContentItem>> distributables() async {
    final rows = await _database.select(_database.distributables).get();
    return [
      for (final r in rows) AdminContentItem(id: r.id, name: r.name, subtitle: r.note),
    ];
  }

  Future<List<AdminContentItem>> matns() async {
    final rows = await _database.select(_database.matns).get();
    return [
      for (final r in rows)
        AdminContentItem(
          id: r.id,
          name: r.name,
          subtitle: '${r.pointsPerVerse} نقطة/بيت · ${r.totalVerses} بيت',
        ),
    ];
  }

  // ── Change requests ─────────────────────────────────────────────────────

  Future<List<AdminChangeRequest>> changeRequests() async {
    final rows = await _database.select(_database.changeRequests).get();
    final students = await _database.select(_database.students).get();
    final nameById = {for (final s in students) s.id: s.name};
    final list = [
      for (final r in rows)
        AdminChangeRequest(
          id: r.id,
          studentId: r.studentId,
          studentName: nameById[r.studentId] ?? '#${r.studentId}',
          fieldLabel: _fieldLabel(r.field),
          requestedValue: r.requestedValue,
          currentValue: r.currentValue,
          status: r.status,
          createdAt: r.createdAt,
        ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Derived "audit" list of recent writes across record types (E13, trial).
  Future<List<({String model, String action, String description, DateTime when, int recordId})>>
      recentWrites({int limit = 40}) async {
    final out = <({String model, String action, String description, DateTime when, int recordId})>[];
    final students = await _database.select(_database.students).get();
    final nameById = {for (final s in students) s.id: s.name};

    for (final a in await _database.select(_database.attendances).get()) {
      if (a.arrivalTime == null) continue;
      out.add((
        model: 'Attendance',
        action: 'create',
        description: 'حضور ${nameById[a.studentId] ?? a.studentId}',
        when: a.arrivalTime!,
        recordId: a.id,
      ));
    }
    for (final m in await _database.select(_database.memorizations).get()) {
      out.add((
        model: 'Memorization',
        action: 'create',
        description: 'حفظ ${nameById[m.studentId] ?? m.studentId} — صفحة ${m.page}',
        when: m.date,
        recordId: m.id,
      ));
    }
    for (final t in await _database.select(_database.transactions).get()) {
      out.add((
        model: 'Transaction',
        action: 'create',
        description:
            'معاملة ${nameById[t.studentId] ?? t.studentId} · ${t.pointsValue}',
        when: t.date,
        recordId: t.id,
      ));
    }
    out.sort((a, b) => b.when.compareTo(a.when));
    return out.take(limit).toList();
  }

  /// Reverts a record from the admin notifications feed (E19 undo).
  Future<bool> undoRecord(String model, int recordId) async {
    switch (model) {
      case 'Attendance':
        await (_database.delete(_database.attendances)
              ..where((t) => t.id.equals(recordId)))
            .go();
      case 'Memorization':
        await (_database.delete(_database.memorizations)
              ..where((t) => t.id.equals(recordId)))
            .go();
      case 'Transaction':
        await (_database.delete(_database.transactions)
              ..where((t) => t.id.equals(recordId)))
            .go();
      default:
        return false;
    }
    return true;
  }

  /// Aggregated admin notifications: consecutive same-kind writes on the
  /// same day are collapsed into one entry (e.g. «تسجيل حضور لفلان و54 آخرين»).
  Future<List<AdminNotification>> notifications({int limit = 200}) async {
    final writes = await recentWrites(limit: limit);
    final aggregated = <AdminNotification>[];
    AdminNotification? current;
    for (final w in writes) {
      final day = _dateOnly(w.when);
      if (current == null ||
          current.kind != w.model ||
          current.day != day) {
        current = AdminNotification(
          id: '${w.model}-${day.millisecondsSinceEpoch}',
          kind: w.model,
          day: day,
          when: w.when,
          firstName: w.description,
          extraCount: 0,
          recordId: w.recordId,
        );
        aggregated.add(current);
      } else {
        current = AdminNotification(
          id: current.id,
          kind: current.kind,
          day: current.day,
          when: current.when,
          firstName: current.firstName,
          extraCount: current.extraCount + 1,
          recordId: current.recordId,
        );
        aggregated[aggregated.length - 1] = current;
      }
    }
    return aggregated;
  }

  Future<DateTime?> lastAdminNotifRead() async {
    final row = await (_database.select(_database.appMeta)
          ..where((t) => t.key.equals('notif_admin_last_read')))
        .getSingleOrNull();
    final raw = row?.value;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> markAdminNotifRead() async {
    final now = DateTime.now();
    final existing = await (_database.select(_database.appMeta)
          ..where((t) => t.key.equals('notif_admin_last_read')))
        .getSingleOrNull();
    if (existing == null) {
      await _database.into(_database.appMeta).insert(
            db.AppMetaCompanion.insert(
                key: 'notif_admin_last_read', value: now.toIso8601String()),
          );
    } else {
      await (_database.update(_database.appMeta)
            ..where((t) => t.key.equals('notif_admin_last_read')))
          .write(db.AppMetaCompanion(value: Value(now.toIso8601String())));
    }
  }

  Future<int> unreadAdminNotifications() async {
    final items = await notifications();
    final lastRead = await lastAdminNotifRead();
    if (lastRead == null) return items.length;
    return items.where((n) => n.when.isAfter(lastRead)).length;
  }

  Future<void> resolveChangeRequest(int id, {required bool approve}) async {
    await (_database.update(_database.changeRequests)
          ..where((t) => t.id.equals(id)))
        .write(db.ChangeRequestsCompanion(
      status: Value(approve ? 'approved' : 'rejected'),
      reviewedAt: Value(DateTime.now()),
    ));
  }

  // ── Session attendance + recording ──────────────────────────────────────

  Future<List<AdminAttendanceRow>> sessionAttendance(int sessionId) async {
    final students = await _database.select(_database.students).get();
    final nameById = {for (final s in students) s.id: s.name};
    final att = await (_database.select(_database.attendances)
          ..where((t) => t.sessionId.equals(sessionId)))
        .get();
    final session = await (_database.select(_database.sessions)
          ..where((t) => t.id.equals(sessionId)))
        .getSingle();
    final s = Session(
      id: session.id,
      courseId: session.courseId,
      date: session.date,
      earlyPoints: session.earlyPoints,
      midPoints: session.midPoints,
      latePoints: session.latePoints,
      earlyUntil: session.earlyUntil,
      lateFrom: session.lateFrom,
      orderInCourse: session.orderInCourse,
    );
    final rows = [
      for (final a in att)
        if (a.arrivalTime != null)
          AdminAttendanceRow(
            studentId: a.studentId,
            name: nameById[a.studentId] ?? '#${a.studentId}',
            arrivalTime: a.arrivalTime,
            category: s.categoryFor(a.arrivalTime!),
          ),
    ]..sort((a, b) => (a.arrivalTime!).compareTo(b.arrivalTime!));
    return rows;
  }

  /// Full roster of a session (all students of its course), each with their
  /// status for this session (present with arrival time / absent).
  Future<List<AdminSessionMember>> sessionMembers(int sessionId) async {
    final session = await (_database.select(_database.sessions)
          ..where((t) => t.id.equals(sessionId)))
        .getSingle();
    final courseSessions = await (_database.select(_database.sessions)
          ..where((t) => t.courseId.equals(session.courseId)))
        .get();
    final courseSessionIds = courseSessions.map((s) => s.id).toList();
    final courseAtt = courseSessionIds.isEmpty
        ? const <db.Attendance>[]
        : await (_database.select(_database.attendances)
              ..where((t) => t.sessionId.isIn(courseSessionIds)))
            .get();
    final rosterIds = courseAtt.map((a) => a.studentId).toSet().toList();
    final thisSession = await (_database.select(_database.attendances)
          ..where((t) => t.sessionId.equals(sessionId)))
        .get();
    final arrivalById = {for (final a in thisSession) a.studentId: a.arrivalTime};
    final students = rosterIds.isEmpty
        ? const <db.Student>[]
        : await (_database.select(_database.students)
              ..where((t) => t.id.isIn(rosterIds)))
            .get();
    return [
      for (final s in students)
        AdminSessionMember(
          studentId: s.id,
          name: s.name,
          arrivalTime: arrivalById[s.id],
        ),
    ]..sort((a, b) {
        if (a.present != b.present) return a.present ? -1 : 1;
        return a.name.compareTo(b.name);
      });
  }

  /// Scans a barcode into a session. Returns the student name or null.
  Future<String?> addAttendanceByBarcode(int sessionId, String barcode) async {
    final student = await (_database.select(_database.students)
          ..where((t) => t.barcode.equals(barcode.trim())))
        .getSingleOrNull();
    if (student == null) return null;
    final existing = await (_database.select(_database.attendances)
          ..where((t) =>
              t.sessionId.equals(sessionId) & t.studentId.equals(student.id)))
        .getSingleOrNull();
    if (existing != null) {
      // Replace arrival time (default behavior on re-scan).
      await (_database.update(_database.attendances)
            ..where((t) => t.id.equals(existing.id)))
          .write(db.AttendancesCompanion(arrivalTime: Value(DateTime.now())));
    } else {
      await _database.into(_database.attendances).insert(
            db.AttendancesCompanion.insert(
              id: Value(await _nextAttendanceId()),
              studentId: student.id,
              sessionId: sessionId,
              arrivalTime: Value(DateTime.now()),
            ),
          );
    }
    return student.name;
  }

  Future<void> addManualAttendance(int sessionId, int studentId) async {
    await _database.into(_database.attendances).insert(
          db.AttendancesCompanion.insert(
            id: Value(await _nextAttendanceId()),
            studentId: studentId,
            sessionId: sessionId,
            arrivalTime: Value(DateTime.now()),
          ),
    );
  }

  /// Removes a student's attendance from a session (BR-701 undo path).
  Future<void> removeAttendance(int sessionId, int studentId) async {
    await (_database.delete(_database.attendances)
          ..where((t) =>
              t.sessionId.equals(sessionId) & t.studentId.equals(studentId)))
        .go();
  }

  /// Adjusts the recorded arrival time of an existing attendance row.
  Future<void> updateAttendanceTime(
      int sessionId, int studentId, DateTime time) async {
    final existing = await (_database.select(_database.attendances)
          ..where((t) =>
              t.sessionId.equals(sessionId) & t.studentId.equals(studentId)))
        .getSingleOrNull();
    if (existing == null) return;
    await (_database.update(_database.attendances)
          ..where((t) => t.id.equals(existing.id)))
        .write(db.AttendancesCompanion(arrivalTime: Value(time)));
  }

  Future<void> addMemorization({
    required int studentId,
    required int sessionId,
    required List<QuranUnit> units,
    required int rating,
    required String reciterName,
  }) async {
    for (final unit in units) {
      await _database.into(_database.memorizations).insert(
            db.MemorizationsCompanion.insert(
              id: Value(await _nextId(await _countMems())),
              studentId: studentId,
              sessionId: sessionId,
              page: unit.page,
              partIndex: Value(unit.partIndex),
              parts: Value(quranPageParts(unit.page)),
              surah: Value(unit.surah),
              rating: rating,
              reciterName: Value(reciterName),
              date: DateTime.now(),
            ),
          );
    }
  }

  Future<void> addTransaction({
    required int studentId,
    required int sessionId,
    required String type,
    required int value,
    String? description,
  }) async {
    await _database.into(_database.transactions).insert(
          db.TransactionsCompanion.insert(
            id: Value(await _nextId(await _countTx())),
            studentId: studentId,
            sessionId: sessionId,
            type: type,
            pointsValue: value,
            date: DateTime.now(),
            description: Value(description),
          ),
        );
  }

  Future<void> addMatnRecitation({
    required int studentId,
    required int matnId,
    required int sessionId,
    required int lastVerse,
    required String teacherName,
  }) async {
    await _database.into(_database.matnRecitations).insert(
          db.MatnRecitationsCompanion.insert(
            id: Value(await _nextId(await _countMatnRecs())),
            studentId: studentId,
            matnId: matnId,
            lastVerse: lastVerse,
            teacherName: Value(teacherName),
            sessionId: sessionId,
          ),
        );
  }

  Future<int> addSession(int courseId, DateTime date) async {
    final existing = await (_database.select(_database.sessions)
          ..where((t) => t.courseId.equals(courseId)))
        .get();
    final order = existing.isEmpty
        ? 1
        : existing.map((s) => s.orderInCourse).reduce((a, b) => a > b ? a : b) + 1;
    // Id must be unique across the whole table (a new course may share the
    // same session count as another one → count-based ids would collide).
    final all = await _database.select(_database.sessions).get();
    final id = await _nextId(all.length, base: 100);
    await _database.into(_database.sessions).insert(
          db.SessionsCompanion.insert(
            id: Value(id),
            courseId: courseId,
            date: date,
            orderInCourse: Value(order),
          ),
        );
    return id;
  }

  /// Updates a session's thresholds/point values (BR-402: per session).
  Future<void> updateSession(
    int sessionId, {
    required int earlyPoints,
    required int midPoints,
    required int latePoints,
    required String earlyUntil,
    required String lateFrom,
    DateTime? date,
  }) async {
    await (_database.update(_database.sessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(db.SessionsCompanion(
      earlyPoints: Value(earlyPoints),
      midPoints: Value(midPoints),
      latePoints: Value(latePoints),
      earlyUntil: Value(earlyUntil),
      lateFrom: Value(lateFrom),
      date: date == null ? const Value.absent() : Value(date),
    ));
  }

  Future<int> addCourse(String name, DateTime start, DateTime end) async {
    final existing = await _database.select(_database.courses).get();
    final id = await _nextId(existing.length, base: 1);
    await _database.into(_database.courses).insert(
          db.CoursesCompanion.insert(
            id: Value(id),
            name: name,
            startDate: start,
            endDate: end,
          ),
        );
    return id;
  }

  Future<int> addStudent({
    required String name,
    String? fatherName,
    int? yearOfBirth,
    int? teamId,
    String? phone,
  }) async {
    final existing = await _database.select(_database.students).get();
    final id = await _nextId(existing.length, base: 1000);
    await _database.into(_database.students).insert(
          db.StudentsCompanion.insert(
            id: Value(id),
            name: name,
            fatherName: Value(fatherName),
            yearOfBirth: Value(yearOfBirth),
            // BR-625/707: barcode = mosque code + student id.
            barcode: 'frq-$id',
          ),
        );
    if (teamId != null) {
      await _linkStudentToTeam(id, teamId);
    }
    if (phone != null && phone.trim().isNotEmpty) {
      final phones = await _database.select(_database.phones).get();
      await _database.into(_database.phones).insert(
            db.PhonesCompanion.insert(
              id: Value(10000 + phones.length),
              studentId: id,
              phone: phone.trim(),
              type: 'parent',
            ),
          );
    }
    return id;
  }

  Future<void> _linkStudentToTeam(int studentId, int teamId) async {
    final existing = await (_database.select(_database.studentTeams)
          ..where((t) =>
              t.studentId.equals(studentId) & t.teamId.equals(teamId)))
        .getSingleOrNull();
    if (existing != null) return;
    final links = await _database.select(_database.studentTeams).get();
    await _database.into(_database.studentTeams).insert(
          db.StudentTeamsCompanion.insert(
            id: Value(20000 + links.length),
            studentId: studentId,
            teamId: teamId,
            date: Value(DateTime.now()),
          ),
        );
  }

  /// Direct admin edit (bypasses change requests).
  Future<void> updateStudent(
    int studentId, {
    required String name,
    String? fatherName,
    int? yearOfBirth,
  }) async {
    await (_database.update(_database.students)
          ..where((t) => t.id.equals(studentId)))
        .write(db.StudentsCompanion(
      name: Value(name),
      fatherName: Value(fatherName),
      yearOfBirth: Value(yearOfBirth),
    ));
  }

  Future<void> addPhone(int studentId, String phone, String type) async {
    final rows = await _database.select(_database.phones).get();
    await _database.into(_database.phones).insert(
          db.PhonesCompanion.insert(
            id: Value(10000 + rows.length),
            studentId: studentId,
            phone: phone,
            type: type,
          ),
        );
  }

  Future<void> removePhone(int phoneId) async {
    await (_database.delete(_database.phones)
          ..where((t) => t.id.equals(phoneId)))
        .go();
  }

  /// Members of a team (E8 preview + bulk management).
  Future<List<AdminStudentRow>> teamStudents(int teamId) async {
    final links = await (_database.select(_database.studentTeams)
          ..where((t) => t.teamId.equals(teamId)))
        .get();
    if (links.isEmpty) return const [];
    final ids = links.map((l) => l.studentId).toList();
    final rows = await (_database.select(_database.students)
          ..where((t) => t.id.isIn(ids)))
        .get();
    final teamNames = await _teamNamesByStudent();
    return [
      for (final s in rows)
        AdminStudentRow(
          id: s.id,
          name: s.name,
          teamNames: (teamNames[s.id] ?? const <String>[]).join(' · '),
          barcode: s.barcode,
          yearOfBirth: s.yearOfBirth,
          active: s.active,
        ),
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> addStudentsToTeam(int teamId, List<int> studentIds) async {
    for (final id in studentIds) {
      await _linkStudentToTeam(id, teamId);
    }
  }

  Future<void> removeStudentsFromTeam(int teamId, List<int> studentIds) async {
    await (_database.delete(_database.studentTeams)
          ..where((t) =>
              t.teamId.equals(teamId) & t.studentId.isIn(studentIds)))
        .go();
  }

  Future<void> addTeam({
    required String name,
    required String typeName,
    String teacherName = '',
  }) async {
    final existing = await _database.select(_database.teams).get();
    await _database.into(_database.teams).insert(
          db.TeamsCompanion.insert(
            id: Value(await _nextId(existing.length, base: 100)),
            name: name,
            typeName: typeName,
            teacherName: Value(teacherName),
          ),
        );
  }

  Future<void> addTeamType(String name) async {
    final existing = await _database.select(_database.teamTypes).get();
    await _database.into(_database.teamTypes).insert(
          db.TeamTypesCompanion.insert(
              id: Value(await _nextId(existing.length, base: 1)), name: name),
        );
  }

  /// Deletes a team type (BR-601: admin-managed). Fails silently when the
  /// type is still used by teams.
  Future<void> deleteTeamType(int id) async {
    await (_database.delete(_database.teamTypes)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Teams taught by a teacher (matched by teacher name on the team row).
  Future<List<AdminTeamRow>> teacherTeams(String teacherName) async {
    final rows = await (_database.select(_database.teams)
          ..where((t) => t.teacherName.equals(teacherName)))
        .get();
    final links = await _database.select(_database.studentTeams).get();
    final counts = <int, int>{};
    for (final l in links) {
      counts[l.teamId] = (counts[l.teamId] ?? 0) + 1;
    }
    return [
      for (final t in rows)
        AdminTeamRow(
          id: t.id,
          name: t.name,
          typeName: t.typeName,
          teacherName: t.teacherName,
          studentsCount: counts[t.id] ?? 0,
        ),
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Assigns (or replaces) the teacher of a team.
  Future<void> setTeamTeacher(int teamId, String teacherName) async {
    await (_database.update(_database.teams)
          ..where((t) => t.id.equals(teamId)))
        .write(db.TeamsCompanion(teacherName: Value(teacherName)));
  }

  /// Removes the teacher from a team (teacher left the team).
  Future<void> removeTeamTeacher(int teamId) async {
    await (_database.update(_database.teams)
          ..where((t) => t.id.equals(teamId)))
        .write(const db.TeamsCompanion(teacherName: Value('')));
  }

  Future<void> addSubject(String name, String? book) async {
    final existing = await _database.select(_database.subjects).get();
    await _database.into(_database.subjects).insert(
          db.SubjectsCompanion.insert(
            id: Value(await _nextId(existing.length, base: 1)),
            name: name,
            book: Value(book),
          ),
        );
  }

  Future<void> addDistributable(String name, String? note) async {
    final existing = await _database.select(_database.distributables).get();
    await _database.into(_database.distributables).insert(
          db.DistributablesCompanion.insert(
            id: Value(await _nextId(existing.length, base: 1)),
            name: name,
            note: Value(note),
          ),
        );
  }

  Future<void> updateMatn(
      int id, String name, int pointsPerVerse, int totalVerses) async {
    await (_database.update(_database.matns)
          ..where((t) => t.id.equals(id)))
        .write(db.MatnsCompanion(
      name: Value(name),
      pointsPerVerse: Value(pointsPerVerse),
      totalVerses: Value(totalVerses),
    ));
  }

  Future<void> deleteMatn(int id) async {
    await (_database.delete(_database.matns)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> updateSubject(int id, String name, String? book) async {
    await (_database.update(_database.subjects)
          ..where((t) => t.id.equals(id)))
        .write(db.SubjectsCompanion(name: Value(name), book: Value(book)));
  }

  Future<void> deleteSubject(int id) async {
    await (_database.delete(_database.subjects)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> updateDistributable(int id, String name, String? note) async {
    await (_database.update(_database.distributables)
          ..where((t) => t.id.equals(id)))
        .write(db.DistributablesCompanion(
            name: Value(name), note: Value(note)));
  }

  Future<void> deleteDistributable(int id) async {
    await (_database.delete(_database.distributables)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> addMatn(String name, int pointsPerVerse, int totalVerses) async {
    final existing = await _database.select(_database.matns).get();
    await _database.into(_database.matns).insert(
          db.MatnsCompanion.insert(
            id: Value(await _nextId(existing.length, base: 100)),
            name: name,
            pointsPerVerse: pointsPerVerse,
            totalVerses: totalVerses,
          ),
        );
  }

  /// Per-course records for a single student (E7 course switcher).
  Future<List<({int courseId, String course, int points})>>
      studentCourseRecords(int studentId) async {
    final courses = await _database.select(_database.courses).get();
    final result = <({int courseId, String course, int points})>[];
    for (final c in courses) {
      final sessions = await (_database.select(_database.sessions)
            ..where((t) => t.courseId.equals(c.id)))
          .get();
      if (sessions.isEmpty) continue;
      final sessionIds = sessions.map((s) => s.id).toList();
      final attendance = await (_database.select(_database.attendances)
            ..where((t) =>
                t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
          .get();
      final mems = await (_database.select(_database.memorizations)
            ..where((t) =>
                t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
          .get();
      final txs = await (_database.select(_database.transactions)
            ..where((t) =>
                t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
          .get();
      final hasRecords =
          attendance.isNotEmpty || mems.isNotEmpty || txs.isNotEmpty;
      if (!hasRecords) continue;
      final points = await _studentPoints(
        studentId,
        course: _mapCourse(c),
        sessionIds: sessionIds,
      );
      result.add((courseId: c.id, course: c.name, points: points));
    }
    return result;
  }

  Future<List<AdminContentItem>> courseExams(int courseId) async {
    final rows = await (_database.select(_database.exams)
          ..where((t) => t.courseId.equals(courseId)))
        .get();
    return [
      for (final e in rows)
        AdminContentItem(
          id: e.id,
          name: e.subjectName,
          subtitle:
              '${_examTypeLabel(e.type)} · ${e.maxMark} درجة · ${e.points} نقطة',
        ),
    ];
  }

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

  Future<void> addExam({
    required int courseId,
    required String subjectName,
    required String type,
    required int maxMark,
    required int minSuccessMark,
    required int points,
  }) async {
    // Count across all courses to keep ids unique between new courses.
    final all = await _database.select(_database.exams).get();
    await _database.into(_database.exams).insert(
          db.ExamsCompanion.insert(
            id: Value(await _nextId(all.length, base: 500)),
            courseId: courseId,
            subjectName: subjectName,
            date: DateTime.now(),
            type: type,
            maxMark: maxMark,
            minSuccessMark: minSuccessMark,
            points: Value(points),
          ),
        );
  }

  /// Full exam row for the detail/edit sheet (E2 exams tab).
  Future<AdminExamDetail?> examDetail(int examId) async {
    final e = await (_database.select(_database.exams)
          ..where((t) => t.id.equals(examId)))
        .getSingleOrNull();
    if (e == null) return null;
    return AdminExamDetail(
      id: e.id,
      courseId: e.courseId,
      subjectName: e.subjectName,
      type: e.type,
      maxMark: e.maxMark,
      minSuccessMark: e.minSuccessMark,
      points: e.points,
    );
  }

  Future<void> updateExam(
    int examId, {
    required String subjectName,
    required String type,
    required int maxMark,
    required int minSuccessMark,
    required int points,
  }) async {
    await (_database.update(_database.exams)
          ..where((t) => t.id.equals(examId)))
        .write(db.ExamsCompanion(
      subjectName: Value(subjectName),
      type: Value(type),
      maxMark: Value(maxMark),
      minSuccessMark: Value(minSuccessMark),
      points: Value(points),
    ));
  }

  Future<void> deleteExam(int examId) async {
    await (_database.delete(_database.exams)
          ..where((t) => t.id.equals(examId)))
        .go();
  }

  /// Marks of an exam (E2 submissions entry, BR-803/804).
  Future<List<AdminSubmissionRow>> examSubmissions(int examId) async {
    final subs = await (_database.select(_database.examSubmissions)
          ..where((t) => t.examId.equals(examId)))
        .get();
    if (subs.isEmpty) return const [];
    final ids = subs.map((s) => s.studentId).toList();
    final students = await (_database.select(_database.students)
          ..where((t) => t.id.isIn(ids)))
        .get();
    final nameById = {for (final s in students) s.id: s.name};
    return [
      for (final s in subs)
        AdminSubmissionRow(
          studentId: s.studentId,
          studentName: nameById[s.studentId] ?? '#${s.studentId}',
          mark: s.mark,
        ),
    ]..sort((a, b) => a.studentName.compareTo(b.studentName));
  }

  /// Adds or replaces a student's mark for an exam (one per student, BR-804).
  Future<void> addExamSubmission(int examId, int studentId, double mark) async {
    final existing = await (_database.select(_database.examSubmissions)
          ..where((t) =>
              t.examId.equals(examId) & t.studentId.equals(studentId)))
        .getSingleOrNull();
    if (existing != null) {
      await (_database.update(_database.examSubmissions)
            ..where((t) => t.id.equals(existing.id)))
          .write(db.ExamSubmissionsCompanion(
        mark: Value(mark),
        date: Value(DateTime.now()),
      ));
      return;
    }
    final all = await _database.select(_database.examSubmissions).get();
    await _database.into(_database.examSubmissions).insert(
          db.ExamSubmissionsCompanion.insert(
            id: Value(await _nextId(all.length, base: 60)),
            studentId: studentId,
            examId: examId,
            mark: mark,
            date: DateTime.now(),
          ),
        );
  }

  String _examTypeLabel(String type) => switch (type) {
        'oral' => 'شفهي',
        'writtenProbe' => 'سبر كتابي',
        'final' => 'اختبار نهائي',
        _ => type,
      };

  // ── helpers ─────────────────────────────────────────────────────────────

  Future<int> _countMems() async =>
      (await _database.select(_database.memorizations).get()).length;
  Future<int> _countTx() async =>
      (await _database.select(_database.transactions).get()).length;
  Future<int> _countMatnRecs() async =>
      (await _database.select(_database.matnRecitations).get()).length;

  Future<int> _nextAttendanceId() async {
    final rows = await _database.select(_database.attendances).get();
    return 100000 + rows.length;
  }

  Future<int> _nextId(int count, {int base = 1}) async {
    // Avoid clashing with seeded ids by using a high offset.
    return base * 100000 + count + 1;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Points within a course for a given student: attendance + memorization
  /// (per page units) + total-affecting transactions.
  Future<int> _studentPoints(
    int studentId, {
    required Course course,
    required List<int> sessionIds,
  }) async {
    if (sessionIds.isEmpty) return 0;
    var points = 0;
    final sessionRows = await (_database.select(_database.sessions)
          ..where((t) => t.id.isIn(sessionIds)))
        .get();
    final att = await (_database.select(_database.attendances)
          ..where((t) =>
              t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
        .get();
    final attBySession = {for (final a in att) a.sessionId: a};
    for (final row in sessionRows) {
      final s = Session(
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
      final a = attBySession[s.id];
      if (a?.arrivalTime != null) {
        points += s.pointsFor(s.categoryFor(a!.arrivalTime!));
      }
    }
    final mems = await (_database.select(_database.memorizations)
          ..where((t) =>
              t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
        .get();
    for (final m in mems) {
      final parts = m.parts <= 0 ? 1 : m.parts;
      points += (course.memorizationPointsForRating(m.rating) / parts).round();
    }
    final txs = await (_database.select(_database.transactions)
          ..where((t) =>
              t.studentId.equals(studentId) & t.sessionId.isIn(sessionIds)))
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
          break;
      }
    }
    return points;
  }

  String _fieldLabel(String field) => switch (field) {
        'name' => 'الاسم',
        'fatherName' => 'اسم الأب',
        'yearOfBirth' => 'سنة الميلاد',
        'phoneNumber' => 'رقم الهاتف',
        _ => field,
      };
}

/// Wrapper so screens can pass the leaderboard list around.
class LeaderboardResult {
  const LeaderboardResult(this.entries);
  final List<StudentLeaderboardEntry> entries;
}
