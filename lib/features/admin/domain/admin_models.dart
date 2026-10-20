import '../../student/domain/models/student_models.dart';

/// Aggregate stats across the mosque (E1 home).
class GeneralStats {
  const GeneralStats({
    required this.students,
    required this.teams,
    required this.teachers,
    required this.courses,
    required this.pendingRequests,
    required this.memorizedPages,
  });

  final int students;
  final int teams;
  final int teachers;
  final int courses;
  final int pendingRequests;
  final int memorizedPages;
}

/// A course summary for the admin home (E1) and list.
class AdminCourseSummary {
  const AdminCourseSummary({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.sessionsCount,
    required this.studentsCount,
    required this.todayPresent,
    required this.todayTotal,
    required this.attendancePercent,
    required this.series,
  });

  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int sessionsCount;
  final int studentsCount;
  final int todayPresent;
  final int todayTotal;
  final int attendancePercent;
  final List<double> series;
}

class AdminStudentRow {
  const AdminStudentRow({
    required this.id,
    required this.name,
    required this.teamNames,
    this.barcode = '',
    this.yearOfBirth,
    this.active = true,
  });

  final int id;
  final String name;
  final String teamNames;
  final String barcode;
  final int? yearOfBirth;
  final bool active;
}

/// Tolerant (BR-627) match for the global student search: name, id, barcode
/// or team — normalized, trimmed and case-insensitive.
bool studentMatchesQuery(AdminStudentRow row, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return row.name.toLowerCase().contains(q) ||
      row.teamNames.toLowerCase().contains(q) ||
      row.barcode.toLowerCase().contains(q) ||
      row.id.toString() == q;
}

class AdminTeamRow {
  const AdminTeamRow({
    required this.id,
    required this.name,
    required this.typeName,
    required this.teacherName,
    required this.studentsCount,
  });

  final int id;
  final String name;
  final String typeName;
  final String teacherName;
  final int studentsCount;
}

class AdminTeacherRow {
  const AdminTeacherRow({required this.name, required this.teamsCount});

  final String name;
  final int teamsCount;
}

class AdminContentItem {
  const AdminContentItem({required this.id, required this.name, this.subtitle});

  final int id;
  final String name;
  final String? subtitle;
}

/// Full exam row for the detail/edit sheet (E2 exams tab, BR-802).
class AdminExamDetail {
  const AdminExamDetail({
    required this.id,
    required this.courseId,
    required this.subjectName,
    required this.type,
    required this.maxMark,
    required this.minSuccessMark,
    required this.points,
  });

  final int id;
  final int courseId;
  final String subjectName;
  final String type;
  final int maxMark;
  final int minSuccessMark;
  final int points;
}

/// One student's mark on an exam (E2 submissions entry).
class AdminSubmissionRow {
  const AdminSubmissionRow({
    required this.studentId,
    required this.studentName,
    required this.mark,
  });

  final int studentId;
  final String studentName;
  final double mark;
}

class AdminChangeRequest {
  const AdminChangeRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.fieldLabel,
    required this.requestedValue,
    required this.status,
    required this.createdAt,
    this.currentValue,
  });

  final int id;
  final int studentId;
  final String studentName;
  final String fieldLabel;
  final String requestedValue;
  final String status;
  final DateTime createdAt;
  final String? currentValue;
}

class AdminSessionRow {
  const AdminSessionRow({
    required this.id,
    required this.index,
    required this.date,
    required this.present,
    required this.total,
    this.earlyPoints = 3,
    this.midPoints = 2,
    this.latePoints = 1,
    this.earlyUntil = '16:00',
    this.lateFrom = '16:30',
  });

  final int id;
  final int index;
  final DateTime date;
  final int present;
  final int total;
  final int earlyPoints;
  final int midPoints;
  final int latePoints;
  final String earlyUntil;
  final String lateFrom;
}

class AdminAttendanceRow {
  const AdminAttendanceRow({
    required this.studentId,
    required this.name,
    this.arrivalTime,
    required this.category,
  });

