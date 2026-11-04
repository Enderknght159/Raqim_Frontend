import '../../admin/data/admin_repository.dart';
import '../../admin/domain/admin_models.dart';
import '../domain/teacher_models.dart';

/// Loads the teacher's students and merges each student with the teams (and
/// type switches) that grant record writes. The server already scopes
/// [AdminRepository.teams] to the teacher's teams.
class TeacherRosterService {
  const TeacherRosterService(this.repository);

  final AdminRepository repository;

  Future<List<TeacherRosterEntry>> load() async {
    final teams = await repository.teams();
    final byStudent = <int, TeacherRosterEntry>{};

    for (final team in teams) {
      final students = await repository.teamStudents(team.id);
      for (final student in students) {
        final entry = byStudent.putIfAbsent(
          student.id,
          () => TeacherRosterEntry(student: student),
        );
        if (!entry.teams.any((existing) => existing.id == team.id)) {
          entry.teams.add(team);
        }
      }
    }

    final roster = byStudent.values.toList()
      ..sort((a, b) => a.student.name.compareTo(b.student.name));
    return roster;
  }

  Future<List<AdminCourseSummary>> courses() => repository.courses();

  Future<List<AdminSessionRow>> sessions(int courseId) =>
      repository.courseSessions(courseId);
}
