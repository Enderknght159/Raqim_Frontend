import 'models/student_models.dart';

/// Automatic points breakdown per `business-rules-and-glossary.md` §4.
class PointsBreakdown {
  const PointsBreakdown({
    this.memorization = 0,
    this.attendance = 0,
    this.exams = 0,
    this.certificates = 0,
    this.matn = 0,
    this.reward = 0,
    this.penalty = 0,
    this.purchase = 0,
    this.collection = 0,
    this.incomeExpense = 0,
  });

  final int memorization;
  final int attendance;
  final int exams;
  final int certificates;
  final int matn;

  final int reward;
  final int penalty;
  final int purchase;
  final int collection;
  final int incomeExpense;

  /// Calculated (non-transaction) points.
  int get calculated =>
      memorization + attendance + exams + certificates + matn;

  /// محصلة — ranking/evaluation balance (BR-304).
  int get total => calculated + reward - penalty + incomeExpense;

  /// محصلة متاح للشراء — spendable balance (BR-305).
  int get purchaseBalance =>
      calculated + reward - penalty - purchase + collection;

  /// True when points came only from transactions (no calc source yet).
  bool get isEmpty => total == 0 && purchaseBalance == 0;
}

/// Result of attendance over a course.
class AttendanceSummary {
  const AttendanceSummary({
    required this.early,
    required this.onTime,
    required this.late,
    required this.absent,
    required this.totalSessions,
  });

  final int early;
  final int onTime;
  final int late;
  final int absent;
  final int totalSessions;

  int get attended => early + onTime + late;

  /// Percentage of attended sessions (0–100).
  int get percentage =>
      totalSessions == 0 ? 0 : ((attended / totalSessions) * 100).round();
}

/// Quran tab stats (B2).
class QuranStats {
  const QuranStats({
    required this.pagesMemorized,
    required this.monthlyRate,
    required this.expectedCompletion,
  });

  final int pagesMemorized;

  /// Pages heard/recited in the last 30 days (BR: معدل الحفظ).
  final double monthlyRate;

  /// Projected completion date = now + remaining/rate months (null if rate 0).
  final DateTime? expectedCompletion;

  static const int totalPages = 604;

  int get percent => ((pagesMemorized / totalPages) * 100).round();
}

