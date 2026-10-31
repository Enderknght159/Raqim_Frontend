import '../../student/domain/models/student_models.dart';
import '../../student/domain/student_stats.dart';

/// Read/write surface used by the student screens.
///
/// The local (drift) and API implementations both implement this interface, so
/// screens never depend on where the data comes from.
abstract class StudentRepository {
  Future<StudentProfileModel> profile();
  Future<String> mosqueName();
  Future<List<Course>> courses();
  Future<List<Team>> teams();
  Future<List<StudentBrief>> peersOfTeam(int teamId);
  Future<List<StudentLeaderboardEntry>> leaderboard(int courseId);
  Future<List<CourseOverview>> courseOverviews();
  Future<StudentCourseBundle> courseBundle(int courseId, {int? studentId});
  Future<List<Memorization>> allMemorizations();
  Future<List<Certificate>> certificates();
  Future<List<Matn>> matns();
  Future<List<MatnRecitation>> matnRecitations({int? studentId});
  Future<Map<int, MatnRecitation>> latestMatnRecitations();
  Future<List<({Exam exam, ExamSubmission? submission})>>
  examsWithSubmissions();
  Future<QuranStats> quranStats();
  Future<List<StudentNotification>> notifications();
  Future<void> markNotifRead();
  Future<int> unreadNotifications();

  /// Warms the read-only cache after a successful login (best-effort).
  Future<void> warmCache();

  // Cached reads for stale-while-revalidate.
  Future<StudentProfileModel?> cachedProfile();
  Future<List<CourseOverview>?> cachedCourseOverviews();
  Future<StudentCourseBundle?> cachedCourseBundle(int courseId);
  Future<List<StudentLeaderboardEntry>?> cachedLeaderboard(int courseId);
  Future<List<Memorization>?> cachedMemorizations();
  Future<List<Certificate>?> cachedCertificates();
  Future<QuranStats?> cachedQuranStats();
  Future<List<Matn>?> cachedMatns();
  Future<Map<int, MatnRecitation>?> cachedLatestMatnRecitations();
  Future<List<({Exam exam, ExamSubmission? submission})>?>
  cachedExamsWithSubmissions();
  Future<List<Team>?> cachedTeams();

  /// Submits a self-service data change request (B5/B9).
  Future<void> requestChange({
    required String field,
    required String requestedValue,
  });
}
