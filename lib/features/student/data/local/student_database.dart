import 'package:drift/drift.dart';

import 'student_database_connection.dart'
    if (dart.library.io) 'student_database_connection_native.dart'
    if (dart.library.js_interop) 'student_database_connection_web.dart';

part 'student_database.g.dart';

// ── Tables (mirroring `erd.json` v0.4, student-relevant subset) ─────────────

class Courses extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  IntColumn get goodPoints => integer().withDefault(const Constant(1))();
  IntColumn get veryGoodPoints => integer().withDefault(const Constant(2))();
  IntColumn get excellentPoints => integer().withDefault(const Constant(3))();
  IntColumn get certificatePoints =>
      integer().withDefault(const Constant(10))();

  @override
  Set<Column> get primaryKey => {id};
}

class Sessions extends Table {
  IntColumn get id => integer()();
  IntColumn get courseId => integer()();
  DateTimeColumn get date => dateTime()();
  IntColumn get earlyPoints => integer().withDefault(const Constant(3))();
  IntColumn get midPoints => integer().withDefault(const Constant(2))();
  IntColumn get latePoints => integer().withDefault(const Constant(1))();
  TextColumn get earlyUntil => text().withDefault(const Constant('16:00'))();
  TextColumn get lateFrom => text().withDefault(const Constant('16:30'))();
  IntColumn get orderInCourse => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

class Attendances extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get sessionId => integer()();
  DateTimeColumn get arrivalTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Memorizations extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get sessionId => integer()();
  IntColumn get page => integer()();
  IntColumn get partIndex => integer().withDefault(const Constant(1))();
  IntColumn get parts => integer().withDefault(const Constant(1))();
  TextColumn get surah => text().withDefault(const Constant(''))();
  IntColumn get rating => integer()(); // 1..3
  TextColumn get reciterName => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get sessionId => integer()();
  TextColumn get type =>
      text()(); // reward|penalty|purchase|collection|incomeExpense
  IntColumn get pointsValue => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Certificates extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get courseId => integer()();
  IntColumn get startJuz => integer()();
  IntColumn get endJuz => integer()();
  IntColumn get mark => integer()();
  BoolColumn get byHeart => boolean().withDefault(const Constant(true))();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Exams extends Table {
  IntColumn get id => integer()();
  IntColumn get courseId => integer()();
  TextColumn get subjectName => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()(); // oral|writtenProbe|final
  IntColumn get maxMark => integer()();
  IntColumn get minSuccessMark => integer()();
  IntColumn get points => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class ExamSubmissions extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get examId => integer()();
  RealColumn get mark => real()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Teams extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get typeName => text()();
  TextColumn get teacherName => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class StudentTeams extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get teamId => integer()();
  DateTimeColumn get date => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Students extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get fatherName => text().nullable()();
  IntColumn get yearOfBirth => integer().nullable()();
  TextColumn get barcode => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Phones extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  TextColumn get phone => text()();
  TextColumn get type => text()(); // parent|student|landline

  @override
  Set<Column> get primaryKey => {id};
}

class Matns extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get pointsPerVerse => integer()();
  IntColumn get totalVerses => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class MatnRecitations extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get matnId => integer()();
  IntColumn get lastVerse => integer()();
  TextColumn get teacherName => text().withDefault(const Constant(''))();
  IntColumn get sessionId => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Key/value app metadata (seed marker, active account, etc.).
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// In-app notices sent by the administration (e.g. absence notices for a
/// session). `studentId = 0` broadcasts to all students.
class StudentNotices extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  TextColumn get kind => text()(); // absence|general
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Admin-centric tables (E6–E14) ───────────────────────────────────────────

class TeamTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Subjects extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get book => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Distributables extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get note => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Distributions extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  IntColumn get distributableId => integer()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChangeRequests extends Table {
  IntColumn get id => integer()();
  IntColumn get studentId => integer()();
  TextColumn get field => text()(); // name|fatherName|yearOfBirth|phoneNumber
  TextColumn get currentValue => text().nullable()();
  TextColumn get requestedValue => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get reviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Courses,
    Sessions,
    Attendances,
    Memorizations,
    Transactions,
    Certificates,
    Exams,
    ExamSubmissions,
    Teams,
    StudentTeams,
    Students,
    Phones,
    Matns,
    MatnRecitations,
    AppMeta,
    StudentNotices,
    TeamTypes,
    Subjects,
    Distributables,
    Distributions,
    ChangeRequests,
  ],
)
class StudentDatabase extends _$StudentDatabase {
  StudentDatabase() : super(openStudentDatabaseConnection());

  StudentDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // SQLite can't ADD COLUMN with a volatile default, so the column
        // is added nullable and existing rows are backfilled.
        await m.addColumn(studentTeams, studentTeams.date);
        await customStatement(
          "UPDATE student_teams SET date = datetime('now') "
          'WHERE date IS NULL',
        );
      }
      if (from < 3) {
        await m.createTable(teamTypes);
        await m.createTable(subjects);
        await m.createTable(distributables);
        await m.createTable(distributions);
        await m.createTable(changeRequests);
      }
      if (from < 4) {
        await m.createTable(studentNotices);
      }
    },
  );
}
