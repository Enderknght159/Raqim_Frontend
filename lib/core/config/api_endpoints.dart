/// Central place for API endpoint paths, relative to [AppConfig.apiBaseUrl].
///
/// Note: the live backend is Laravel — paths have NO trailing slash (a
/// trailing slash triggers a 301 that turns POSTs into GETs).
abstract class ApiEndpoints {
  // ── Auth & policy ───────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';
  static const String policyCurrent = '/policy/current';

  // ── Me / student self ───────────────────────────────────────────────────
  static const String me = '/me';
  static const String meProfile = '/me/profile';
  static const String meCourses = '/me/courses';
  static const String meQuran = '/me/quran';
  static const String meQuranMemorizations = '/me/quran/memorizations';
  static const String meQuranCertificates = '/me/quran/certificates';
  static const String meAchievement = '/me/achievement';
  static const String meExams = '/me/exams';
  static const String meTeams = '/me/teams';
  static const String meNotifications = '/me/notifications';
  static const String meNotificationsRead = '/me/notifications/read';
  static const String meNotificationsUnread = '/me/notifications/unread-count';
  static const String meChangeRequests = '/me/change-requests';

  static String meCourse(int courseId) => '$meCourses/$courseId';
  static String meCoursePoints(int courseId) => '${meCourse(courseId)}/points';
  static String meCourseLeaderboard(int courseId) =>
      '${meCourse(courseId)}/leaderboard';
  static String meCourseAttendance(int courseId) =>
      '${meCourse(courseId)}/attendance';
  static String meCourseTransactions(int courseId) =>
      '${meCourse(courseId)}/transactions';
  static String meTeamMembers(int teamId) => '$meTeams/$teamId/members';

  // ── Students ────────────────────────────────────────────────────────────
  static const String students = '/students';
  static const String studentsBulk = '/students/bulk';
  static const String studentsBarcodes = '/students/barcodes';
  static const String searchStudents = '/search/students';
  static const String phones = '/phones';

  static String studentDetail(int id) => '$students/$id';
  static String studentOverview(int id) => '$students/$id/overview';
  static String studentCourses(int id) => '$students/$id/courses';
  static String studentCourseBundle(int id, int courseId) =>
      '$students/$id/courses/$courseId/bundle';
  static String studentCoursePoints(int id, int courseId) =>
      '$students/$id/courses/$courseId/points';
  static String studentActivate(int id) => '$students/$id/activate';
  static String studentCertificates(int id) => '$students/$id/certificates';
  static String studentChangeRequests(int id) =>
      '$students/$id/change-requests';
  static String studentPhones(int id) => '$students/$id/phones';
  static String studentTeams(int id) => '$students/$id/teams';
  static String studentPhoto(int id) => '$students/$id/photo';
  static String studentMemorizations(int id) => '$students/$id/memorizations';
  static String studentRecitations(int id) => '$students/$id/recitations';
  static String studentMatnRecitations(int id) =>
      '$students/$id/matn-recitations';
  static String studentTajweedRatings(int id) =>
      '$students/$id/tajweed-ratings';
  static String studentRecitationTests(int id) =>
      '$students/$id/recitation-tests';
  static String studentTransactions(int id) => '$students/$id/transactions';
  static String studentDistributions(int id) => '$students/$id/distributions';
  static String phoneDetail(int id) => '$phones/$id';

  // ── Sessions & attendance ───────────────────────────────────────────────
  static const String sessions = '/sessions';
  static const String sessionsLast = '/sessions/last';
  static const String sessionsOrder = '/sessions/order';
  static const String sessionsBulkDelete = '/sessions/bulk-delete';
  static const String sessionsRestore = '/sessions/restore';
  static const String attendance = '/attendance';

  static String sessionDetail(int id) => '$sessions/$id';
  static String sessionAttendance(int id) => '$sessions/$id/attendance';
  static String sessionAttendanceScan(int id) =>
      '$sessions/$id/attendance/scan';
  static String sessionRecords(int id) => '$sessions/$id/records';
  static String sessionRoster(int id) => '$sessions/$id/roster';
  static String sessionSummary(int id) => '$sessions/$id/summary';
  static String sessionAbsenceNotices(int id) =>
      '$sessions/$id/absence-notices';
  static String attendanceDetail(int id) => '$attendance/$id';

