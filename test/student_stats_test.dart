import 'package:flutter_test/flutter_test.dart';
import 'package:raqim/features/student/domain/models/student_models.dart';
import 'package:raqim/features/student/domain/student_stats.dart';

Course _courseAt(DateTime start, DateTime end) => Course(
      id: 1,
      name: 'دور',
      startDate: start,
      endDate: end,
      goodPoints: 1,
      veryGoodPoints: 2,
      excellentPoints: 3,
      certificatePoints: 10,
    );

void main() {
  test('computePoints: attendance category + memorization latest-wins + balances',
      () {
    final now = DateTime(2026, 1, 15, 16);
    final course = _courseAt(now.subtract(const Duration(days: 30)), now.add(const Duration(days: 30)));

    final sessions = [
      Session(
        id: 1,
        courseId: 1,
        date: now,
        earlyPoints: 3,
        midPoints: 2,
        latePoints: 1,
        earlyUntil: '16:00',
        lateFrom: '16:30',
        orderInCourse: 1,
      ),
      Session(
        id: 2,
        courseId: 1,
        date: now,
        earlyPoints: 3,
        midPoints: 2,
        latePoints: 1,
        earlyUntil: '16:00',
        lateFrom: '16:30',
        orderInCourse: 2,
      ),
    ];

    // Session 1 early (15:45), session 2 absent.
    final attendance = [
      AttendanceRecord(
          sessionId: 1, arrivalTime: DateTime(2026, 1, 15, 15, 45)),
      AttendanceRecord(sessionId: 2, arrivalTime: null),
    ];

    // Same page/unit memorized twice — latest rating (3) wins → 3 points.
    final memorizations = [
      Memorization(
        sessionId: 1,
        page: 600,
        partIndex: 1,
        parts: 1,
        surah: 'عم',
        rating: 1,
        reciterName: 'قارئ',
        date: DateTime(2026, 1, 10),
      ),
      Memorization(
        sessionId: 2,
        page: 600,
        partIndex: 1,
        parts: 1,
        surah: 'عم',
        rating: 3,
        reciterName: 'قارئ',
        date: DateTime(2026, 1, 12),
      ),
    ];

    final transactions = [
      StudentTransaction(
        sessionId: 1,
        type: TransactionType.reward,
        pointsValue: 5,
        date: now,
      ),
      StudentTransaction(
        sessionId: 1,
        type: TransactionType.purchase,
        pointsValue: 4,
        date: now,
      ),
    ];

    final result = computePoints(
      course: course,
      sessions: sessions,
      attendance: attendance,
      memorizations: memorizations,
      exams: const [],
      examSubmissions: const [],
      certificates: const [],
      matns: const [],
      matnRecitations: const [],
      transactions: transactions,
    );

    expect(result.attendance, 3); // early session
    expect(result.memorization, 3); // latest rating wins (not additive, not max of both)
    expect(result.reward, 5);
    expect(result.purchase, 4);
    // total = 3 + 3 + 5 = 11 (purchase ignored in total)
    expect(result.total, 11);
    // purchase balance = 3 + 3 + 5 - 4 = 7
    expect(result.purchaseBalance, 7);
  });

  test('attendance summary counts categories + percentage', () {
    final sessions = [
      for (var i = 1; i <= 4; i++)
        Session(
          id: i,
          courseId: 1,
          date: DateTime(2026, 1, 15),
          earlyPoints: 1,
          midPoints: 1,
          latePoints: 1,
          earlyUntil: '16:00',
          lateFrom: '16:30',
          orderInCourse: i,
        ),
    ];
    final attendance = [
      AttendanceRecord(
          sessionId: 1, arrivalTime: DateTime(2026, 1, 15, 15, 30)),
      AttendanceRecord(
          sessionId: 2, arrivalTime: DateTime(2026, 1, 15, 16, 15)),
      AttendanceRecord(
          sessionId: 3, arrivalTime: DateTime(2026, 1, 15, 16, 45)),
      // session 4 → absent
    ];
    final summary = computeAttendanceSummary(
        sessions: sessions, attendance: attendance);
    expect(summary.early, 1);
    expect(summary.onTime, 1);
    expect(summary.late, 1);
    expect(summary.absent, 1);
    expect(summary.attended, 3);
    expect(summary.percentage, 75);
  });
}