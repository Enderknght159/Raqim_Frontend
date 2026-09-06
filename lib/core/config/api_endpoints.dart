/// Central place for API endpoint paths, relative to [AppConfig.apiBaseUrl].
abstract class ApiEndpoints {
  static const String login = '/auth/login/';
  static const String refresh = '/auth/refresh/';
  static const String logout = '/auth/logout/';
  static const String me = '/me/';

  static const String courses = '/courses/';
  static const String teams = '/teams/';
  static const String teachers = '/teachers/';
  static const String students = '/students/';
  static const String sessions = '/sessions/';
  static const String attendance = '/attendance/';
  static const String exams = '/exams/';
  static const String books = '/books/';
  static const String distributions = '/distributions/';
  static const String imports = '/imports/';
  static const String exports = '/exports/';

  static const String adminPermissions = '/admin/permissions/';
  static const String adminAudit = '/admin/audit/';
  static const String adminDashboard = '/admin/dashboard/';

  static String studentDetail(int id) => '$students$id/';
  static String studentRecitations(int id) => '$students$id/recitations/';
  static String studentMemorizations(int id) => '$students$id/memorizations/';
  static String studentTajweed(int id) => '$students$id/tajweed/';
  static String studentTransactions(int id) => '$students$id/transactions/';
  static String studentPointsBalance(int id) => '$students$id/points/balance';
  static String sessionAttendance(int id) => '$sessions$id/attendance/';
  static String courseSessions(int id) => '$courses$id/sessions/';
  static String examSubmissions(int id) => '$exams$id/submissions/';
}