  // ── Courses ─────────────────────────────────────────────────────────────
  static const String courses = '/courses';

  static String courseDetail(int id) => '$courses/$id';
  static String courseSessions(int id) => '$courses/$id/sessions';
  static String courseExams(int id) => '$courses/$id/exams';
  static String courseCertificates(int id) => '$courses/$id/certificates';
  static String courseLeaderboard(int id) => '$courses/$id/leaderboard';
  static String courseMessages(int id) => '$courses/$id/messages';
  static String courseExport(int id) => '$courses/$id/export';
  static String courseStudentBundle(int courseId, int studentId) =>
      '$courses/$courseId/students/$studentId/bundle';

  // ── Exams ───────────────────────────────────────────────────────────────
  static const String exams = '/exams';
  static const String examSubmissions = '/exam-submissions';

  static String examDetail(int id) => '$exams/$id';
  static String examSubmissionsOf(int id) => '$exams/$id/submissions';
  static String examSubmissionOf(int examId, int studentId) =>
      '$exams/$examId/submissions/$studentId';
  static String examSubmissionDetail(int id) => '$examSubmissions/$id';

  // ── Content / reference data ────────────────────────────────────────────
  static const String teamTypes = '/team-types';
  static const String teachers = '/teachers';
  static const String teacherCreate = '/teachers';
  static const String teacherCandidates = '/teachers/candidates';
  static const String teams = '/teams';
  static const String subjects = '/subjects';
  static const String matns = '/matns';
  static const String matn = '/matn';
  static const String distributables = '/distributables';
  static const String distributions = '/distributions';
  static const String tajweedNotes = '/tajweed-notes';
  static const String tajweedRatings = '/tajweed-ratings';
  static const String matnRecitations = '/matn-recitations';
  static const String quranPageUnits = '/quran/page-units';

  static String teamType(int id) => '$teamTypes/$id';
  static String teacherDetail(int id) => '$teachers/$id';
  static String teacherNotes(int id) => '$teachers/$id/notes';
  static String teacherNote(int id, int noteId) =>
      '$teachers/$id/notes/$noteId';
  static String teamDetail(int id) => '$teams/$id';
  static String teamStudents(int id) => '$teams/$id/students';
  static String teamTeacher(int id) => '$teams/$id/teacher';
  static String subjectDetail(int id) => '$subjects/$id';
  static String matnDetail(int id) => '$matn/$id';
  static String matnRecitationDetail(int id) => '$matnRecitations/$id';
  static String distributableDetail(int id) => '$distributables/$id';
  static String distributionDetail(int id) => '$distributions/$id';
  static String tajweedNote(int id) => '$tajweedNotes/$id';
  static String tajweedRating(int id) => '$tajweedRatings/$id';

  // ── Records (update/delete by id) ───────────────────────────────────────
  static const String certificates = '/certificates';
  static const String memorizations = '/memorizations';
  static const String recitations = '/recitations';
  static const String recitationTests = '/recitation-tests';
  static const String transactions = '/transactions';

  static String certificate(int id) => '$certificates/$id';
  static String memorization(int id) => '$memorizations/$id';
  static String recitation(int id) => '$recitations/$id';
  static String recitationTest(int id) => '$recitationTests/$id';
  static String transaction(int id) => '$transactions/$id';

  // ── Change requests ─────────────────────────────────────────────────────
  static const String changeRequests = '/change-requests';

  static String changeRequest(int id) => '$changeRequests/$id';

  // ── Reports ─────────────────────────────────────────────────────────────
  static const String reports = '/reports';
  static const String reportsCustom = '/reports/custom';
  static const String reportsTasmiSheets = '/reports/tasmi-sheets';
  static const String reportsAbsence = '/reports/absence';
  static const String reportsExport = '/reports/export';

