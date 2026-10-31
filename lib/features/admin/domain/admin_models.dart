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

/// Admin landing data (stats + courses + last session).
class AdminHomeData {
  const AdminHomeData({required this.stats, required this.courses, this.last});

  final GeneralStats stats;
  final List<AdminCourseSummary> courses;
  final AdminSessionRow? last;
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
    required this.lastSessionPresent,
    required this.lastSessionTotal,
    required this.attendancePercent,
    required this.series,
    this.goodPoints = 1,
    this.veryGoodPoints = 2,
    this.excellentPoints = 3,
    this.certificatePoints = 10,
  });

  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int sessionsCount;
  final int studentsCount;

  /// Attendance of the **last** session (not today's).
  final int lastSessionPresent;
  final int lastSessionTotal;
  final int attendancePercent;
  final List<double> series;

  /// Course criteria (BR-304): memorization rating points + certificate points.
  final int goodPoints;
  final int veryGoodPoints;
  final int excellentPoints;
  final int certificatePoints;
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
    required this.date,
  });

  final int id;
  final int courseId;
  final String subjectName;
  final String type;
  final int maxMark;
  final int minSuccessMark;
  final int points;
  final DateTime date;
}

/// One student's mark on an exam (E2 submissions entry).
class AdminSubmissionRow {
  const AdminSubmissionRow({
    required this.studentId,
    required this.studentName,
    required this.mark,
    this.id = 0,
    this.date,
  });

  final int id;
  final int studentId;
  final String studentName;
  final double mark;
  final DateTime? date;
}

/// A record attached to one session, grouped by kind (E3 «سجلات الجلسة»).
class AdminSessionRecord {
  const AdminSessionRecord({
    required this.id,
    required this.kind,
    required this.studentName,
    required this.title,
    required this.subtitle,
    required this.when,
  });

  /// memorization | matn | transaction
  final String kind;
  final int id;
  final String studentName;
  final String title;
  final String subtitle;
  final DateTime when;
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

/// Result of scanning a barcode into a session.
class AttendanceScanResult {
  const AttendanceScanResult({
    required this.studentId,
    required this.name,
    required this.created,
  });

  final int studentId;
  final String name;

  /// False when the server ignored the scan because the student was already
  /// present (BR-102), true when a new attendance row was created.
  final bool created;
}

/// A roster entry of a session: every student of the session's course with
/// their attendance status for that session (absent → arrivalTime null).
class AdminSessionMember {
  const AdminSessionMember({
    required this.studentId,
    required this.name,
    this.barcode = '',
    this.arrivalTime,
  });

  final int studentId;
  final String name;
  final String barcode;
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

  AdminNotification copyWith({String? firstName, int? extraCount}) =>
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

/// One Quran certificate row (admin lists + student profile).
class AdminCertificateRow {
  const AdminCertificateRow({
    required this.startJuz,
    required this.endJuz,
    required this.mark,
    required this.byHeart,
    required this.date,
    this.id = 0,
    this.studentId = 0,
    this.studentName = '',
    this.courseId = 0,
  });

  final int id;
  final int studentId;
  final String studentName;
  final int courseId;
  final int startJuz;
  final int endJuz;
  final int mark;
  final bool byHeart;
  final DateTime date;

  int get juzCount => endJuz - startJuz + 1;
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

/// Mosque identity returned by `GET /mosque` (E17).
class MosqueInfo {
  const MosqueInfo({
    required this.id,
    required this.name,
    required this.code,
    this.logoUrl,
    this.primaryColor,
    this.status,
    this.deletionMessage,
    this.contactEmail,
    this.contactPhone,
    this.city,
  });

  final int id;
  final String name;
  final String code;
  final String? logoUrl;
  final String? primaryColor;
  final String? status;
  final String? deletionMessage;
  final String? contactEmail;
  final String? contactPhone;
  final String? city;
}

/// `GET /mosque/deletion-state` (E17).
class MosqueDeletionState {
  const MosqueDeletionState({
    required this.status,
    this.deletionScheduledAt,
    this.deletionMessage,
    this.exportDownloadToken,
  });

  final String status;
  final DateTime? deletionScheduledAt;
  final String? deletionMessage;
  final String? exportDownloadToken;

  bool get isDeleting => status == 'pendingDeletion' || status == 'pending';
}

/// One account row from `GET /admin/users` (E11).
class AdminUserRow {
  const AdminUserRow({
    required this.id,
    required this.name,
    required this.username,
    required this.active,
    required this.isAdmin,
    required this.isSupervisor,
    required this.isTeacher,
    required this.isStudent,
    this.studentId,
    this.teacherId,
    this.teamNames = const [],
  });

  /// Account id (used by the permissions endpoints), not the student id.
  final int id;
  final String name;
  final String username;
  final bool active;
  final bool isAdmin;
  final bool isSupervisor;
  final bool isTeacher;
  final bool isStudent;
  final int? studentId;
  final int? teacherId;
  final List<String> teamNames;

  String get displayName {
    final n = name.trim();
    if (n.isNotEmpty && n != username.trim()) return n;
    final u = username.trim();
    if (u.isNotEmpty) return u;
    return 'حساب بدون اسم';
  }

  String get usernameLabel {
    final u = username.trim();
    if (u.isEmpty) return '';
    return '@$u';
  }

