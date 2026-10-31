// Student-domain models (read/display side). Mapped from the local drift
// tables now; later from the API resources.

enum AttendanceCategory { early, onTime, late, absent }

enum TransactionType {
  reward('reward', 'مكافأة'),
  penalty('penalty', 'عقوبة'),
  purchase('purchase', 'شراء'),
  collection('collection', 'تحصيل'),
  incomeExpense('incomeExpense', 'دخل صرف');

  const TransactionType(this.value, this.arabic);

  final String value;
  final String arabic;

  static TransactionType fromValue(String? value) =>
      TransactionType.values.firstWhere(
        (t) => t.value == value,
        orElse: () => TransactionType.reward,
      );
}

enum ExamType {
  oral('oral', 'شفهي'),
  writtenProbe('writtenProbe', 'سبر كتابي'),
  finalExam('final', 'اختبار نهائي');

  const ExamType(this.value, this.arabic);

  final String value;
  final String arabic;

  static ExamType fromValue(String? value) => ExamType.values.firstWhere(
    (e) => e.value == value,
    orElse: () => ExamType.oral,
  );
}

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.goodPoints,
    required this.veryGoodPoints,
    required this.excellentPoints,
    required this.certificatePoints,
  });

  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int goodPoints;
  final int veryGoodPoints;
  final int excellentPoints;
  final int certificatePoints;

  bool get isActive => !DateTime.now().isAfter(endDate);

  int memorizationPointsForRating(int rating) => switch (rating) {
    3 => excellentPoints,
    2 => veryGoodPoints,
    _ => goodPoints,
  };
}

class Session {
  const Session({
    required this.id,
    required this.courseId,
    required this.date,
    required this.earlyPoints,
    required this.midPoints,
    required this.latePoints,
    required this.earlyUntil,
    required this.lateFrom,
    required this.orderInCourse,
  });

  final int id;
  final int courseId;
  final DateTime date;
  final int earlyPoints;
  final int midPoints;
  final int latePoints;
  final String earlyUntil;
  final String lateFrom;
  final int orderInCourse;

  /// Derives the arrival category from a recorded arrival time vs thresholds.
  AttendanceCategory categoryFor(DateTime arrival) {
    final e = _parse(earlyUntil);
    final l = _parse(lateFrom);
    final t = _minutes(arrival);
    if (e != null && t <= e) return AttendanceCategory.early;
    if (l != null && t >= l) return AttendanceCategory.late;
    return AttendanceCategory.onTime;
  }

  int pointsFor(AttendanceCategory category) => switch (category) {
    AttendanceCategory.early => earlyPoints,
    AttendanceCategory.onTime => midPoints,
    AttendanceCategory.late => latePoints,
    AttendanceCategory.absent => 0,
  };

  static int _minutes(DateTime d) => d.hour * 60 + d.minute;

  static int? _parse(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }
}

class AttendanceRecord {
  const AttendanceRecord({required this.sessionId, required this.arrivalTime});

  final int sessionId;
  final DateTime? arrivalTime;
}

class Phone {
  const Phone({required this.id, required this.phone, required this.type});

  final int id;
  final String phone;
  final String type; // parent | student | landline

  String get typeLabel => switch (type) {
    'parent' => 'ولي الأمر',
    'student' => 'الطالب',
    'landline' => 'هاتف أرضي',
    _ => type,
  };
}

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.typeName,
    required this.teacherName,
    this.teacherId,
  });

  /// Fallback label used when the API only sends a teacher id.
  static const fallbackTeacherName = 'معلم الحلقة';

  final int id;
  final String name;
  final String typeName;
  final String teacherName;
  final int? teacherId;

  /// A raw id/number is never a displayable teacher name.
  static bool isDisplayableTeacherName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return int.tryParse(trimmed) == null;
  }

  /// Never leaks a bare teacher id to the UI.
  String get teacherDisplayName {
    if (isDisplayableTeacherName(teacherName)) return teacherName.trim();
    if (teacherId != null || teacherName.trim().isNotEmpty) {
      return fallbackTeacherName;
    }
    return '';
  }
}

class StudentBrief {
  const StudentBrief({required this.id, required this.name, this.yearOfBirth});

  final int id;
  final String name;
  final int? yearOfBirth;
}

/// One row in the course leaderboard ("الطلاب الأوائل").
class StudentLeaderboardEntry {
  const StudentLeaderboardEntry({
    required this.rank,
    required this.student,
    required this.points,
  });

  final int rank;
  final StudentBrief student;
  final int points;
}

/// A derived activity notification covering any record added for the student.
enum NotificationKind {
  attendance,
  memorization,
  transaction,
  exam,
  certificate,
  matn,
  team,
  notice,
}

class StudentNotification {
  const StudentNotification({
    required this.id,
    required this.when,
    required this.kind,
    required this.title,
    required this.body,
  });

  final String id;
  final DateTime when;
  final NotificationKind kind;
  final String title;
  final String body;
}

class StudentProfileModel {
  const StudentProfileModel({
    required this.id,
    required this.name,
    this.fatherName,
    this.yearOfBirth,
    required this.barcode,
    this.lastSeenAt,
    this.phones = const [],
  });

  final int id;
  final String name;
  final String? fatherName;
  final int? yearOfBirth;
  final String barcode;
  final DateTime? lastSeenAt;
  final List<Phone> phones;
}

class Memorization {
  const Memorization({
    required this.sessionId,
    required this.page,
    required this.partIndex,
    required this.parts,
    required this.surah,
    required this.rating,
    required this.reciterName,
    required this.date,
  });

  final int sessionId;
  final int page;
  final int partIndex;
  final int parts;
  final String surah;
  final int rating;
  final String reciterName;
  final DateTime date;
}

class StudentTransaction {
  const StudentTransaction({
    required this.sessionId,
    required this.type,
    required this.pointsValue,
    required this.date,
    this.description,
  });

  final int sessionId;
  final TransactionType type;
  final int pointsValue;
  final DateTime date;
  final String? description;
}

class Certificate {
  const Certificate({
    required this.courseId,
    required this.startJuz,
    required this.endJuz,
    required this.mark,
    required this.byHeart,
    required this.date,
  });

  final int courseId;
  final int startJuz;
  final int endJuz;
  final int mark;
  final bool byHeart;
  final DateTime date;

  int get juzCount => endJuz - startJuz + 1;
}

class Exam {
  const Exam({
    required this.id,
    required this.courseId,
    required this.subjectName,
    required this.date,
    required this.type,
    required this.maxMark,
    required this.minSuccessMark,
    required this.points,
  });

  final int id;
  final int courseId;
  final String subjectName;
  final DateTime date;
  final ExamType type;
  final int maxMark;
  final int minSuccessMark;
  final int points;
}

class ExamSubmission {
  const ExamSubmission({
    required this.examId,
    required this.mark,
    required this.date,
  });

  final int examId;
  final double mark;
  final DateTime date;
}

class Matn {
  const Matn({
    required this.id,
    required this.name,
    required this.pointsPerVerse,
    required this.totalVerses,
  });

  final int id;
  final String name;
  final int pointsPerVerse;
  final int totalVerses;
}

class MatnRecitation {
  const MatnRecitation({
    required this.matnId,
    required this.lastVerse,
    required this.teacherName,
    this.sessionId,
  });

  final int matnId;
  final int lastVerse;
  final String teacherName;
  final int? sessionId;
}
