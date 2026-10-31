import '../../student/domain/models/student_models.dart';
import '../../student/domain/quran_units.dart';
import '../../student/domain/student_stats.dart';
import '../domain/admin_models.dart';

/// Read/write surface used by the admin/supervisor screens.
abstract class AdminRepository {
  // ── Dashboard / courses ─────────────────────────────────────────────────
  Future<GeneralStats> generalStats();
  Future<AdminHomeData?> homeCached();
  Future<List<AdminCourseSummary>> courses();
  Future<List<AdminCourseSummary>?> coursesCached();
  Future<AdminCourseSummary?> courseSummary(int courseId);
  Future<LeaderboardResult> leaderboard(int courseId);
  Future<AdminSessionRow?> lastSession();
  Future<List<AdminSessionRow>> courseSessions(int courseId);
  Future<AdminSessionRow> sessionRow(int sessionId);
  Future<StudentCourseBundle> studentCourseBundle(int courseId, int studentId);

  // ── Students / reference data ───────────────────────────────────────────
  Future<List<AdminStudentRow>> students({String? query, int? teamId});
  Future<PagedResult<AdminStudentRow>> studentsPage({
    String? query,
    int? teamId,
    int page = 1,
    int pageSize = 30,
  });
  Future<PagedResult<AdminStudentRow>?> studentsPageCached({
    String? query,
    int? teamId,
    int page = 1,
    int pageSize = 30,
  });
  Future<AdminStudentProfile> studentProfile(int id);
  Future<List<AdminTeamRow>> teams();
  Future<List<AdminTeacherRow>> teachers();
  Future<List<TeacherCandidate>> teacherCandidates();
  Future<PagedResult<AdminUserRow>> usersPage({
    String? query,
    String filter = 'all',
    int page = 1,
    int pageSize = 30,
  });
  Future<PagedResult<AdminUserRow>?> usersPageCached({
    String? query,
    String filter = 'all',
    int page = 1,
    int pageSize = 30,
  });
  Future<AdminUserRow?> user(int userId);
  Future<AdminUserPermissions> userPermissions(int userId);
  Future<void> updateUserPermissions(
    int userId,
    AdminUserPermissions permissions,
  );
  Future<void> setUserAdmin(int userId, bool isAdmin);
  Future<AdminTeacherDetail?> teacherDetail(int teacherId);
  Future<int> createTeacher(String name);
  Future<void> linkTeacherToUser(int userId, int teacherId);
  Future<List<AdminContentItem>> teamTypes();
  Future<List<AdminContentItem>> subjects();
  Future<List<AdminContentItem>> distributables();
  Future<List<AdminContentItem>> matns();

  // ── Change requests / audit / notifications ─────────────────────────────
  Future<List<AdminChangeRequest>> changeRequests();
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
  recentWrites({int limit = 40});
  Future<List<AdminNotification>> notifications({int limit = 200});
  Future<void> markAdminNotifRead();
  Future<int> unreadAdminNotifications();
  Future<void> resolveChangeRequest(int id, {required bool approve});
  Future<bool> undoRecord(String model, int recordId);

  // ── Sessions / attendance ───────────────────────────────────────────────
  Future<List<AdminAttendanceRow>> sessionAttendance(int sessionId);
  Future<List<AdminSessionMember>> sessionMembers(int sessionId);
  Future<AttendanceScanResult?> addAttendanceByBarcode(
    int sessionId,
    String barcode,
  );
  Future<void> addManualAttendance(
    int sessionId,
    int studentId, {
    DateTime? time,
  });
  Future<void> removeAttendance(int sessionId, int studentId);
  Future<void> updateAttendanceTime(
    int sessionId,
    int studentId,
    DateTime time,
  );
  Future<List<AdminSessionRecord>> sessionRecords(int sessionId);
  Future<int> sendAbsenceNotices({
    required int sessionId,
    required List<int> studentIds,
  });
  Future<Object> deleteSessionsWithRecords(List<int> sessionIds);
  Future<void> restoreSessions(Object snapshot);
  Future<int> addSession(int courseId, DateTime date);
  Future<void> updateSession(
    int sessionId, {
    required int earlyPoints,
    required int midPoints,
    required int latePoints,
    required String earlyUntil,
    required String lateFrom,
    DateTime? date,
  });

  // ── Records entry ───────────────────────────────────────────────────────
  Future<void> addMemorization({
    required int studentId,
    required int sessionId,
    required List<QuranUnit> units,
    required int rating,
    required String reciterName,
  });
  Future<void> addTransaction({
    required int studentId,
    required int sessionId,
    required String type,
    required int value,
    String? description,
  });
  Future<void> addMatnRecitation({
    required int studentId,
    required int matnId,
    required int sessionId,
    required int lastVerse,
    required String teacherName,
  });

