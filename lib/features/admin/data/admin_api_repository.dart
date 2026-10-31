import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_mappers.dart';
import '../../../core/network/api_repository_base.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../auth/domain/auth_session.dart';
import '../../student/domain/models/student_models.dart';
import '../../student/domain/quran_units.dart';
import '../../student/domain/student_stats.dart';
import '../domain/admin_models.dart';
import 'admin_repository.dart';

/// API-backed implementation of [AdminRepository].
class AdminApiRepository extends ApiRepositoryBase implements AdminRepository {
  AdminApiRepository(super.dio, this.session, {super.cache});

  final ApiSession session;

  List<Map<String, dynamic>>? _studentsRaw;
  List<Map<String, dynamic>>? _teamsRaw;
  List<Map<String, dynamic>>? _teachersRaw;
  List<Map<String, dynamic>>? _teamTypesRaw;
  List<Map<String, dynamic>>? _subjectsRaw;
  List<Map<String, dynamic>>? _matnsRaw;
  List<Map<String, dynamic>>? _candidatesRaw;
  final Map<int, String> _studentNames = {};
  final Map<int, String> _teacherNames = {};
  Future<List<Map<String, dynamic>>>? _studentsInFlight;
  Future<List<Map<String, dynamic>>>? _teachersInFlight;
  final Map<String, PagedResult<AdminStudentRow>> _studentPages = {};
  final Map<String, PagedResult<AdminUserRow>> _userPages = {};
  List<AdminCourseSummary>? _coursesCache;
  DateTime? _coursesAt;
  DateTime? _cacheAt;

  bool get _cacheFresh {
    final at = _cacheAt;
    return at != null && DateTime.now().difference(at).inSeconds < 30;
  }

  void _touchCache() => _cacheAt = DateTime.now();

  Future<Map<String, dynamic>> _safeGetMap(String path) async {
    try {
      return await getMap(path);
    } catch (_) {
      return const {};
    }
  }

  Future<List<Map<String, dynamic>>> _allStudents() async {
    if (_studentsRaw != null && _cacheFresh) return _studentsRaw!;
    final inFlight = _studentsInFlight;
    if (inFlight != null) return inFlight;
    final future = getAllPages(ApiEndpoints.students, pageSize: 500);
    _studentsInFlight = future;
    try {
      final items = await future;
      _studentsRaw = items;
      for (final item in items) {
        _studentNames[asInt(item['id'])] = asString(item['name']);
      }
      _touchCache();
      return items;
    } finally {
      _studentsInFlight = null;
    }
  }

  Future<List<Map<String, dynamic>>> _allTeams() async {
    if (_teamsRaw != null && _cacheFresh) return _teamsRaw!;
    final items = await getAllPages(ApiEndpoints.teams);
    _teamsRaw = items;
    _touchCache();
    return items;
  }

  Future<List<Map<String, dynamic>>> _allTeachers() async {
    if (_teachersRaw != null && _cacheFresh) return _teachersRaw!;
    final inFlight = _teachersInFlight;
    if (inFlight != null) return inFlight;
    final future = getAllPages(ApiEndpoints.teachers);
    _teachersInFlight = future;
    try {
      final items = await future;
      _teachersRaw = items;
      for (final item in items) {
        _teacherNames[asInt(item['id'])] = asString(item['name']);
      }
      _touchCache();
      return items;
    } finally {
      _teachersInFlight = null;
    }
  }