/// Computes the full points breakdown for a student within a course.
PointsBreakdown computePoints({
  required Course course,
  required List<Session> sessions,
  required List<AttendanceRecord> attendance,
  required List<Memorization> memorizations,
  required List<Exam> exams,
  required List<ExamSubmission> examSubmissions,
  required List<Certificate> certificates,
  required List<Matn> matns,
  required List<MatnRecitation> matnRecitations,
  required List<StudentTransaction> transactions,
}) {
  final sessionById = {for (final s in sessions) s.id: s};

  // ── Memorization: latest record per (page, partIndex); additive per unit ──
  final latestUnit = <String, Memorization>{};
  for (final m in memorizations) {
    if (!sessionById.containsKey(m.sessionId)) continue;
    final key = '${m.page}:${m.partIndex}';
    final existing = latestUnit[key];
    if (existing == null || m.date.isAfter(existing.date)) {
      latestUnit[key] = m;
    }
  }
  var memorizationPoints = 0.0;
  for (final m in latestUnit.values) {
    final parts = m.parts <= 0 ? 1 : m.parts;
    memorizationPoints += course.memorizationPointsForRating(m.rating) / parts;
  }

  // ── Attendance ──
  final attendanceBySession = {
    for (final a in attendance) a.sessionId: a,
  };
  var attendancePoints = 0;
  for (final s in sessions) {
    final a = attendanceBySession[s.id];
    if (a?.arrivalTime == null) continue;
    attendancePoints += s.pointsFor(s.categoryFor(a!.arrivalTime!));
  }

  // ── Exams (BR-806) ──
  final examById = {for (final e in exams) e.id: e};
  var examPoints = 0;
  for (final sub in examSubmissions) {
    final exam = examById[sub.examId];
    if (exam == null) continue;
    if (sub.mark >= exam.minSuccessMark && exam.maxMark > 0) {
      examPoints += (exam.points * (sub.mark / exam.maxMark)).round();
    }
  }

  // ── Certificates (BR-813) ──
  var certificatePoints = 0;
  for (final c in certificates) {
    if (!c.byHeart) continue;
    certificatePoints +=
        ((c.mark / 100) * course.certificatePoints * c.juzCount).round();
  }

  // ── Matn: latest recitation per matn (BR-553/555) ──
  final matnById = {for (final m in matns) m.id: m};
  final latestMatn = <int, MatnRecitation>{};
  for (final r in matnRecitations) {
    final existing = latestMatn[r.matnId];
    if (existing == null || r.lastVerse != existing.lastVerse) {
      latestMatn[r.matnId] = r;
    }
  }
  var matnPoints = 0;
  latestMatn.forEach((matnId, r) {
    final matn = matnById[matnId];
    if (matn != null) matnPoints += r.lastVerse * matn.pointsPerVerse;
  });

  // ── Transactions (BR-304/305) ──
  var reward = 0, penalty = 0, purchase = 0, collection = 0, incomeExpense = 0;
  for (final t in transactions) {
    final v = t.pointsValue.abs();
    switch (t.type) {
      case TransactionType.reward:
        reward += v;
      case TransactionType.penalty:
        penalty += v;
      case TransactionType.purchase:
        purchase += v;
      case TransactionType.collection:
        collection += v;
      case TransactionType.incomeExpense:
        incomeExpense += v;
    }
  }

  return PointsBreakdown(
    memorization: memorizationPoints.round(),
    attendance: attendancePoints,
    exams: examPoints,
    certificates: certificatePoints,
    matn: matnPoints,
    reward: reward,
    penalty: penalty,
    purchase: purchase,
    collection: collection,
    incomeExpense: incomeExpense,
  );
}

AttendanceSummary computeAttendanceSummary({
  required List<Session> sessions,
  required List<AttendanceRecord> attendance,
}) {
  final bySession = {for (final a in attendance) a.sessionId: a};
  var early = 0, onTime = 0, late = 0, absent = 0;
  for (final s in sessions) {
    final a = bySession[s.id];
    if (a?.arrivalTime == null) {
      absent++;
      continue;
    }
    switch (s.categoryFor(a!.arrivalTime!)) {
      case AttendanceCategory.early:
        early++;
      case AttendanceCategory.onTime:
        onTime++;
      case AttendanceCategory.late:
        late++;
      case AttendanceCategory.absent:
        absent++;
    }
  }
  return AttendanceSummary(
    early: early,
    onTime: onTime,
    late: late,
    absent: absent,
    totalSessions: sessions.length,
  );
}

QuranStats computeQuranStats(List<Memorization> memorizations) {
  // Latest rating per unit; count distinct memorized pages.
  final latestUnit = <String, Memorization>{};
  for (final m in memorizations) {
    final key = '${m.page}:${m.partIndex}';
    final existing = latestUnit[key];
    if (existing == null || m.date.isAfter(existing.date)) latestUnit[key] = m;
  }
  final pages = <int>{};
  var fullPages = 0.0;
  final byPage = <int, List<Memorization>>{};
  for (final m in latestUnit.values) {
    byPage.putIfAbsent(m.page, () => []).add(m);
  }
  byPage.forEach((page, units) {
    pages.add(page);
    final totalParts = units.first.parts <= 0 ? 1 : units.first.parts;
    if (units.length >= totalParts) fullPages += 1;
  });

  final now = DateTime.now();
  final rate = memorizations
      .where((m) => now.difference(m.date).inDays <= 30)
      .map((m) => 1 / (m.parts <= 0 ? 1 : m.parts))
      .fold<double>(0, (a, b) => a + b);

  DateTime? expected;
  if (rate > 0) {
    final remaining = QuranStats.totalPages - fullPages;
    final months = remaining / rate;
    expected = now.add(Duration(days: (months * 30).round()));
  }

  return QuranStats(
    pagesMemorized: pages.length,
    monthlyRate: double.parse(rate.toStringAsFixed(1)),
    expectedCompletion: expected,
  );
}

