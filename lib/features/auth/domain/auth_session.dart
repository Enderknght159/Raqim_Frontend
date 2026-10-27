import 'models/user_profile.dart';

/// Holds the profile of the currently signed-in account.
///
/// The API repositories read the student/teacher identity from here instead of
/// hardcoding the trial student `id = 1`.
class ApiSession {
  UserProfile? profile;

  bool get isAuthenticated => profile != null;

  int? get studentId => profile?.studentId;

  int? get teacherId => profile?.teacherId;

  bool get isAdmin => profile?.isAdmin ?? false;

  String get mosqueName => profile?.mosqueName ?? '';
}
