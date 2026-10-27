import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_mappers.dart';
import '../../../core/network/api_repository_base.dart';
import '../../auth/domain/auth_session.dart';
import '../domain/models/student_models.dart';
import '../domain/student_stats.dart';
import 'student_repository.dart';

/// API-backed implementation of [StudentRepository].
class StudentApiRepository extends ApiRepositoryBase
    implements StudentRepository {
  StudentApiRepository(super.dio, this.session);

  final ApiSession session;

  int get _studentId {
    final id = session.studentId;
    if (id == null) {
      throw const ApiException(
        code: 'NO_STUDENT_LINK',
        messageAr: 'هذا الحساب غير مرتبط بملف طالب',
        messageEn: 'This account is not linked to a student profile',
      );
    }
    return id;
  }

  Map<String, dynamic>? _quranCache;
  List<Map<String, dynamic>>? _achievementCache;
  List<Matn>? _matnsCache;
  DateTime? _cacheAt;

  bool get _cacheFresh {
    final at = _cacheAt;
    return at != null && DateTime.now().difference(at).inSeconds < 30;
  }

  void _touchCache() => _cacheAt = DateTime.now();

  Future<Map<String, dynamic>> _quran() async {
    if (_quranCache != null && _cacheFresh) return _quranCache!;
    final json = await getMap(ApiEndpoints.meQuran);
    _quranCache = json;
    _touchCache();
    return json;
  }

  Future<List<Map<String, dynamic>>> _achievement() async {
    if (_achievementCache != null && _cacheFresh) return _achievementCache!;
    final json = await getMap(ApiEndpoints.meAchievement);
    _achievementCache = [json];
    _touchCache();
    return _achievementCache!;
  }

  @override
  Future<StudentProfileModel> profile() async {
    final json = await getMap(ApiEndpoints.meProfile);
    return mapStudentProfile(json);
  }

  @override
  Future<String> mosqueName() async {
    final name = session.mosqueName.trim();
    return name.isEmpty ? 'المسجد' : name;
  }

  @override
  Future<List<Course>> courses() async {
    final items = await getList(ApiEndpoints.meCourses);
    return items
        .whereType<Map>()
        .map((e) => mapCourse(asMap(e['course'] ?? e)))
        .toList();
  }

  @override
  Future<List<Team>> teams() async {
    final items = await getList(ApiEndpoints.meTeams);
    return items
        .whereType<Map>()
        .map((e) => mapTeam(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<List<StudentBrief>> peersOfTeam(int teamId) async {
    final items = await getList(ApiEndpoints.meTeams);
    for (final item in items.whereType<Map>()) {
      if (asInt(item['id']) != teamId) continue;
      return [
        for (final peer in asMapList(item['peers']))
          StudentBrief(
            id: asInt(peer['id']),
            name: asString(peer['name']),
            yearOfBirth: peer['yearOfBirth'] == null
                ? null
                : asInt(peer['yearOfBirth']),
          ),
      ];
    }
    return const [];
  }

  @override
  Future<List<StudentLeaderboardEntry>> leaderboard(int courseId) async {
    final items = await getList(ApiEndpoints.meCourseLeaderboard(courseId));
    return [
      for (final item in items.whereType<Map>())
        StudentLeaderboardEntry(
          rank: asInt(item['rank']),
          student: StudentBrief(
            id: asInt(asMap(item['student'])['id']),
            name: asString(asMap(item['student'])['name']),
            yearOfBirth: asMap(item['student'])['yearOfBirth'] == null
                ? null
                : asInt(asMap(item['student'])['yearOfBirth']),
          ),
          points: asInt(item['points']),
        ),
    ];
  }

  @override
  Future<List<CourseOverview>> courseOverviews() async {
    final items = await getList(ApiEndpoints.meCourses);
    final overviews = <CourseOverview>[];
    for (final item in items.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      overviews.add(
        CourseOverview(
          course: mapCourse(asMap(map['course'])),
          points: mapPoints(asMap(map['points'])),
          attendance: mapAttendanceSummary(asMap(map['attendance'])),
          rank: map['rank'] == null ? null : asInt(map['rank']),
          lastUpdated: asDateOrNull(map['lastUpdated']),
        ),
      );
    }
    return overviews;
  }

  @override
  Future<StudentCourseBundle> courseBundle(
    int courseId, {
    int? studentId,
  }) async {
    final id = studentId ?? _studentId;
    final path = id == _studentId
        ? ApiEndpoints.meCourse(courseId)
        : ApiEndpoints.studentCourseBundle(id, courseId);
    final json = await getMap(path);
    final allMatns = await matns();
    return mapBundle(json, matns: allMatns);
  }

  @override
  Future<List<Memorization>> allMemorizations() async {
    final json = await _quran();
    return [
      for (final item in asMapList(json['memorizations']))
        mapMemorization(item),
    ];
  }

  @override
  Future<List<Certificate>> certificates() async {
    final items = await getList(ApiEndpoints.meQuranCertificates);
    return [
      for (final item in items.whereType<Map>())
        mapCertificate(Map<String, dynamic>.from(item)),
    ];
  }

  @override
  Future<List<Matn>> matns() async {
    if (_matnsCache != null && _cacheFresh) return _matnsCache!;
    // Students cannot read the admin `/matns` reference endpoint; the
    // achievement payload already carries every matn with its verse data.
    final achievement = (await _achievement()).first;
    final result = [
      for (final item in asMapList(achievement['matns']))
        Matn(
          id: asInt(item['matnId']),
          name: asString(item['name']),
          pointsPerVerse: asInt(item['pointsPerVerse']),
          totalVerses: asInt(item['totalVerses']),
        ),
    ];
    _matnsCache = result;
    _touchCache();
    return result;
  }

  @override
  Future<List<MatnRecitation>> matnRecitations({int? studentId}) async {
    final id = studentId ?? _studentId;
    if (id == _studentId) {
      final achievement = (await _achievement()).first;
      return [
        for (final item in asMapList(achievement['matns']))
          MatnRecitation(
            matnId: asInt(item['matnId']),
            lastVerse: asInt(item['lastVerse']),
            teacherName: '',
          ),
      ];
    }
    final overview = await getMap(ApiEndpoints.studentOverview(id));
    return [
      for (final item in asMapList(overview['matnProgress']))
        MatnRecitation(
          matnId: asInt(item['matnId']),
          lastVerse: asInt(item['lastVerse']),
          teacherName: '',
        ),
    ];
  }

  @override
  Future<Map<int, MatnRecitation>> latestMatnRecitations() async {
    final all = await matnRecitations();
    final result = <int, MatnRecitation>{};
    for (final record in all) {
      result[record.matnId] = record;
    }
    return result;
  }

  @override
  Future<List<({Exam exam, ExamSubmission? submission})>>
  examsWithSubmissions() async {
    final items = await getList(ApiEndpoints.meExams);
    return [
      for (final item in items.whereType<Map>())
        _examWithSubmission(Map<String, dynamic>.from(item)),
    ];
  }

  ({Exam exam, ExamSubmission? submission}) _examWithSubmission(
    Map<String, dynamic> item,
  ) {
    final exam = mapExam(item);
    final mark = item['mark'];
    final submission = mark == null
        ? null
        : ExamSubmission(
            examId: exam.id,
            mark: asDouble(mark),
            date: asDate(item['date']),
          );
    return (exam: exam, submission: submission);
  }

  @override
  Future<QuranStats> quranStats() async {
    final json = await _quran();
    final stats = asMap(json['stats']);
    return QuranStats(
      pagesMemorized: asInt(stats['pagesMemorized']),
      monthlyRate: asDouble(stats['monthlyRate']),
      expectedCompletion: asDateOrNull(stats['expectedCompletion']),
    );
  }

  @override
  Future<List<StudentNotification>> notifications() async {
    final out = <StudentNotification>[];
    var page = 1;
    while (page <= 50) {
      final json = await getMap(
        ApiEndpoints.meNotifications,
        query: {'page': page, 'page_size': 100},
      );
      out.addAll(asMapList(json['results']).map(mapNotification));
      final next = json['next'];
      if (next == null || next == '' || next == 0) break;
      final nextPage = asInt(next);
      if (nextPage <= page) break;
      page = nextPage;
    }
    return out;
  }

  @override
  Future<void> markNotifRead() async {
    await postMap(ApiEndpoints.meNotificationsRead, data: const <dynamic>[]);
  }

  @override
  Future<int> unreadNotifications() async {
    final json = await getMap(ApiEndpoints.meNotificationsUnread);
    return asInt(json['count']);
  }

  @override
  Future<void> requestChange({
    required String field,
    required String requestedValue,
  }) async {
    await postMap(
      ApiEndpoints.meChangeRequests,
      data: {'field': field, 'requestedValue': requestedValue},
    );
  }
}
