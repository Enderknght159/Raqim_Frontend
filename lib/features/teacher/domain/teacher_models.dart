import '../../admin/domain/admin_models.dart';

/// The four record types a team type can grant (BR-607 v0.2).
enum TeacherRecordKind { attendance, quranTasmi, matn, points }

extension TeacherRecordKindX on TeacherRecordKind {
  String get label => switch (this) {
    TeacherRecordKind.attendance => 'حضور',
    TeacherRecordKind.quranTasmi => 'تسميع',
    TeacherRecordKind.matn => 'متون',
    TeacherRecordKind.points => 'نقاط',
  };

  String get longLabel => switch (this) {
    TeacherRecordKind.attendance => 'تسجيل الحضور',
    TeacherRecordKind.quranTasmi => 'تسميع القرآن',
    TeacherRecordKind.matn => 'تسميع المتون',
    TeacherRecordKind.points => 'تسجيل النقاط',
  };
}

/// A teacher-scoped student with the teams (and type switches) that grant
/// record writes. A student may appear in more than one of the teacher's teams.
class TeacherRosterEntry {
  TeacherRosterEntry({required this.student, List<AdminTeamRow>? teams})
    : teams = teams ?? <AdminTeamRow>[];

  final AdminStudentRow student;
  final List<AdminTeamRow> teams;

  Iterable<TeamTypePermissions> get _permissions =>
      teams.map((team) => team.typePermissions);

  bool get attendanceAllowed =>
      _permissions.any((permission) => permission.attendance);

  bool get quranTasmiAllowed =>
      _permissions.any((permission) => permission.quranTasmi);

  bool get matnAllowed => _permissions.any((permission) => permission.matn);

  bool get pointsAllowed => _permissions.any((permission) => permission.points);

  /// Writable record types (attendance is handled by the student sheet).
  List<TeacherRecordKind> get recordKinds => [
    if (quranTasmiAllowed) TeacherRecordKind.quranTasmi,
    if (matnAllowed) TeacherRecordKind.matn,
    if (pointsAllowed) TeacherRecordKind.points,
  ];

  bool get canWriteAnything => attendanceAllowed || recordKinds.isNotEmpty;

  String get teamNames {
    final names = teams
        .map((team) => team.name)
        .where((name) => name.isNotEmpty);
    return names.isEmpty ? student.teamNames : names.join(' · ');
  }

  String get typeNames {
    final names = teams
        .map((team) => team.typeName)
        .where((name) => name.isNotEmpty)
        .toSet();
    return names.join(' · ');
  }

  Set<int> get teamIds => teams.map((team) => team.id).toSet();

  bool matchesTeam(int? teamId) =>
      teamId == null || teams.any((team) => team.id == teamId);

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return student.name.toLowerCase().contains(q) ||
        student.barcode.toLowerCase().contains(q) ||
        student.id.toString() == q ||
        teamNames.toLowerCase().contains(q);
  }
}

/// Course → session pair chosen by the teacher.
class TeacherSessionSelection {
  const TeacherSessionSelection({required this.course, required this.session});

  final AdminCourseSummary course;
  final AdminSessionRow session;

  String get courseName => course.name;

  String get dateLabel {
    final date = session.date;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