/// Summary used by the "دوراتي" (B1) smart-watch cards.
class CourseOverview {
  const CourseOverview({
    required this.course,
    required this.points,
    required this.attendance,
    this.rank,
    this.lastUpdated,
  });

  final Course course;
  final PointsBreakdown points;
  final AttendanceSummary attendance;
  final int? rank;
  final DateTime? lastUpdated;

  int get totalPoints => points.total;
  int get attendancePercentage => attendance.percentage;
}

/// Bundles everything a course-detail view needs and exposes the derived
/// points + a cumulative sparkline series.
class StudentCourseBundle {
  const StudentCourseBundle({
    required this.course,
    required this.sessions,
    required this.attendance,
    required this.memorizations,
    required this.exams,
    required this.examSubmissions,
    required this.certificates,
    required this.matns,
    required this.matnRecitations,
    required this.transactions,
  });

  final Course course;
  final List<Session> sessions;
  final List<AttendanceRecord> attendance;
  final List<Memorization> memorizations;
  final List<Exam> exams;
  final List<ExamSubmission> examSubmissions;
  final List<Certificate> certificates;
  final List<Matn> matns;
  final List<MatnRecitation> matnRecitations;
  final List<StudentTransaction> transactions;

  PointsBreakdown get breakdown => computePoints(
        course: course,
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

  AttendanceSummary get attendanceSummary =>
      computeAttendanceSummary(sessions: sessions, attendance: attendance);

  /// Cumulative "محصلة" points after each session (attendance + memorization +
  /// transactions), for the sparkline. Course-level items (exams/certs/matn)
  /// are added to the final point.
  List<double> cumulativeSeries() {
    final ordered = [...sessions]
      ..sort((a, b) => a.orderInCourse.compareTo(b.orderInCourse));
    if (ordered.isEmpty) return const [];

    final attBySession = {for (final a in attendance) a.sessionId: a};
    final courseLevel = breakdown.certificates +
        breakdown.exams +
        breakdown.matn;

    final perSessionPoints = <int, int>{};
    for (final s in ordered) {
      var pts = 0;
      // Attendance.
      final a = attBySession[s.id];
      if (a?.arrivalTime != null) {
        pts += s.pointsFor(s.categoryFor(a!.arrivalTime!));
      }
      // Memorization recorded in this session (rating points / parts).
      for (final m in memorizations.where((m) => m.sessionId == s.id)) {
        final parts = m.parts <= 0 ? 1 : m.parts;
        pts += (course.memorizationPointsForRating(m.rating) / parts).round();
      }
      // Transactions (total-affecting).
      for (final t in transactions.where((t) => t.sessionId == s.id)) {
        final v = t.pointsValue.abs();
        switch (t.type) {
          case TransactionType.reward:
            pts += v;
          case TransactionType.penalty:
          case TransactionType.purchase:
          case TransactionType.collection:
            break; // purchase/collection don't affect total; penalty handled below
          case TransactionType.incomeExpense:
            pts += v;
        }
        if (t.type == TransactionType.penalty) pts -= v;
      }
      perSessionPoints[s.id] = pts;
    }

    final series = <double>[];
    var running = 0;
    for (var i = 0; i < ordered.length; i++) {
      running += perSessionPoints[ordered[i].id] ?? 0;
      series.add((running + (i == ordered.length - 1 ? courseLevel : 0))
          .toDouble());
    }
    return series;
  }
}

