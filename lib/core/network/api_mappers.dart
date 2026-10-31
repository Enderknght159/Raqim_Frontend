import '../../features/student/domain/models/student_models.dart';
import '../../features/student/domain/student_stats.dart';
import '../logging/app_logger.dart';

// ── Primitive helpers ─────────────────────────────────────────────────────

int asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double asDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

DateTime asDate(dynamic value, [DateTime? fallback]) {
  if (value is DateTime) return value;
  final text = asString(value);
  return DateTime.tryParse(text) ?? fallback ?? DateTime(2000);
}

DateTime? asDateOrNull(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final text = asString(value);
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (value is Map && value['results'] is List) {
    return asMapList(value['results']);
  }
  return const <Map<String, dynamic>>[];
}

/// API times arrive as `HH:mm:ss`; the domain models use `HH:mm`.
String hhmm(dynamic value) {
  final text = asString(value);
  if (text.isEmpty) return '00:00';
  final parts = text.split(':');
  if (parts.length >= 2) return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  return text;
}

String optionalName(dynamic value) {
  if (value == null) return '';
  if (value is Map) return asString(value['name']);
  return asString(value);
}

AttendanceCategory parseCategory(dynamic value) => switch (asString(value)) {
  'early' => AttendanceCategory.early,
  'late' => AttendanceCategory.late,
  'absent' => AttendanceCategory.absent,
  _ => AttendanceCategory.onTime,
};

NotificationKind parseNotificationKind(dynamic value) =>
    switch (asString(value)) {
      'attendance' => NotificationKind.attendance,
      'memorization' => NotificationKind.memorization,
      'transaction' => NotificationKind.transaction,
      'exam' => NotificationKind.exam,
      'certificate' => NotificationKind.certificate,
      'matn' => NotificationKind.matn,
      'team' => NotificationKind.team,
      'notice' => NotificationKind.notice,
      _ => NotificationKind.notice,
    };

// ── Domain mappers ────────────────────────────────────────────────────────

Course mapCourse(Map<String, dynamic> json) {
  final criteria = json['criteria'] is Map
      ? asMap(json['criteria'])
      : const <String, dynamic>{};
  return Course(
    id: asInt(json['id'] ?? json['courseId']),
    name: asString(json['name'] ?? json['courseName']),
    startDate: asDate(json['startDate']),
    endDate: asDate(json['endDate']),
    goodPoints: asInt(criteria['goodPoints'] ?? json['goodMemorizationPoints']),
    veryGoodPoints: asInt(
      criteria['veryGoodPoints'] ?? json['veryGoodMemorizationPoints'],
    ),
    excellentPoints: asInt(
      criteria['excellentPoints'] ?? json['excellentMemorizationPoints'],
    ),
    certificatePoints: asInt(
      criteria['certificatePoints'] ?? json['quranCertificatePoints'],
    ),
  );
}

Session mapSession(Map<String, dynamic> json) => Session(
  id: asInt(json['id']),
  courseId: asInt(json['courseId']),
  date: asDate(json['date']),
  earlyPoints: asInt(json['earlyPoints']),
  midPoints: asInt(json['midPoints']),
  latePoints: asInt(json['latePoints']),
  earlyUntil: hhmm(json['earlyUntil']),
  lateFrom: hhmm(json['lateFrom']),
  orderInCourse: asInt(json['orderInCourse'] ?? json['index']),
);

PointsBreakdown mapPoints(Map<String, dynamic> json) => PointsBreakdown(
  memorization: asInt(json['memorization']),
  attendance: asInt(json['attendance']),
  exams: asInt(json['exams']),
  certificates: asInt(json['certificates']),
  matn: asInt(json['matn']),
  reward: asInt(json['reward']),
  penalty: asInt(json['penalty']),
  purchase: asInt(json['purchase']),
  collection: asInt(json['collection']),
  incomeExpense: asInt(json['incomeExpense']),
);

AttendanceSummary mapAttendanceSummary(Map<String, dynamic> json) {
  final early = asInt(json['early']);
  final onTime = asInt(json['onTime']);
  final late = asInt(json['late']);
  final absent = asInt(json['absent']);
  return AttendanceSummary(
    early: early,
    onTime: onTime,
    late: late,
    absent: absent,
    totalSessions: asInt(json['totalSessions'], early + onTime + late + absent),
  );
}

StudentProfileModel mapStudentProfile(Map<String, dynamic> json) {
  final raw = json['profile'] is Map ? asMap(json['profile']) : json;
  return StudentProfileModel(
    id: asInt(raw['id']),
    name: asString(raw['name']),
    fatherName: raw['fatherName'] == null ? null : asString(raw['fatherName']),
    yearOfBirth: raw['yearOfBirth'] == null ? null : asInt(raw['yearOfBirth']),
    barcode: asString(raw['barcode']),
    lastSeenAt: asDateOrNull(raw['lastSeenAt']),
    phones: [
      for (final phone in asMapList(raw['phones']))
        Phone(
          id: asInt(phone['id']),
          phone: asString(phone['phone']),
          type: asString(phone['type'], 'parent'),
        ),
    ],
  );
}

final _teamLog = AppLogger.forTag('Teams');

