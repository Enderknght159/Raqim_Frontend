import '../../../core/utils/numeral_utils.dart';
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

/// Compact, teacher-facing summary of what a student already recorded in the
/// open session. The API returns human titles/subtitles for [AdminSessionRecord],
/// so the numbers are derived from those labels (pages, last matn, points).
class TeacherSessionSummary {
  const TeacherSessionSummary({
    required this.records,
    required this.pages,
    required this.lastMatn,
    required this.lastVerse,
    required this.points,
    required this.pointsCount,
    required this.otherCount,
  });

  factory TeacherSessionSummary.fromRecords(List<AdminSessionRecord> records) {
    final pageKeys = <String>{};
    AdminSessionRecord? newestMatn;
    var points = 0;
    var pointsCount = 0;
    var otherCount = 0;

    for (final record in records) {
      switch (record.kind) {
        case 'memorization':
          final page = RegExp(r'صفحة\s*(\d+)').firstMatch(record.title);
          pageKeys.add(page?.group(1) ?? '#${record.id}');
          break;
        case 'matn':
          newestMatn ??= record;
          break;
        case 'transaction':
          final value =
              int.tryParse(
                RegExp(r'([+-]?\d+)').firstMatch(record.title)?.group(1) ?? '',
              ) ??
              0;
          final negative =
              record.title.contains('عقوبة') || record.title.contains('خصم');
          points += negative ? -value.abs() : value.abs();
          pointsCount++;
          break;
        default:
          otherCount++;
          break;
      }
    }

    var lastMatn = '';
    var lastVerse = 0;
    if (newestMatn != null) {
      final title = newestMatn.title;
      lastMatn = title.split('—').first.trim();
      lastVerse =
          int.tryParse(
            RegExp(r'البيت الأخير\s*(\d+)').firstMatch(title)?.group(1) ?? '',
          ) ??
          0;
    }

    return TeacherSessionSummary(
      records: records,
      pages: pageKeys.length,
      lastMatn: lastMatn,
      lastVerse: lastVerse,
      points: points,
      pointsCount: pointsCount,
      otherCount: otherCount,
    );
  }

  final List<AdminSessionRecord> records;
  final int pages;
  final String lastMatn;
  final int lastVerse;
  final int points;
  final int pointsCount;
  final int otherCount;

  bool get isEmpty => records.isEmpty;

  String get pagesLabel => '$pages صفحة';

  String? get matnLabel {
    if (lastMatn.isEmpty) return null;
    return lastVerse > 0 ? '$lastMatn · $lastVerse' : lastMatn;
  }

  String? get pointsLabel {
    if (pointsCount == 0) return null;
    final formatted = formatNumber(points);
    return points > 0 ? '+$formatted نقطة' : '$formatted نقطة';
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