  // ── Courses ─────────────────────────────────────────────────────────────
  Future<int> addCourse(String name, DateTime start, DateTime end);
  Future<void> updateCourse(
    int id, {
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int goodPoints,
    required int veryGoodPoints,
    required int excellentPoints,
    required int certificatePoints,
  });
  Future<void> deleteCourse(int courseId);

  // ── Students writes ─────────────────────────────────────────────────────
  Future<int> addStudent({
    required String name,
    String? fatherName,
    int? yearOfBirth,
    int? teamId,
    String? phone,
  });
  Future<void> updateStudent(
    int studentId, {
    required String name,
    String? fatherName,
    int? yearOfBirth,
  });
  Future<void> addPhone(int studentId, String phone, String type);
  Future<void> updatePhone(
    int phoneId, {
    required String phone,
    required String type,
  });
  Future<void> removePhone(int phoneId);

  // ── Teams / teachers ────────────────────────────────────────────────────
  Future<List<AdminStudentRow>> teamStudents(int teamId);
  Future<void> addStudentsToTeam(int teamId, List<int> studentIds);
  Future<void> removeStudentsFromTeam(int teamId, List<int> studentIds);
  Future<void> addTeam({
    required String name,
    required String typeName,
    String teacherName = '',
  });
  Future<void> addTeamType(String name);
  Future<void> deleteTeamType(int id);
  Future<List<AdminTeamRow>> teacherTeams(String teacherName);
  Future<void> setTeamTeacher(int teamId, String teacherName);
  Future<void> setTeamTeacherById(int teamId, int userId);
  Future<void> removeTeamTeacher(int teamId);

  // ── Content writes ──────────────────────────────────────────────────────
  Future<void> addSubject(String name, String? book);
  Future<void> addDistributable(String name, String? note);
  Future<void> updateMatn(
    int id,
    String name,
    int pointsPerVerse,
    int totalVerses,
  );
  Future<void> deleteMatn(int id);
  Future<void> updateSubject(int id, String name, String? book);
  Future<void> deleteSubject(int id);
  Future<void> updateDistributable(int id, String name, String? note);
  Future<void> deleteDistributable(int id);
  Future<void> addMatn(String name, int pointsPerVerse, int totalVerses);

  // ── Student course records / certificates ───────────────────────────────
  Future<List<({int courseId, String course, int points})>>
  studentCourseRecords(int studentId);
  Future<List<AdminContentItem>> courseExams(int courseId);
  Future<List<AdminCertificateRow>> courseCertificates(int courseId);
  Future<void> addCertificate({
    required int studentId,
    required int courseId,
    required int startJuz,
    required int endJuz,
    required int mark,
    required bool byHeart,
    required DateTime date,
  });
  Future<void> updateCertificate(
    int id, {
    required int studentId,
    required int courseId,
    required int startJuz,
    required int endJuz,
    required int mark,
    required bool byHeart,
    required DateTime date,
  });
  Future<void> deleteCertificate(int id);

  // ── Exams ───────────────────────────────────────────────────────────────
  Future<void> addExam({
    required int courseId,
    required String subjectName,
    required String type,
    required int maxMark,
    required int minSuccessMark,
    required int points,
  });
  Future<AdminExamDetail?> examDetail(int examId);
  Future<void> updateExam(
    int examId, {
    required String subjectName,
    required String type,
    required int maxMark,
    required int minSuccessMark,
    required int points,
  });
  Future<void> deleteExam(int examId);
  Future<List<AdminSubmissionRow>> examSubmissions(int examId);
  Future<void> updateExamSubmission(int id, double mark);
  Future<void> deleteExamSubmission(int id);
  Future<void> addExamSubmission(int examId, int studentId, double mark);

  // ── Mosque identity / lifecycle (E17) ───────────────────────────────────
  Future<MosqueInfo> mosque();
  Future<void> updateMosque({
    String? name,
    String? code,
    String? contactEmail,
    String? contactPhone,
    String? city,
  });
  Future<MosqueDeletionState> mosqueDeletionState();
  Future<void> requestMosqueDeletion({String? message});
  Future<void> cancelMosqueDeletion();
  Future<void> updateMosqueDeletionMessage(String message);
  Future<int?> requestFullExport();

  /// Warms the read-only cache after a successful login (best-effort).
  Future<void> warmCache();
}

/// Wrapper so screens can pass the leaderboard list around.
class LeaderboardResult {
  const LeaderboardResult(this.entries);
  final List<StudentLeaderboardEntry> entries;
}