Team mapTeam(Map<String, dynamic> json) {
  final rawTeacher = json['teacher'];
  final rawTeacherName = json['teacherName'];
  var teacherName = '';
  int? teacherId = json['teacherId'] == null ? null : asInt(json['teacherId']);

  if (rawTeacher is Map) {
    final teacher = asMap(rawTeacher);
    teacherName = asString(teacher['name']).trim();
    if (teacher['id'] != null) teacherId = asInt(teacher['id']);
  } else if (rawTeacher is num) {
    // Backend sent only an id; keep it for reference but never display it.
    teacherId = rawTeacher.toInt();
  } else if (rawTeacher is String && rawTeacher.trim().isNotEmpty) {
    final text = rawTeacher.trim();
    final parsedId = int.tryParse(text);
    if (parsedId == null) {
      teacherName = text;
    } else {
      teacherId = parsedId;
    }
  }

  if (teacherName.isEmpty && rawTeacherName != null) {
    final text = asString(rawTeacherName).trim();
    if (Team.isDisplayableTeacherName(text)) teacherName = text;
  }

  if (teacherName.isEmpty && teacherId != null) {
    _teamLog.warning(
      'Team #${asInt(json['id'])}: teacher has no name (id: $teacherId). '
      'Backend should include teacher.name in /me/teams.',
    );
  }

  return Team(
    id: asInt(json['id']),
    name: asString(json['name']),
    typeName: optionalName(json['type']) == ''
        ? 'حلقة'
        : optionalName(json['type']),
    teacherName: teacherName,
    teacherId: teacherId,
  );
}

Memorization mapMemorization(Map<String, dynamic> json) => Memorization(
  sessionId: asInt(json['sessionId']),
  page: asInt(json['page']),
  partIndex: asInt(json['partIndex'], 1),
  parts: asInt(json['parts'], 1),
  surah: asString(json['surah']),
  rating: asInt(json['rating']),
  reciterName: optionalName(json['reciter']),
  date: asDate(json['date']),
);

StudentTransaction mapTransaction(Map<String, dynamic> json) =>
    StudentTransaction(
      sessionId: asInt(json['sessionId']),
      type: TransactionType.fromValue(asString(json['type'])),
      pointsValue: asInt(json['pointsValue']),
      date: asDate(json['date']),
      description: json['description'] == null
          ? null
          : asString(json['description']),
    );

Certificate mapCertificate(
  Map<String, dynamic> json, {
  int? fallbackCourseId,
}) => Certificate(
  courseId: asInt(json['courseId'], fallbackCourseId ?? 0),
  startJuz: asInt(json['startJuz']),
  endJuz: asInt(json['endJuz']),
  mark: asInt(json['mark']),
  byHeart: json['byHeart'] == true,
  date: asDate(json['date']),
);

Exam mapExam(Map<String, dynamic> json) => Exam(
  id: asInt(json['id'] ?? json['examId']),
  courseId: asInt(json['courseId']),
  subjectName: asString(json['subject'] ?? json['subjectName']),
  date: asDate(json['date']),
  type: ExamType.fromValue(asString(json['type'])),
  maxMark: asInt(json['maxMark']),
  minSuccessMark: asInt(json['minSuccessMark']),
  points: asInt(json['points']),
);

Matn mapMatn(Map<String, dynamic> json) => Matn(
  id: asInt(json['id']),
  name: asString(json['name']),
  pointsPerVerse: asInt(json['pointsPerVerse']),
  totalVerses: asInt(json['totalVerses']),
);

MatnRecitation mapMatnRecitation(Map<String, dynamic> json) => MatnRecitation(
  matnId: asInt(json['matnId']),
  lastVerse: asInt(json['lastVerse']),
  teacherName: optionalName(json['teacher'] ?? json['teacherName']),
  sessionId: json['sessionId'] == null ? null : asInt(json['sessionId']),
);

StudentNotification mapNotification(Map<String, dynamic> json) =>
    StudentNotification(
      id: asString(json['id']),
      when: asDate(json['when']),
      kind: parseNotificationKind(json['kind']),
      title: asString(json['title']),
      body: asString(json['body']),
    );

StudentCourseBundle mapBundle(
  Map<String, dynamic> json, {
  List<Matn> matns = const [],
}) {
  final course = mapCourse(asMap(json['course']));
  final sessions = [
    for (final item in asMapList(json['sessions'])) mapSession(item),
  ];
  final attendance = [
    for (final item in asMapList(json['attendance']))
      AttendanceRecord(
        sessionId: asInt(item['sessionId']),
        arrivalTime: asDateOrNull(item['arrivalTime']),
      ),
  ];
  final memorizations = [
    for (final item in asMapList(json['memorizations'])) mapMemorization(item),
  ];
  final exams = <Exam>[];
  final submissions = <ExamSubmission>[];
  for (final item in asMapList(json['exams'])) {
    final exam = mapExam(item);
    exams.add(exam);
    final submission = item['submission'];
    if (submission is Map) {
      final map = asMap(submission);
      submissions.add(
        ExamSubmission(
          examId: exam.id,
          mark: asDouble(map['mark']),
          date: asDate(map['date']),
        ),
      );
    }
  }
  final certificates = [
    for (final item in asMapList(json['certificates']))
      mapCertificate(item, fallbackCourseId: course.id),
  ];
  final matnRecitations = [
    for (final item in asMapList(json['matnRecitations']))
      mapMatnRecitation(item),
  ];
  final transactions = [
    for (final item in asMapList(json['transactions'])) mapTransaction(item),
  ];

  return StudentCourseBundle(
    course: course,
    sessions: sessions,
    attendance: attendance,
    memorizations: memorizations,
    exams: exams,
    examSubmissions: submissions,
    certificates: certificates,
    matns: matns,
    matnRecitations: matnRecitations,
    transactions: transactions,
  );
}