  Future<String?> _studentNameOrNull(int id) async {
    try {
      await _allStudents();
      final name = _studentNames[id];
      return name == null || name.isEmpty ? null : name;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _teacherNameOrNull(int id) async {
    try {
      await _allTeachers();
      final name = _teacherNames[id];
      return name == null || name.isEmpty ? null : name;
    } catch (_) {
      return null;
    }
  }

  String _pageKey(String kind, Map<String, dynamic> query) =>
      '$kind:${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';

  Future<List<Map<String, dynamic>>> _allTeamTypes() async {
    if (_teamTypesRaw != null && _cacheFresh) return _teamTypesRaw!;
    final items = await getAllPages(ApiEndpoints.teamTypes);
    _teamTypesRaw = items;
    _touchCache();
    return items;
  }

  Future<List<Map<String, dynamic>>> _allSubjects() async {
    if (_subjectsRaw != null && _cacheFresh) return _subjectsRaw!;
    final items = await getAllPages(ApiEndpoints.subjects);
    _subjectsRaw = items;
    _touchCache();
    return items;
  }

  Future<List<Map<String, dynamic>>> _allMatns() async {
    if (_matnsRaw != null && _cacheFresh) return _matnsRaw!;
    final items = await getAllPages(ApiEndpoints.matns);
    _matnsRaw = items;
    _touchCache();
    return items;
  }

  Future<List<Map<String, dynamic>>> _allCandidates() async {
    if (_candidatesRaw != null && _cacheFresh) return _candidatesRaw!;
    final items = await getAllPages(ApiEndpoints.teacherCandidates);
    _candidatesRaw = items;
    _touchCache();
    return items;
  }

  Future<String> _studentName(int id) async {
    final cached = _studentNames[id];
    if (cached != null && cached.isNotEmpty) return cached;
    try {
      // One bulk read beats one request per certificate/submission row.
      await _allStudents();
      final known = _studentNames[id];
      if (known != null && known.isNotEmpty) return known;
      final json = await getMap(ApiEndpoints.studentDetail(id));
      final name = asString(json['name'], '#$id');
      _studentNames[id] = name;
      return name;
    } catch (_) {
      return '#$id';
    }
  }

  Future<int?> _teacherIdByName(String name) async {
    final items = await _allTeachers();
    for (final item in items) {
      if (asString(item['name']) == name) return asInt(item['id']);
    }
    return null;
  }

  Future<int?> _teacherUserIdByName(String name) async {
    final items = await _allCandidates();
    for (final item in items) {
      if (asString(item['name']) == name) return asInt(item['userId']);
    }
    return null;
  }

  Future<int?> _teamTypeIdByName(String name) async {
    final items = await _allTeamTypes();
    for (final item in items) {
      if (asString(item['name']) == name) return asInt(item['id']);
    }
    return null;
  }

  Future<int?> _subjectIdByName(String name) async {
    final items = await _allSubjects();
    for (final item in items) {
      if (asString(item['name']) == name) return asInt(item['id']);
    }
    return null;
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _examTypeLabel(String type) => switch (type) {
    'oral' => 'شفهي',
    'writtenProbe' => 'سبر كتابي',
    'final' => 'اختبار نهائي',
    _ => type,
  };

  String _fieldLabel(String field) => switch (field) {
    'name' => 'الاسم',
    'fatherName' => 'اسم الأب',
    'yearOfBirth' => 'سنة الميلاد',
    'phoneNumber' => 'رقم الهاتف',
    _ => field,
  };

  // ── Dashboard / courses ─────────────────────────────────────────────────

  @override
  Future<GeneralStats> generalStats() async {
    final json = await getMap(ApiEndpoints.adminOverview);
    return _statsFrom(json);
  }

  GeneralStats _statsFrom(Map<String, dynamic> json) {
    return GeneralStats(
      students: asInt(json['students']),
      teams: asInt(json['teams']),
      teachers: asInt(json['teachers']),
      courses: asInt(json['courses']),
      pendingRequests: asInt(json['pendingChangeRequests']),
      memorizedPages: asInt(json['memorizedPages']),
    );
  }

  @override
  Future<AdminHomeData?> homeCached() async {
    final courses = _coursesCache;
    if (courses == null || courses.isEmpty) return null;
    final statsJson =
        await cachedMap(ApiEndpoints.adminOverview) ??
        const <String, dynamic>{};
    final lastJson = await cachedMap(ApiEndpoints.sessionsLast);
    return AdminHomeData(
      stats: _statsFrom(statsJson),
      courses: courses,
      last: lastJson == null ? null : _sessionRowFrom(lastJson),
    );
  }

  @override
  Future<List<AdminCourseSummary>> courses() async {
    final cached = _coursesCache;
    if (cached != null &&
        _coursesAt != null &&
        DateTime.now().difference(_coursesAt!).inSeconds < 30) {
      return cached;
    }
    final items = await getAllPages(ApiEndpoints.courses);
    final result = await Future.wait(items.map(_courseSummary));
    result.sort(_sortCourses);
    _coursesCache = result;
    _coursesAt = DateTime.now();
    return result;
  }

  @override
  Future<List<AdminCourseSummary>?> coursesCached() async {
    final memory = _coursesCache;
    if (memory != null && memory.isNotEmpty) return memory;
    return null;
  }

  int _sortCourses(AdminCourseSummary a, AdminCourseSummary b) {
    if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
    return b.startDate.compareTo(a.startDate);
  }

  void _replaceCourseSummary(AdminCourseSummary summary) {
    final list = _coursesCache;
    if (list == null) return;
    _coursesCache = [
      for (final item in list)
        if (item.id != summary.id) item,
      summary,
    ]..sort(_sortCourses);
    _coursesAt = DateTime.now();
  }

  @override
  Future<AdminCourseSummary?> courseSummary(int courseId) async {
    try {
      final item = await getMap(ApiEndpoints.courseDetail(courseId));
      final summary = await _courseSummary(item);
      _replaceCourseSummary(summary);
      return summary;
    } catch (_) {
      return null;
    }
  }

  Future<AdminCourseSummary> _courseSummary(Map<String, dynamic> item) async {
    final id = asInt(item['id']);
    final parallel = await Future.wait([
      _safeGetList(ApiEndpoints.courseSessions(id)),
      _safeGetMap(ApiEndpoints.reportCourseTotal(id)),
    ]);
    final sessions = parallel[0] as List<Map<String, dynamic>>;
    final total = parallel[1] as Map<String, dynamic>;
    final last = sessions.isEmpty ? null : sessions.last;
    final summary = last == null
        ? const <String, dynamic>{}
        : await _safeGetMap(ApiEndpoints.sessionSummary(asInt(last['id'])));
    final lastPresent = asInt(summary['present']);
    return AdminCourseSummary(
      id: id,
      name: asString(item['name']),
      startDate: asDate(item['startDate']),
      endDate: asDate(item['endDate']),
      isActive:
          item['active'] == true ||
          !DateTime.now().isAfter(asDate(item['endDate'])),
      sessionsCount: sessions.length,
      studentsCount: asInt(total['students']),
      lastSessionPresent: lastPresent,
      lastSessionTotal: asInt(summary['total']),
      attendancePercent: asDouble(total['attendanceRate']).round(),
      series: lastPresent > 0 ? [lastPresent.toDouble()] : const [],
      goodPoints: asInt(item['goodMemorizationPoints']),
      veryGoodPoints: asInt(item['veryGoodMemorizationPoints']),
      excellentPoints: asInt(item['excellentMemorizationPoints']),
      certificatePoints: asInt(item['quranCertificatePoints']),
    );
  }

  Future<List<Map<String, dynamic>>> _safeGetList(String path) async {
    try {
      final items = await getList(path);
      return items
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<LeaderboardResult> leaderboard(int courseId) async {
    final items = await getList(ApiEndpoints.courseLeaderboard(courseId));
    return LeaderboardResult([
      for (final item in items.whereType<Map>())
        _leaderboardEntry(Map<String, dynamic>.from(item)),
    ]);
  }

  StudentLeaderboardEntry _leaderboardEntry(Map<String, dynamic> item) {
    final student = asMap(item['student']);
    return StudentLeaderboardEntry(
      rank: asInt(item['rank']),
      student: StudentBrief(
        id: asInt(student['id']),
        name: asString(student['name']),
        yearOfBirth: student['yearOfBirth'] == null
            ? null
            : asInt(student['yearOfBirth']),
      ),
      points: asInt(item['points']),
    );
  }

  @override
  Future<AdminSessionRow?> lastSession() async {
    try {
      final json = await getMap(ApiEndpoints.sessionsLast);
      return _sessionRowFrom(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AdminSessionRow>> courseSessions(int courseId) async {
    final items = await _safeGetList(ApiEndpoints.courseSessions(courseId));
    return _sessionRows(items);
  }

  @override
  Future<AdminSessionRow> sessionRow(int sessionId) async {
    final json = await getMap(ApiEndpoints.sessionDetail(sessionId));
    return _sessionRowFrom(json);
  }

  Future<List<AdminSessionRow>> _sessionRows(
    List<Map<String, dynamic>> items,
  ) async {
    const batchSize = 12;
    final summaries = <int, Map<String, dynamic>>{};
    for (var start = 0; start < items.length; start += batchSize) {
      final end = start + batchSize > items.length
          ? items.length
          : start + batchSize;
      final slice = items.sublist(start, end);
      final results = await Future.wait(
        slice.map(
          (item) => _safeGetMap(ApiEndpoints.sessionSummary(asInt(item['id']))),
        ),
      );
      for (var i = 0; i < slice.length; i++) {
        summaries[asInt(slice[i]['id'])] = results[i];
      }
    }
    return [
      for (final item in items)
        _sessionRowFrom(
          item,
          summary: summaries[asInt(item['id'])] ?? const {},
        ),
    ];
  }

  AdminSessionRow _sessionRowFrom(
    Map<String, dynamic> json, {
    Map<String, dynamic>? summary,
  }) {
    final map = summary ?? const <String, dynamic>{};
    return AdminSessionRow(
      id: asInt(json['id']),
      index: asInt(json['orderInCourse'] ?? json['index']),
      date: asDate(json['date']),
      present: asInt(map['present']),
      total: asInt(map['total']),
      earlyPoints: asInt(json['earlyPoints']),
      midPoints: asInt(json['midPoints']),
      latePoints: asInt(json['latePoints']),
      earlyUntil: hhmm(json['earlyUntil']),
      lateFrom: hhmm(json['lateFrom']),
    );
  }

  @override
  Future<StudentCourseBundle> studentCourseBundle(
    int courseId,
    int studentId,
  ) async {
    final json = await getMap(
      ApiEndpoints.studentCourseBundle(studentId, courseId),
    );
    final domainMatns = (await _allMatns()).map(mapMatn).toList();
    return mapBundle(json, matns: domainMatns);
  }

  // ── Students / reference data ───────────────────────────────────────────

  AdminStudentRow _studentRowFrom(
    Map<String, dynamic> item, {
    String fallbackTeamName = '',
  }) {
    final teams = asMapList(item['teams']);
    final names = teams
        .map((t) => asString(t['name']))
        .where((n) => n.isNotEmpty)
        .toList();
    return AdminStudentRow(
      id: asInt(item['id']),
      name: asString(item['name']),
      teamNames: names.isNotEmpty ? names.join(' · ') : fallbackTeamName,
      barcode: asString(item['barcode']),
      yearOfBirth: item['yearOfBirth'] == null
          ? null
          : asInt(item['yearOfBirth']),
      active: item['active'] != false,
    );
  }

  @override
  Future<PagedResult<AdminStudentRow>> studentsPage({
    String? query,
    int? teamId,
    int page = 1,
    int pageSize = 30,
  }) async {
    final q = query?.trim() ?? '';
    if (teamId != null) {
      final items = await _safeGetList(ApiEndpoints.teamStudents(teamId));
      final teams = await _allTeams();
      final team = teams.where((t) => asInt(t['id']) == teamId).firstOrNull;
      final teamName = team == null ? '' : asString(team['name']);
      var rows = items
          .map((item) => _studentRowFrom(item, fallbackTeamName: teamName))
          .toList();
      if (q.isNotEmpty) {
        rows = rows.where((row) => studentMatchesQuery(row, q)).toList();
      }
      return PagedResult(
        items: rows,
        page: 1,
        hasMore: false,
        total: rows.length,
      );
    }

    final json = await getMap(
      ApiEndpoints.students,
      query: {
        'page': page,
        'page_size': pageSize,
        if (q.isNotEmpty) 'search': q,
      },
    );
    var rows = asMapList(
      json['results'],
    ).map((item) => _studentRowFrom(item)).toList();
    var total = asInt(json['count']);
    var hasMore = json['next'] != null;
    if (rows.isEmpty && q.isNotEmpty && RegExp(r'^[0-9+]{5,}$').hasMatch(q)) {
      try {
        final raw = await postDynamic(
          ApiEndpoints.searchStudents,
          data: {
            'queries': [q],
          },
        );
        final results = raw is List ? raw : [raw];
        rows = [
          for (final item in results.whereType<Map>())
            if (asString(item['status']) == 'found')
              AdminStudentRow(
                id: asInt(item['id']),
                name: asString(item['name']),
                teamNames:
                    (item['teams'] as List?)
                        ?.map((team) => '')
                        .where((name) => name.isNotEmpty)
                        .join(' · ') ??
                    '',
                barcode: '',
                yearOfBirth: item['yearOfBirth'] == null
                    ? null
                    : asInt(item['yearOfBirth']),
                active: true,
              ),
        ];
        total = rows.length;
        hasMore = false;
      } catch (_) {
        // Phone lookup needs the phoneSearch ability.
      }
    }
    final result = PagedResult(
      items: rows,
      page: page,
      hasMore: hasMore,
      total: total,
    );
    _studentPages[_pageKey('students', {
          'page': page,
          'page_size': pageSize,
          if (q.isNotEmpty) 'search': q,
          'team': ?teamId,
        })] =
        result;
    return result;
  }

  @override
  Future<PagedResult<AdminStudentRow>?> studentsPageCached({
    String? query,
    int? teamId,
    int page = 1,
    int pageSize = 30,
  }) async {
    final q = query?.trim() ?? '';
    final key = _pageKey('students', {
      'page': page,
      'page_size': pageSize,
      if (q.isNotEmpty) 'search': q,
      'team': ?teamId,
    });
    final memory = _studentPages[key];
    if (memory != null) return memory;
    if (teamId != null) return null;
    final cached = await cachedMap(
      ApiEndpoints.students,
      query: {
        'page': page,
        'page_size': pageSize,
        if (q.isNotEmpty) 'search': q,
      },
    );
    if (cached == null) return null;
    final rows = asMapList(
      cached['results'],
    ).map((item) => _studentRowFrom(item)).toList();
    return PagedResult(
      items: rows,
      page: page,
      hasMore: cached['next'] != null,
      total: asInt(cached['count']),
    );
  }

  @override
  Future<List<AdminStudentRow>> students({String? query, int? teamId}) async {
    var fallbackTeamName = '';
    List<Map<String, dynamic>> items;
    if (teamId != null) {
      items = await _safeGetList(ApiEndpoints.teamStudents(teamId));
      final teams = await _allTeams();
      final team = teams.where((t) => asInt(t['id']) == teamId).firstOrNull;
      if (team != null) fallbackTeamName = asString(team['name']);
    } else {
      items = await _allStudents();
    }
    var mapped = items.map((item) {
      final teams = asMapList(item['teams']);
      final names = teams
          .map((t) => asString(t['name']))
          .where((n) => n.isNotEmpty)
          .toList();
      return AdminStudentRow(
        id: asInt(item['id']),
        name: asString(item['name']),
        teamNames: names.isNotEmpty ? names.join(' · ') : fallbackTeamName,
        barcode: asString(item['barcode']),
        yearOfBirth: item['yearOfBirth'] == null
            ? null
            : asInt(item['yearOfBirth']),
        active: item['active'] != false,
      );
    }).toList();

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      final local = mapped.where((row) => studentMatchesQuery(row, q)).toList();
      final ids = local.map((row) => row.id).toSet();
      // Phone numbers are not part of the student list resource; use the
      // dedicated lookup when the query looks like a phone/id.
      if (RegExp(r'^[0-9+]{5,}$').hasMatch(q) && teamId == null) {
        try {
          final raw = await postDynamic(
            ApiEndpoints.searchStudents,
            data: {
              'queries': [q],
            },
          );
          final results = raw is List ? raw : [raw];
          for (final item in results) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            if (asString(map['status']) != 'found') continue;
            final id = asInt(map['id']);
            if (id == 0 || ids.contains(id)) continue;
            final teamNames = (map['teams'] as List?)
                ?.map((team) => '$team')
                .where((name) => name.isNotEmpty)
                .join(' · ');
            local.add(
              AdminStudentRow(
                id: id,
                name: asString(map['name']),
                teamNames: teamNames ?? '',
                barcode: '',
                yearOfBirth: map['yearOfBirth'] == null
                    ? null
                    : asInt(map['yearOfBirth']),
                active: true,
              ),
            );
            ids.add(id);
          }
        } catch (_) {
          // The phone lookup needs the `phoneSearch` ability; the local
          // name/barcode filter still works without it.
        }
      }
      mapped = local;
    }
    mapped.sort((a, b) => a.name.compareTo(b.name));
    return mapped;
  }

  @override
  Future<AdminStudentProfile> studentProfile(int id) async {
    final json = await getMap(ApiEndpoints.studentOverview(id));
    final profile = mapStudentProfile(asMap(json['profile']));
    final stats = asMap(json['stats']);
    final teams = asMapList(json['teams']).map(mapTeam).toList();
    final subjects = [
      for (final item in asMapList(json['subjects']))
        (
          subject: asString(item['name']),
          result: item['bestFinalPercent'] == null
              ? null
              : asInt(item['bestFinalPercent']),
        ),
    ];
    final certificates = [
      for (final item in asMapList(json['certificates']))
        AdminCertificateRow(
          id: asInt(item['id']),
          studentId: asInt(item['studentId'], id),
          studentName: profile.name,
          courseId: asInt(item['courseId']),
          startJuz: asInt(item['startJuz']),
          endJuz: asInt(item['endJuz']),
          mark: asInt(item['mark']),
          byHeart: item['byHeart'] == true,
          date: asDate(item['date']),
        ),
    ];
    final matnProgress = [
      for (final item in asMapList(json['matnProgress']))
        AdminMatnProgress(
          name: asString(item['name']),
          lastVerse: asInt(item['lastVerse']),
          totalVerses: asInt(item['totalVerses']),
        ),
    ];
    final examResults = [
      for (final item in asMapList(json['examResults']))
        AdminExamResult(
          subject: asString(item['subject']),
          typeLabel: _examTypeLabel(asString(item['type'])),
          mark: asDouble(item['mark']),
          maxMark: asInt(item['maxMark']),
          passed: item['passed'] == true,
          date: asDate(item['date']),
        ),
    ];
    final memorizations = [
      for (final item in asMapList(json['memorizations']))
        mapMemorization(item),
    ];
    final matnRecitationLog = [
      for (final item in asMapList(json['matnRecitationLog']))
        AdminMatnRecitation(
          matnName: asString(item['matnName']),
          lastVerse: asInt(item['lastVerse']),
          teacherName: optionalName(item['teacher']),
          date: asDateOrNull(item['date']),
        ),
    ];

    return AdminStudentProfile(
      profile: profile,
      teams: teams,
      pagesMemorized: asInt(stats['pagesMemorized']),
      certificatesCount: asInt(stats['certificatesCount']),
      subjects: subjects,
      certificates: certificates,
      testedJuz: asInt(stats['testedJuz']),
      matnProgress: matnProgress,
      examResults: examResults,
      memorizations: memorizations,
      matnRecitationLog: matnRecitationLog,
    );
  }

  @override
  Future<List<AdminTeamRow>> teams() async {
    final teams = await _allTeams();
    final types = await _allTeamTypes();
    final teachers = await _allTeachers();
    final typeNames = {
      for (final t in types) asInt(t['id']): asString(t['name']),
    };
    final teacherNames = {
      for (final t in teachers) asInt(t['id']): asString(t['name']),
    };
    final counts = await Future.wait(
      teams.map(
        (team) => _safeGetList(
          ApiEndpoints.teamStudents(asInt(team['id'])),
        ).then((members) => members.length),
      ),
    );
    final result = <AdminTeamRow>[
      for (var index = 0; index < teams.length; index++)
        AdminTeamRow(
          id: asInt(teams[index]['id']),
          name: asString(teams[index]['name']),
          typeName: typeNames[asInt(teams[index]['teamTypeId'])] ?? 'حلقة',
          teacherName: teacherNames[asInt(teams[index]['teacherId'])] ?? '',
          studentsCount: counts[index],
        ),
    ];
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  @override
  Future<List<AdminTeacherRow>> teachers() async {
    final teachers = await _allTeachers();
    final teams = await _allTeams();
    final counts = <int, int>{};
    for (final team in teams) {
      final id = asInt(team['teacherId']);
      if (id == 0) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return [
      for (final teacher in teachers)
        AdminTeacherRow(
          name: asString(teacher['name']),
          teamsCount: counts[asInt(teacher['id'])] ?? 0,
        ),
    ]..sort((a, b) => b.teamsCount.compareTo(a.teamsCount));
  }

  @override
  Future<List<TeacherCandidate>> teacherCandidates() async {
    final items = await _allCandidates();
    return [
      for (final item in items)
        TeacherCandidate(
          userId: asInt(item['userId']),
          name: asString(item['name']),
          username: asString(item['username']),
          role: switch (asString(item['role'])) {
            'admin' => 'إدارة',
            'teacher' => 'معلم',
            'student' => 'طالب',
            final role => role,
          },
          teacherId: item['teacherId'] == null
              ? null
              : asInt(item['teacherId']),
        ),
    ];
  }

  @override
  Future<AdminTeacherDetail?> teacherDetail(int teacherId) async {
    try {
      final json = await getMap(ApiEndpoints.teacherDetail(teacherId));
      if (json.isEmpty) return null;
      return AdminTeacherDetail(
        id: asInt(json['id'], teacherId),
        name: asString(json['name']),
        userId: json['userId'] == null ? null : asInt(json['userId']),
        teams: [
          for (final item in asMapList(json['teams']))
            AdminTeamRef(id: asInt(item['id']), name: asString(item['name'])),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> createTeacher(String name) async {
    final json = await postMap(
      ApiEndpoints.teacherCreate,
      data: {'name': name.trim()},
    );
    _teachersRaw = null;
    _teacherNames.clear();
    _candidatesRaw = null;
    return asInt(json['id']);
  }

  @override
  Future<void> linkTeacherToUser(int userId, int teacherId) async {
    await patchMap(
      ApiEndpoints.adminUser(userId),
      data: {'teacherId': teacherId},
    );
    _userPages.clear();
    _teachersRaw = null;
    _teacherNames.clear();
    _candidatesRaw = null;
  }

  @override
  Future<PagedResult<AdminUserRow>> usersPage({
    String? query,
    String filter = 'all',
    int page = 1,
    int pageSize = 30,
  }) async {
    final q = query?.trim() ?? '';
    final key = _pageKey('users', {
      'page': page,
      'page_size': pageSize,
      if (q.isNotEmpty) 'search': q,
      if (filter != 'all') 'filter': filter,
    });
    final json = await getMap(
      ApiEndpoints.adminUsers,
      query: {
        'page': page,
        'page_size': pageSize,
        if (q.isNotEmpty) 'search': q,
        if (filter != 'all') 'filter': filter,
      },
    );
    final items = await Future.wait(
      asMapList(json['results']).map(_adminUserRowFrom),
    );
    final result = PagedResult(
      items: items,
      page: page,
      hasMore: json['next'] != null,
      total: asInt(json['count']),
    );
    _userPages[key] = result;
    return result;
  }

  @override
  Future<PagedResult<AdminUserRow>?> usersPageCached({
    String? query,
    String filter = 'all',
    int page = 1,
    int pageSize = 30,
  }) async {
    final q = query?.trim() ?? '';
    final key = _pageKey('users', {
      'page': page,
      'page_size': pageSize,
      if (q.isNotEmpty) 'search': q,
      if (filter != 'all') 'filter': filter,
    });
    return _userPages[key];
  }

  Future<AdminUserRow> _adminUserRowFrom(Map<String, dynamic> item) async {
    final studentId = item['studentId'] == null
        ? null
        : asInt(item['studentId']);
    final teacherId = item['teacherId'] == null
        ? null
        : asInt(item['teacherId']);
    var name = asString(item['name']).trim();
    if (name.isEmpty && studentId != null) {
      name = await _studentNameOrNull(studentId) ?? '';
    }
    if (name.isEmpty && teacherId != null) {
      name = await _teacherNameOrNull(teacherId) ?? '';
    }
    return AdminUserRow(
      id: asInt(item['id']),
      name: name,
      username: asString(item['username']),
      active: item['isActive'] == true,
      isAdmin: item['isAdmin'] == true,
      isSupervisor: item['isSupervisor'] == true,
      isTeacher: item['isTeacher'] == true,
      isStudent: item['isStudent'] == true,
      studentId: studentId,
      teacherId: teacherId,
      teamNames: [
        for (final team in asMapList(item['teams'])) asString(team['name']),
      ].where((e) => e.isNotEmpty).toList(),
    );
  }

  @override
  Future<AdminUserRow?> user(int userId) async {
    try {
      final json = await getMap(ApiEndpoints.adminUser(userId));
      if (json.isEmpty) return null;
      return _adminUserRowFrom(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AdminUserPermissions> userPermissions(int userId) async {
    final json = await getMap(ApiEndpoints.adminUserPermissions(userId));
    return AdminUserPermissions.fromJson(json);
  }

  @override
  Future<void> updateUserPermissions(
    int userId,
    AdminUserPermissions permissions,
  ) async {
    await putMap(
      ApiEndpoints.adminUserPermissions(userId),
      data: {
        // The permissions endpoint only promotes; demotion goes through the
        // account endpoint (`setUserAdmin`) because the server ignores
        // `isAdmin: false` here.
        if (permissions.isAdmin) 'isAdmin': true,
        'modules': {
          for (final entry in permissions.modules.entries)
            entry.key: entry.value.toJson(),
        },
        'specialAbilities': permissions.abilities.toList(),
      },
    );
    _userPages.clear();
  }

  @override
  Future<void> setUserAdmin(int userId, bool isAdmin) async {
    // Verified against the live API (2026-10-31): any admin may demote another
    // admin; precedence/creation order is not checked by the server.
    await patchMap(ApiEndpoints.adminUser(userId), data: {'isAdmin': isAdmin});
    _userPages.clear();
  }

  @override
  Future<List<AdminContentItem>> teamTypes() async {
    final items = await _allTeamTypes();
    return [
      for (final item in items)
        AdminContentItem(
          id: asInt(item['id']),
          name: asString(item['name']),
          subtitle: item['note'] == null ? null : asString(item['note']),
        ),
    ];
  }

  @override
  Future<List<AdminContentItem>> subjects() async {
    final items = await _allSubjects();
    return [
      for (final item in items)
        AdminContentItem(
          id: asInt(item['id']),
          name: asString(item['name']),
          subtitle: item['book'] == null ? null : asString(item['book']),
        ),
    ];
  }

  @override
  Future<List<AdminContentItem>> distributables() async {
    final items = await getAllPages(ApiEndpoints.distributables);
    return [
      for (final item in items)
        AdminContentItem(
          id: asInt(item['id']),
          name: asString(item['name']),
          subtitle: item['note'] == null ? null : asString(item['note']),
        ),
    ];
  }

  @override
  Future<List<AdminContentItem>> matns() async {
    final items = await _allMatns();
    return [
      for (final item in items)
        AdminContentItem(
          id: asInt(item['id']),
          name: asString(item['name']),
          subtitle:
              '${asInt(item['pointsPerVerse'])} نقطة/بيت · '
              '${asInt(item['totalVerses'])} بيت',
        ),
    ];
  }

  // ── Change requests / audit / notifications ─────────────────────────────

  @override
  Future<List<AdminChangeRequest>> changeRequests() async {
    final items = await getAllPages(ApiEndpoints.changeRequests);
    final result = <AdminChangeRequest>[];
    for (final item in items) {
      final studentId = asInt(item['studentId']);
      result.add(
        AdminChangeRequest(
          id: asInt(item['id']),
          studentId: studentId,
          studentName: await _studentName(studentId),
          fieldLabel: _fieldLabel(asString(item['field'])),
          requestedValue: asString(item['requestedValue']),
          currentValue: item['currentValue'] == null
              ? null
              : asString(item['currentValue']),
          status: asString(item['status'], 'pending'),
          createdAt: asDate(item['createdAt']),
        ),
      );
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  @override
  Future<
    List<
      ({
        String model,
        String action,
        String description,
        DateTime when,
        int recordId,
      })
    >
  >
  recentWrites({int limit = 40}) async {
    final json = await getMap(
      ApiEndpoints.adminAudit,
      query: {'page_size': limit},
    );
    return [
      for (final item in asMapList(json['results']))
        (
          model: asString(item['model']),
          action: asString(item['action']),
          description: _auditDescription(item),
          when: asDate(item['timestamp']),
          recordId: asInt(item['object_id']),
        ),
    ]..sort((a, b) => b.when.compareTo(a.when));
  }

  String _auditDescription(Map<String, dynamic> item) {
    final action = switch (asString(item['action'])) {
      'create' => 'إضافة',
      'update' => 'تعديل',
      'delete' => 'حذف',
      final action => action,
    };
    final model = switch (asString(item['model'])) {
      'Attendance' => 'حضور',
      'QuranMemorization' => 'حفظ',
      'Transaction' => 'معاملة',
      'QuranCertificate' => 'شهادة',
      'Student' => 'طالب',
      'Team' => 'حلقة',
      'Course' => 'دورة',
      'Session' => 'جلسة',
      final model => model,
    };
    return '$action $model';
  }

  @override
  Future<List<AdminNotification>> notifications({int limit = 200}) async {
    final json = await getMap(
      ApiEndpoints.adminNotifications,
      query: {'page_size': limit},
    );
    return [
      for (final item in asMapList(json['results']))
        AdminNotification(
          id: asString(item['id']),
          kind: asString(item['kind']),
          day: asDate(item['day']),
          when: asDate(item['when']),
          firstName: asString(item['firstName']),
          extraCount: asInt(item['extraCount']),
          recordId: item['recordId'] == null ? null : asInt(item['recordId']),
        ),
    ];
  }

  @override
  Future<void> markAdminNotifRead() async {
    await postMap(ApiEndpoints.adminNotificationsRead, data: const <dynamic>[]);
  }

  @override
  Future<int> unreadAdminNotifications() async {
    final json = await getMap(ApiEndpoints.adminNotificationsUnread);
    return asInt(json['count']);
  }

  @override
  Future<void> resolveChangeRequest(int id, {required bool approve}) async {
    await patchMap(
      ApiEndpoints.changeRequest(id),
      data: {'status': approve ? 'approved' : 'rejected'},
    );
  }

  @override
  Future<bool> undoRecord(String model, int recordId) async {
    await postMap(
      ApiEndpoints.adminNotificationsUndo,
      data: {'model': model, 'recordId': recordId},
    );
    return true;
  }

  // ── Sessions / attendance ───────────────────────────────────────────────

  @override
  Future<List<AdminAttendanceRow>> sessionAttendance(int sessionId) async {
    final json = await getMap(ApiEndpoints.sessionAttendance(sessionId));
    return [
      for (final item in asMapList(json['results']))
        AdminAttendanceRow(
          studentId: asInt(item['studentId']),
          name: await _studentName(asInt(item['studentId'])),
          arrivalTime: asDateOrNull(item['arrivalTime']),
          category: parseCategory(item['category']),
        ),
    ]..sort((a, b) {
      final at = a.arrivalTime;
      final bt = b.arrivalTime;
      if (at == null || bt == null) return 0;
      return at.compareTo(bt);
    });
  }

  @override
  Future<List<AdminSessionMember>> sessionMembers(int sessionId) async {
    final items = await _safeGetList(ApiEndpoints.sessionRoster(sessionId));
    return [
      for (final item in items)
        AdminSessionMember(
          studentId: asInt(item['studentId']),
          name: asString(item['name']),
          barcode: asString(item['barcode']),
          arrivalTime: asDateOrNull(item['arrivalTime']),
        ),
    ];
  }

  @override
  Future<AttendanceScanResult?> addAttendanceByBarcode(
    int sessionId,
    String barcode,
  ) async {
    final json = await postMap(
      ApiEndpoints.sessionAttendanceScan(sessionId),
      data: {'barcode': barcode.trim()},
    );
    final student = asMap(json['student']);
    final studentId = asInt(student['id']);
    if (studentId == 0) return null;
    return AttendanceScanResult(
      studentId: studentId,
      name: asString(student['name']),
      created: asString(json['status']) != 'ignored',
    );
  }

  @override
  Future<void> addManualAttendance(
    int sessionId,
    int studentId, {
    DateTime? time,
  }) async {
    await postMap(
      ApiEndpoints.sessionAttendance(sessionId),
      data: {
        'studentId': studentId,
        'arrivalTime': (time ?? DateTime.now()).toIso8601String(),
      },
    );
  }

  Future<int?> _attendanceId(int sessionId, int studentId) async {
    final json = await getMap(ApiEndpoints.sessionAttendance(sessionId));
    for (final item in asMapList(json['results'])) {
      if (asInt(item['studentId']) == studentId) return asInt(item['id']);
    }
    return null;
  }

  @override
  Future<void> removeAttendance(int sessionId, int studentId) async {
    final id = await _attendanceId(sessionId, studentId);
    if (id == null) return;
    await deleteVoid(ApiEndpoints.attendanceDetail(id));
  }

  @override
  Future<void> updateAttendanceTime(
    int sessionId,
    int studentId,
    DateTime time,
  ) async {
    final id = await _attendanceId(sessionId, studentId);
    if (id == null) return;
    await patchMap(
      ApiEndpoints.attendanceDetail(id),
      data: {'arrivalTime': time.toIso8601String()},
    );
  }

  @override
  Future<List<AdminSessionRecord>> sessionRecords(int sessionId) async {
    final items = await _safeGetList(ApiEndpoints.sessionRecords(sessionId));
    return [
      for (final item in items)
        AdminSessionRecord(
          id: asInt(item['id']),
          kind: asString(item['kind']),
          studentName: asString(item['studentName']),
          title: asString(item['title']),
          subtitle: asString(item['subtitle']),
          when: asDate(item['when']),
        ),
    ]..sort((a, b) => b.when.compareTo(a.when));
  }

  @override
  Future<int> sendAbsenceNotices({
    required int sessionId,
    required List<int> studentIds,
  }) async {
    final json = await postMap(
      ApiEndpoints.sessionAbsenceNotices(sessionId),
      data: {'studentIds': studentIds},
    );
    return asInt(json['sent'], studentIds.length);
  }

  @override
  Future<Object> deleteSessionsWithRecords(List<int> sessionIds) async {
    if (sessionIds.isEmpty) return '';
    final json = await postMap(
      ApiEndpoints.sessionsBulkDelete,
      data: {'ids': sessionIds},
    );
    return asString(json['undoToken']);
  }

  @override
  Future<void> restoreSessions(Object snapshot) async {
    if (snapshot is! String || snapshot.isEmpty) return;
    await postMap(ApiEndpoints.sessionsRestore, data: {'undoToken': snapshot});
  }

  @override
  Future<int> addSession(int courseId, DateTime date) async {
    final json = await postMap(
      ApiEndpoints.courseSessions(courseId),
      data: {
        'date': _dateOnly(date),
        'earlyPoints': 0,
        'midPoints': 0,
        'latePoints': 0,
        'earlyUntil': '00:00',
        'lateFrom': '23:59',
      },
    );
    return asInt(json['id']);
  }

  @override
  Future<void> updateSession(
    int sessionId, {
    required int earlyPoints,
    required int midPoints,
    required int latePoints,
    required String earlyUntil,
    required String lateFrom,
    DateTime? date,
  }) async {
    await patchMap(
      ApiEndpoints.sessionDetail(sessionId),
      data: {
        'earlyPoints': earlyPoints,
        'midPoints': midPoints,
        'latePoints': latePoints,
        'earlyUntil': hhmm(earlyUntil),
        'lateFrom': hhmm(lateFrom),
        if (date != null) 'date': _dateOnly(date),
      },
    );
  }

  // ── Records entry ───────────────────────────────────────────────────────

  @override
  Future<void> addMemorization({
    required int studentId,
    required int sessionId,
    required List<QuranUnit> units,
    required int rating,
    required String reciterName,
  }) async {
    final reciterId = await _teacherIdByName(reciterName);
    await postMap(
      ApiEndpoints.studentMemorizations(studentId),
      data: {
        'sessionId': sessionId,
        'units': [
          for (final unit in units)
            {'page': unit.page, 'partIndex': unit.partIndex},
        ],
        'rating': rating,
        'reciterId': ?reciterId,
      },
    );
  }

  @override
  Future<void> addTransaction({
    required int studentId,
    required int sessionId,
    required String type,
    required int value,
    String? description,
  }) async {
    await postMap(
      ApiEndpoints.studentTransactions(studentId),
      data: {
        'sessionId': sessionId,
        'type': type,
        'pointsValue': value,
        if (description != null && description.trim().isNotEmpty)
          'textDescription': description.trim(),
      },
    );
  }

  @override
  Future<void> addMatnRecitation({
    required int studentId,
    required int matnId,
    required int sessionId,
    required int lastVerse,
    required String teacherName,
  }) async {
    final teacherId = await _teacherIdByName(teacherName);
    await postMap(
      ApiEndpoints.studentMatnRecitations(studentId),
      data: {
        'matnId': matnId,
        'lastVerse': lastVerse,
        'sessionId': sessionId,
        'teacherId': ?teacherId,
      },
    );
  }

  // ── Courses ─────────────────────────────────────────────────────────────

  @override
  Future<int> addCourse(String name, DateTime start, DateTime end) async {
    final json = await postMap(
      ApiEndpoints.courses,
      data: {
        'name': name,
        'startDate': _dateOnly(start),
        'endDate': _dateOnly(end),
        'goodMemorizationPoints': 5,
        'veryGoodMemorizationPoints': 10,
        'excellentMemorizationPoints': 15,
        'quranCertificatePoints': 100,
      },
    );
    final id = asInt(json['id']);
    await courseSummary(id);
    return id;
  }

  @override
  Future<void> updateCourse(
    int id, {
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int goodPoints,
    required int veryGoodPoints,
    required int excellentPoints,
    required int certificatePoints,
  }) async {
    await patchMap(
      ApiEndpoints.courseDetail(id),
      data: {
        'name': name,
        'startDate': _dateOnly(startDate),
        'endDate': _dateOnly(endDate),
        'goodMemorizationPoints': goodPoints,
        'veryGoodMemorizationPoints': veryGoodPoints,
        'excellentMemorizationPoints': excellentPoints,
        'quranCertificatePoints': certificatePoints,
      },
    );
    await courseSummary(id);
  }

  @override
  Future<void> deleteCourse(int courseId) async {
    await deleteVoid(ApiEndpoints.courseDetail(courseId));
    _coursesCache = _coursesCache
        ?.where((course) => course.id != courseId)
        .toList();
    _coursesAt = DateTime.now();
  }

  // ── Students writes ─────────────────────────────────────────────────────

  @override
  Future<int> addStudent({
    required String name,
    String? fatherName,
    int? yearOfBirth,
    int? teamId,
    String? phone,
  }) async {
    final json = await postMap(
      ApiEndpoints.students,
      data: {
        'name': name,
        if (fatherName != null && fatherName.trim().isNotEmpty)
          'fatherName': fatherName.trim(),
        'yearOfBirth': ?yearOfBirth,
        if (teamId != null) 'teamIds': [teamId],
        if (phone != null && phone.trim().isNotEmpty)
          'phones': [
            {'phone': phone.trim(), 'type': 'parent', 'isPrimary': true},
          ],
      },
    );
    _studentsRaw = null;
    return asInt(json['id']);
  }

  @override
  Future<void> updateStudent(
    int studentId, {
    required String name,
    String? fatherName,
    int? yearOfBirth,
  }) async {
    await patchMap(
      ApiEndpoints.studentDetail(studentId),
      data: {
        'name': name,
        'fatherName': ?fatherName,
        'yearOfBirth': ?yearOfBirth,
      },
    );
    _studentsRaw = null;
  }

  @override
  Future<void> addPhone(int studentId, String phone, String type) async {
    await postMap(
      ApiEndpoints.studentPhones(studentId),
      data: {'phone': phone, 'type': type},
    );
  }

  @override
  Future<void> updatePhone(
    int phoneId, {
    required String phone,
    required String type,
  }) async {
    await patchMap(
      ApiEndpoints.phoneDetail(phoneId),
      data: {'phone': phone, 'type': type},
    );
  }

  @override
  Future<void> removePhone(int phoneId) async {
    await deleteVoid(ApiEndpoints.phoneDetail(phoneId));
  }

  // ── Teams / teachers ────────────────────────────────────────────────────

  @override
  Future<List<AdminStudentRow>> teamStudents(int teamId) async {
    final items = await _safeGetList(ApiEndpoints.teamStudents(teamId));
    final teams = await _allTeams();
    final team = teams.where((t) => asInt(t['id']) == teamId).firstOrNull;
    final teamName = team == null ? '' : asString(team['name']);
    return [
      for (final item in items)
        AdminStudentRow(
          id: asInt(item['id']),
          name: asString(item['name']),
          teamNames: teamName,
          barcode: asString(item['barcode']),
          yearOfBirth: item['yearOfBirth'] == null
              ? null
              : asInt(item['yearOfBirth']),
          active: item['active'] != false,
        ),
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> addStudentsToTeam(int teamId, List<int> studentIds) async {
    await postMap(
      ApiEndpoints.teamStudents(teamId),
      data: {'studentIds': studentIds},
    );
  }

  @override
  Future<void> removeStudentsFromTeam(int teamId, List<int> studentIds) async {
    await deleteVoid(
      ApiEndpoints.teamStudents(teamId),
      data: {'studentIds': studentIds},
    );
  }

  @override
  Future<void> addTeam({
    required String name,
    required String typeName,
    String teacherName = '',
  }) async {
    final typeId = await _teamTypeIdByName(typeName);
    final teacherId = teacherName.trim().isEmpty
        ? null
        : await _teacherIdByName(teacherName);
    await postMap(
      ApiEndpoints.teams,
      data: {'name': name, 'teamTypeId': ?typeId, 'teacherId': ?teacherId},
    );
    _teamsRaw = null;
  }

  @override
  Future<void> addTeamType(String name) async {
    await postMap(ApiEndpoints.teamTypes, data: {'name': name});
    _teamTypesRaw = null;
  }

  @override
  Future<void> deleteTeamType(int id) async {
    await deleteVoid(ApiEndpoints.teamType(id));
    _teamTypesRaw = null;
  }

  @override
  Future<List<AdminTeamRow>> teacherTeams(String teacherName) async {
    final teacherId = await _teacherIdByName(teacherName);
    final teams = await _allTeams();
    final types = await _allTeamTypes();
    final typeNames = {
      for (final t in types) asInt(t['id']): asString(t['name']),
    };
    final mine = teams
        .where((team) => asInt(team['teacherId']) == teacherId)
        .toList();
    final counts = await Future.wait(
      mine.map(
        (team) => _safeGetList(
          ApiEndpoints.teamStudents(asInt(team['id'])),
        ).then((members) => members.length),
      ),
    );
    final result = <AdminTeamRow>[
      for (var index = 0; index < mine.length; index++)
        AdminTeamRow(
          id: asInt(mine[index]['id']),
          name: asString(mine[index]['name']),
          typeName: typeNames[asInt(mine[index]['teamTypeId'])] ?? 'حلقة',
          teacherName: teacherName,
          studentsCount: counts[index],
        ),
    ];
    return result..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> setTeamTeacher(int teamId, String teacherName) async {
    final userId = await _teacherUserIdByName(teacherName);
    if (userId == null) {
      throw const ApiException(
        code: 'TEACHER_NOT_FOUND',
        messageAr: 'تعذّر العثور على حساب هذا المعلم',
        messageEn: 'Could not find the teacher account',
      );
    }
    await setTeamTeacherById(teamId, userId);
  }

  @override
  Future<void> setTeamTeacherById(int teamId, int userId) async {
    await putMap(
      ApiEndpoints.teamTeacher(teamId),
      data: {'userId': userId, 'replace': true},
    );
    _teamsRaw = null;
    // Assigning may create a teacher row; never resolve names from stale lists.
    _teachersRaw = null;
    _teacherNames.clear();
    _candidatesRaw = null;
    _touchCache();
  }

  @override
  Future<void> removeTeamTeacher(int teamId) async {
    await deleteVoid(ApiEndpoints.teamTeacher(teamId));
    _teamsRaw = null;
    _teachersRaw = null;
    _teacherNames.clear();
  }

  // ── Content writes ──────────────────────────────────────────────────────

  @override
  Future<void> addSubject(String name, String? book) async {
    await postMap(ApiEndpoints.subjects, data: {'name': name, 'book': ?book});
    _subjectsRaw = null;
  }

  @override
  Future<void> addDistributable(String name, String? note) async {
    await postMap(
      ApiEndpoints.distributables,
      data: {'name': name, 'note': note, 'active': true},
    );
  }

  @override
  Future<void> updateMatn(
    int id,
    String name,
    int pointsPerVerse,
    int totalVerses,
  ) async {
    await patchMap(
      ApiEndpoints.matnDetail(id),
      data: {
        'name': name,
        'pointsPerVerse': pointsPerVerse,
        'totalVerses': totalVerses,
      },
    );
    _matnsRaw = null;
  }

  @override
  Future<void> deleteMatn(int id) async {
    await deleteVoid(ApiEndpoints.matnDetail(id));
    _matnsRaw = null;
  }

  @override
  Future<void> updateSubject(int id, String name, String? book) async {
    await patchMap(
      ApiEndpoints.subjectDetail(id),
      data: {'name': name, 'book': book},
    );
    _subjectsRaw = null;
  }

  @override
  Future<void> deleteSubject(int id) async {
    await deleteVoid(ApiEndpoints.subjectDetail(id));
    _subjectsRaw = null;
  }

  @override
  Future<void> updateDistributable(int id, String name, String? note) async {
    await patchMap(
      ApiEndpoints.distributableDetail(id),
      data: {'name': name, 'note': note},
    );
  }

  @override
  Future<void> deleteDistributable(int id) async {
    await deleteVoid(ApiEndpoints.distributableDetail(id));
  }

  @override
  Future<void> addMatn(String name, int pointsPerVerse, int totalVerses) async {
    await postMap(
      ApiEndpoints.matn,
      data: {
        'name': name,
        'pointsPerVerse': pointsPerVerse,
        'totalVerses': totalVerses,
      },
    );
    _matnsRaw = null;
  }

  // ── Student course records / certificates ───────────────────────────────

  @override
  Future<List<({int courseId, String course, int points})>>
  studentCourseRecords(int studentId) async {
    final items = await _safeGetList(ApiEndpoints.studentCourses(studentId));
    return [
      for (final item in items)
        (
          courseId: asInt(item['courseId']),
          course: asString(item['courseName']),
          points: asInt(item['points']),
        ),
    ];
  }

  @override
  Future<List<AdminContentItem>> courseExams(int courseId) async {
    final items = await _safeGetList(ApiEndpoints.courseExams(courseId));
    final subjects = await _allSubjects();
    final names = {
      for (final s in subjects) asInt(s['id']): asString(s['name']),
    };
    return [
      for (final item in items)
        AdminContentItem(
          id: asInt(item['id']),
          name: names[asInt(item['subjectId'])] ?? 'مادة',
          subtitle:
              '${formatDate(asDate(item['date']))} · '
              '${_examTypeLabel(asString(item['type']))} · '
              '${asInt(item['maxMark'])} درجة · '
              '${asInt(item['points'])} نقطة',
        ),
    ];
  }

  @override
  Future<List<AdminCertificateRow>> courseCertificates(int courseId) async {
    final items = await _safeGetList(ApiEndpoints.courseCertificates(courseId));
    final result = <AdminCertificateRow>[];
    for (final item in items) {
      final studentId = asInt(item['studentId']);
      result.add(
        AdminCertificateRow(
          id: asInt(item['id']),
          studentId: studentId,
          studentName: await _studentName(studentId),
          courseId: asInt(item['courseId'], courseId),
          startJuz: asInt(item['startJuz']),
          endJuz: asInt(item['endJuz']),
          mark: asInt(item['mark']),
          byHeart: item['byHeart'] == true,
          date: asDate(item['date']),
        ),
      );
    }
    return result..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addCertificate({
    required int studentId,
    required int courseId,
    required int startJuz,
    required int endJuz,
    required int mark,
    required bool byHeart,
    required DateTime date,
  }) async {
    await postMap(
      ApiEndpoints.studentCertificates(studentId),
      data: {
        'courseId': courseId,
        'startJuz': startJuz,
        'endJuz': endJuz,
        'mark': mark,
        'byHeart': byHeart,
        'date': _dateOnly(date),
      },
    );
  }

  @override
  Future<void> updateCertificate(
    int id, {
    required int studentId,
    required int courseId,
    required int startJuz,
    required int endJuz,
    required int mark,
    required bool byHeart,
    required DateTime date,
  }) async {
    await patchMap(
      ApiEndpoints.certificate(id),
      data: {
        'courseId': courseId,
        'startJuz': startJuz,
        'endJuz': endJuz,
        'mark': mark,
        'byHeart': byHeart,
        'date': _dateOnly(date),
      },
    );
  }

  @override
  Future<void> deleteCertificate(int id) async {
    await deleteVoid(ApiEndpoints.certificate(id));
  }

  // ── Exams ───────────────────────────────────────────────────────────────

  @override
  Future<void> addExam({
    required int courseId,
    required String subjectName,
    required String type,
    required int maxMark,
    required int minSuccessMark,
    required int points,
  }) async {
    final subjectId = await _subjectIdByName(subjectName);
    await postMap(
      ApiEndpoints.courseExams(courseId),
      data: {
        'subjectId': ?subjectId,
        'type': type,
        'date': _dateOnly(DateTime.now()),
        'maxMark': maxMark,
        'minSuccessMark': minSuccessMark,
        'points': points,
      },
    );
  }

  @override
  Future<AdminExamDetail?> examDetail(int examId) async {
    try {
      final json = await getMap(ApiEndpoints.examDetail(examId));
      final subjects = await _allSubjects();
      final subjectName = subjects
          .where((s) => asInt(s['id']) == asInt(json['subjectId']))
          .map((s) => asString(s['name']))
          .firstOrNull;
      return AdminExamDetail(
        id: asInt(json['id']),
        courseId: asInt(json['courseId']),
        subjectName: subjectName ?? 'مادة',
        type: asString(json['type']),
        maxMark: asInt(json['maxMark']),
        minSuccessMark: asInt(json['minSuccessMark']),
        points: asInt(json['points']),
        date: asDate(json['date']),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateExam(
    int examId, {
    required String subjectName,
    required String type,
    required int maxMark,
    required int minSuccessMark,
    required int points,
  }) async {
    final subjectId = await _subjectIdByName(subjectName);
    await patchMap(
      ApiEndpoints.examDetail(examId),
      data: {
        'subjectId': ?subjectId,
        'type': type,
        'maxMark': maxMark,
        'minSuccessMark': minSuccessMark,
        'points': points,
      },
    );
  }

  @override
  Future<void> deleteExam(int examId) async {
    await deleteVoid(ApiEndpoints.examDetail(examId));
  }

  @override
  Future<List<AdminSubmissionRow>> examSubmissions(int examId) async {
    final items = await _safeGetList(ApiEndpoints.examSubmissionsOf(examId));
    final result = <AdminSubmissionRow>[];
    for (final item in items) {
      final studentId = asInt(item['studentId']);
      result.add(
        AdminSubmissionRow(
          id: asInt(item['id']),
          studentId: studentId,
          studentName: await _studentName(studentId),
          mark: asDouble(item['mark']),
          date: asDateOrNull(item['date']),
        ),
      );
    }
    return result..sort((a, b) => b.mark.compareTo(a.mark));
  }

  @override
  Future<void> updateExamSubmission(int id, double mark) async {
    await patchMap(ApiEndpoints.examSubmissionDetail(id), data: {'mark': mark});
  }

  @override
  Future<void> deleteExamSubmission(int id) async {
    await deleteVoid(ApiEndpoints.examSubmissionDetail(id));
  }

  @override
  Future<void> addExamSubmission(int examId, int studentId, double mark) async {
    await putMap(
      ApiEndpoints.examSubmissionOf(examId, studentId),
      data: {'mark': mark},
    );
  }

  // ── Mosque identity / lifecycle (E17) ───────────────────────────────────

  @override
  Future<MosqueInfo> mosque() async {
    final json = await getMap(ApiEndpoints.mosque);
    return MosqueInfo(
      id: asInt(json['id']),
      name: asString(json['name']),
      code: asString(json['code']),
      logoUrl: json['logoUrl'] == null ? null : asString(json['logoUrl']),
      primaryColor: json['primaryColor'] == null
          ? null
          : asString(json['primaryColor']),
      status: json['status'] == null ? null : asString(json['status']),
      deletionMessage: json['deletionMessage'] == null
          ? null
          : asString(json['deletionMessage']),
      contactEmail: json['contactEmail'] == null
          ? null
          : asString(json['contactEmail']),
      contactPhone: json['contactPhone'] == null
          ? null
          : asString(json['contactPhone']),
      city: json['city'] == null ? null : asString(json['city']),
    );
  }

  @override
  Future<void> updateMosque({
    String? name,
    String? code,
    String? contactEmail,
    String? contactPhone,
    String? city,
  }) async {
    await patchMap(
      ApiEndpoints.mosque,
      data: {
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (code != null && code.trim().isNotEmpty) 'code': code.trim(),
        'contactEmail': ?contactEmail,
        'contactPhone': ?contactPhone,
        'city': ?city,
      },
    );
  }

  @override
  Future<MosqueDeletionState> mosqueDeletionState() async {
    final json = await getMap(ApiEndpoints.mosqueDeletionState);
    return MosqueDeletionState(
      status: asString(json['status'], 'active'),
      deletionScheduledAt: asDateOrNull(json['deletionScheduledAt']),
      deletionMessage: json['deletionMessage'] == null
          ? null
          : asString(json['deletionMessage']),
      exportDownloadToken: json['exportDownloadToken'] == null
          ? null
          : asString(json['exportDownloadToken']),
    );
  }

  @override
  Future<void> requestMosqueDeletion({String? message}) async {
    await postMap(
      ApiEndpoints.mosqueDeletion,
      data: {
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );
  }

  @override
  Future<void> cancelMosqueDeletion() async {
    await deleteVoid(ApiEndpoints.mosqueDeletion);
  }

  @override
  Future<void> updateMosqueDeletionMessage(String message) async {
    await patchMap(
      ApiEndpoints.mosqueDeletionMessage,
      data: {'message': message},
    );
  }

  @override
  Future<int?> requestFullExport() async {
    final json = await postMap(ApiEndpoints.exportsFull);
    return json['id'] == null ? null : asInt(json['id']);
  }

  @override
  Future<void> warmCache() async {
    Future<void> guard(Future<Object?> Function() action) async {
      try {
        await action();
      } catch (_) {
        // Best-effort; a failed warmer never affects the UI.
      }
    }

    await Future.wait([
      guard(() => generalStats()),
      guard(() => courses()),
      guard(() => lastSession()),
      guard(() => studentsPage(pageSize: 30)),
      guard(() => usersPage(pageSize: 30)),
      guard(() => teachers()),
      guard(() => teams()),
      guard(() => teamTypes()),
      guard(() => subjects()),
      guard(() => matns()),
      guard(() => notifications()),
      guard(() => changeRequests()),
    ]);
  }
}