  String get roleLabel {
    if (isAdmin) return 'مدير';
    if (isSupervisor) return 'مشرف';
    if (isTeacher) return 'معلم';
    if (isStudent) return 'طالب';
    return 'حساب';
  }
}

/// One module entry of `GET /admin/users/{id}/permissions`.
///
/// The server stores five independent action flags plus a scope (courses and
/// teams). A module is only effective when at least one action is granted.
class AdminModuleGrant {
  const AdminModuleGrant({
    this.view = false,
    this.create = false,
    this.update = false,
    this.delete = false,
    this.export = false,
    this.courseIds = const [],
    this.teamIds = const [],
  });

  factory AdminModuleGrant.fromJson(Map<String, dynamic> json) {
    final scope = _adminStringMap(json['scope']);
    return AdminModuleGrant(
      view: json['view'] == true,
      create: json['create'] == true,
      update: json['update'] == true,
      delete: json['delete'] == true,
      export: json['export'] == true,
      courseIds: _adminIntList(scope['courseIds']),
      teamIds: _adminIntList(scope['teamIds']),
    );
  }

  static const none = AdminModuleGrant();

  final bool view;
  final bool create;
  final bool update;
  final bool delete;
  final bool export;
  final List<int> courseIds;
  final List<int> teamIds;

  bool get hasAnyAction => view || create || update || delete || export;
  bool get hasAnyScope => courseIds.isNotEmpty || teamIds.isNotEmpty;

  /// All actions granted on every scope.
  bool get isFull => view && create && update && delete && export;

  AdminModuleGrant copyWith({
    bool? view,
    bool? create,
    bool? update,
    bool? delete,
    bool? export,
    List<int>? courseIds,
    List<int>? teamIds,
  }) {
    return AdminModuleGrant(
      view: view ?? this.view,
      create: create ?? this.create,
      update: update ?? this.update,
      delete: delete ?? this.delete,
      export: export ?? this.export,
      courseIds: courseIds ?? this.courseIds,
      teamIds: teamIds ?? this.teamIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'view': view,
    'create': create,
    'update': update,
    'delete': delete,
    'export': export,
    'scope': {'courseIds': courseIds, 'teamIds': teamIds},
  };
}

/// Supervisor grants loaded from `GET /admin/users/{id}/permissions`.
///
/// Keeps the full module × action × scope payload so the editor can round-trip
/// permissions without losing actions or scopes.
class AdminUserPermissions {
  const AdminUserPermissions({
    required this.isAdmin,
    this.modules = const {},
    this.abilities = const {},
  });

  factory AdminUserPermissions.fromJson(Map<String, dynamic> json) {
    final modulesJson = _adminStringMap(json['modules']);
    final rawAbilities = json['specialAbilities'] ?? json['abilities'];
    return AdminUserPermissions(
      isAdmin: json['isAdmin'] == true,
      modules: {
        for (final entry in modulesJson.entries)
          if (entry.value is Map)
            entry.key: AdminModuleGrant.fromJson(_adminStringMap(entry.value)),
      },
      abilities: {
        for (final item in (rawAbilities is List ? rawAbilities : const []))
          '$item',
      },
    );
  }

  /// The twelve permission-matrix modules (plus Quran certificates).
  static const moduleKeys = [
    'students',
    'attendance',
    'memorization',
    'recitation',
    'matn',
    'points',
    'exams',
    'distributions',
    'teams',
    'courses',
    'reports',
    'imports',
    'quranCertificates',
  ];

  final bool isAdmin;
  final Map<String, AdminModuleGrant> modules;
  final Set<String> abilities;

  bool get isSupervisor =>
      isAdmin ||
      modules.values.any((grant) => grant.hasAnyAction) ||
      abilities.isNotEmpty;

  bool viewEnabled(String module) =>
      isAdmin || (modules[module]?.view ?? false);

  AdminModuleGrant actionsFor(String module) =>
      modules[module] ?? AdminModuleGrant.none;

  AdminUserPermissions copyWith({
    bool? isAdmin,
    Map<String, AdminModuleGrant>? modules,
    Set<String>? abilities,
  }) {
    return AdminUserPermissions(
      isAdmin: isAdmin ?? this.isAdmin,
      modules: modules ?? this.modules,
      abilities: abilities ?? this.abilities,
    );
  }
}

Map<String, dynamic> _adminStringMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<int> _adminIntList(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is num) item.toInt(),
  ];
}

/// A team link of a teacher (`GET /teachers/{id}`).
class AdminTeamRef {
  const AdminTeamRef({required this.id, required this.name});

  final int id;
  final String name;
}

/// Teacher identity + linked teams (`GET /teachers/{id}`).
class AdminTeacherDetail {
  const AdminTeacherDetail({
    required this.id,
    required this.name,
    this.userId,
    this.teams = const [],
  });

  final int id;
  final String name;
  final int? userId;
  final List<AdminTeamRef> teams;
}

/// One page of a server-paginated list.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.total,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final int total;
}

/// An active account that can be assigned as a team teacher.
class TeacherCandidate {
  const TeacherCandidate({
    required this.userId,
    required this.name,
    required this.username,
    required this.role,
    this.teacherId,
  });

  final int userId;
  final String name;
  final String username;
  final String role;
  final int? teacherId;

  String get displayName {
    final n = name.trim();
    final u = username.trim();
    if (n.isNotEmpty && n != u) return n;
    if (u.isNotEmpty) return '@$u';
    if (n.isNotEmpty) return n;
    return 'حساب بدون اسم';
  }

  String get usernameLabel {
    final value = username.trim();
    if (value.isEmpty || value == name.trim()) return '';
    return '@$value';
  }
}
