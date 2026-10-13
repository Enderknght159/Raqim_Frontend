/// App roles, mirroring the backend role model.
enum AppRole {
  admin('admin', 'مشرف عام'),
  supervisor('supervisor', 'مشرف'),
  teacher('teacher', 'مدرس'),
  student('student', 'طالب'),
  parent('parent', 'ولي أمر');

  const AppRole(this.value, this.arabicName);

  final String value;
  final String arabicName;

  static AppRole fromValue(String? value) {
    return AppRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => AppRole.student,
    );
  }
}

/// App section names returned by `/me/` and used to build the nav.
enum AppSection {
  // Student (B1–B5) tabs.
  myCourses('my_courses'),
  quran('quran'),
  achievement('achievement'),
  teams('teams'),
  profile('profile'),

  // Supervisor / teacher sections.
  myProgress('my_progress'),
  courses('courses'),
  students('students'),
  more('more'),
  admin('admin');

  const AppSection(this.value);

  final String value;

  static AppSection fromValue(String? value) {
    return AppSection.values.firstWhere(
      (s) => s.value == value,
      orElse: () => AppSection.more,
    );
  }
}