  static String reportSession(int id) => '$reports/session/$id';
  static String reportSessionBreakdown(int id) =>
      '$reports/session/$id/attendance-breakdown';
  static String reportCourseAttendance(int id) =>
      '$reports/course/$id/attendance';
  static String reportCoursePointsRanking(int id) =>
      '$reports/course/$id/points-ranking';
  static String reportCourseTotal(int id) => '$reports/course/$id/total';
  static String reportStudentAttendance(int id) =>
      '$reports/student/$id/attendance';
  static String reportStudentPoints(int id) => '$reports/student/$id/points';
  static String reportMatn(int id) => '$reports/matn/$id';
  static String reportQuranGrid(int id) => '$reports/quran-grid/$id';
  static String reportExport(String key) => '$reportsExport/$key';

  // ── Messages ────────────────────────────────────────────────────────────
  static const String messages = '/messages';

  static String messageSession(int id) => '$messages/session/$id';
  static String messageSessionExport(int id) => '$messages/session/$id/export';
  static String messageCourse(int id) => '$messages/course/$id';
  static String messageCourseExport(int id) => '$messages/course/$id/export';

  // ── Exports / imports ───────────────────────────────────────────────────
  static const String exports = '/exports';
  static const String exportsFull = '/exports/full';
  static const String imports = '/imports';
  static const String importsUpload = '/imports/upload';

  static String exportDetail(int id) => '$exports/$id';
  static String exportDownload(int id) => '$exports/$id/download';
  static String importDetail(int id) => '$imports/$id';
  static String importMapping(int id) => '$imports/$id/mapping';
  static String importValidate(int id) => '$imports/$id/validate';
  static String importCommit(int id) => '$imports/$id/commit';
  static String importErrors(int id) => '$imports/$id/errors';

  // ── Admin ───────────────────────────────────────────────────────────────
  static const String adminOverview = '/admin/overview';
  static const String adminContentSummary = '/admin/content-summary';
  static const String adminUsers = '/admin/users';
  static const String adminUsersBulk = '/admin/users/bulk';
  static const String adminAudit = '/admin/audit';
  static const String adminNotifications = '/admin/notifications';
  static const String adminNotificationsRead = '/admin/notifications/read';
  static const String adminNotificationsUndo = '/admin/notifications/undo';
  static const String adminNotificationsUnread =
      '/admin/notifications/unread-count';
  static const String adminImports = '/admin/imports';

  static String adminUser(int id) => '$adminUsers/$id';
  static String adminUserActivate(int id) => '$adminUsers/$id/activate';
  static String adminUserDeactivate(int id) => '$adminUsers/$id/deactivate';
  static String adminUserResetPassword(int id) =>
      '$adminUsers/$id/reset-password';
  static String adminPermissions(int userId) => '/admin/permissions/$userId';
  static String adminUserPermissions(int userId) =>
      '$adminUsers/$userId/permissions';
  static String adminAuditRestore(int logId) => '$adminAudit/$logId/restore';

  // ── Mosque / kiosk / sync ───────────────────────────────────────────────
  static const String mosque = '/mosque';
  static const String mosqueDeletion = '/mosque/deletion';
  static const String mosqueDeletionMessage = '/mosque/deletion-message';
  static const String mosqueDeletionState = '/mosque/deletion-state';
  static const String kioskLock = '/kiosk/lock';
  static const String kioskUnlock = '/kiosk/unlock';
  static const String syncUpload = '/sync/upload';
  static const String syncLog = '/sync/log';

  // ── Platform (separate guard) ───────────────────────────────────────────
  static const String platformLogin = '/platform/auth/login';
  static const String platformRefresh = '/platform/auth/refresh';
  static const String platformLogout = '/platform/auth/logout';
  static const String platformApplications = '/platform/applications';
  static const String platformMosques = '/platform/mosques';
  static const String platformPolicies = '/platform/policies';
  static const String platformAudit = '/platform/audit';

  static String platformApplication(int id) => '$platformApplications/$id';
  static String platformMosque(int id) => '$platformMosques/$id';
  static String platformMosqueDeletion(int id) =>
      '$platformMosques/$id/deletion';
  static String platformMosqueExecuteDeletion(int id) =>
      '$platformMosques/$id/execute-deletion';
  static String platformAdminResetPassword(int id) =>
      '/platform/admins/$id/reset-password';
  static String platformPolicy(int id) => '$platformPolicies/$id';
}