  final int studentId;
  final String name;
  final DateTime? arrivalTime;
  final AttendanceCategory category;
}

/// A roster entry of a session: every student of the session's course with
/// their attendance status for that session (absent → arrivalTime null).
class AdminSessionMember {
  const AdminSessionMember({
    required this.studentId,
    required this.name,
    this.arrivalTime,
  });

  final int studentId;
  final String name;
  final DateTime? arrivalTime;

  bool get present => arrivalTime != null;
}

/// Aggregated admin notification: same-kind writes on one day collapsed
/// into «أول وصف + N آخرين» (E-notifications).
class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.kind,
    required this.day,
    required this.when,
    required this.firstName,
    required this.extraCount,
    this.recordId,
  });

  final String id;
  final String kind;
  final DateTime day;
  final DateTime when;
  final String firstName;
  final int extraCount;

  /// Id of the first (most recent) underlying record — used to revert it.
  final int? recordId;

  AdminNotification copyWith({
    String? firstName,
    int? extraCount,
  }) =>
      AdminNotification(
        id: id,
        kind: kind,
        day: day,
        when: when,
        firstName: firstName ?? this.firstName,
        extraCount: extraCount ?? this.extraCount,
        recordId: recordId,
      );
}

/// Kind label + icon for an aggregated admin notification.
String adminNotificationKindLabel(String model) => switch (model) {
      'Attendance' => 'تسجيل حضور',
      'Memorization' => 'تسجيل حفظ',
      'Transaction' => 'معاملة نقاط',
      _ => model,
    };

/// One Quran certificate row in the admin student profile (E7).
class AdminCertificateRow {
  const AdminCertificateRow({
    required this.startJuz,
    required this.endJuz,
    required this.mark,
    required this.byHeart,
    required this.date,
  });

  final int startJuz;
  final int endJuz;
  final int mark;
  final bool byHeart;
  final DateTime date;
}

/// Matn progress row in the admin student profile (E7).
class AdminMatnProgress {
  const AdminMatnProgress({
    required this.name,
    required this.lastVerse,
    required this.totalVerses,
  });

  final String name;
  final int lastVerse;
  final int totalVerses;

  double get percent =>
      totalVerses == 0 ? 0 : (lastVerse / totalVerses).clamp(0.0, 1.0);
}

/// One matn recitation (تسميع متن) record in the admin student profile (E7).
class AdminMatnRecitation {
  const AdminMatnRecitation({
    required this.matnName,
    required this.lastVerse,
    required this.teacherName,
    this.date,
  });

  final String matnName;
  final int lastVerse;
  final String teacherName;
  final DateTime? date;
}

/// Exam result row in the admin student profile (E7).
class AdminExamResult {
  const AdminExamResult({
    required this.subject,
    required this.typeLabel,
    required this.mark,
    required this.maxMark,
    required this.passed,
    required this.date,
  });

  final String subject;
  final String typeLabel;
  final double mark;
  final int maxMark;
  final bool passed;
  final DateTime date;
}

/// Aggregated admin view of a student profile (E7).
class AdminStudentProfile {
  const AdminStudentProfile({
    required this.profile,
    required this.teams,
    required this.pagesMemorized,
    required this.certificatesCount,
    required this.subjects,
    this.certificates = const [],
    this.testedJuz = 0,
    this.matnProgress = const [],
    this.examResults = const [],
    this.memorizations = const [],
    this.matnRecitationLog = const [],
  });

  final StudentProfileModel profile;
  final List<Team> teams;
  final int pagesMemorized;
  final int certificatesCount;
  final List<({String subject, int? result})> subjects;

  /// Quran card data (reuses the student profile data).
  final List<AdminCertificateRow> certificates;
  final int testedJuz;

  /// Academic output: matn progress + exam results.
  final List<AdminMatnProgress> matnProgress;
  final List<AdminExamResult> examResults;

  /// Full Quran memorization records (طسميعات) — newest first.
  final List<Memorization> memorizations;

  /// Full matn recitation records — newest first.
  final List<AdminMatnRecitation> matnRecitationLog;
}
