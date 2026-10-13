import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raqim/core/logging/api_log_interceptor.dart';
import 'package:raqim/core/logging/app_logger.dart';

void main() {
  final originalSink = AppLogger.outputSink;
  final originalEnabled = AppLogger.enabled;
  final originalLevel = AppLogger.minLevel;

  setUp(() {
    AppLogger.enabled = true;
    AppLogger.minLevel = AppLogLevel.verbose;
  });

  tearDown(() {
    AppLogger.outputSink = originalSink;
    AppLogger.enabled = originalEnabled;
    AppLogger.minLevel = originalLevel;
  });

  test('AppLogger respects minLevel filtering', () {
    final lines = <String>[];
    AppLogger.outputSink = lines.add;
    AppLogger.minLevel = AppLogLevel.warning;

    final log = AppLogger.forTag('Test');
    log.debug('hidden');
    log.info('hidden too');
    log.warning('visible warning');
    log.error('visible error');

    expect(lines, hasLength(2));
    expect(lines.first, contains('[WARN][Test]'));
    expect(lines.first, contains('visible warning'));
    expect(lines.last, contains('[ERROR][Test]'));
    expect(lines.last, contains('visible error'));
  });

  test('AppLogger respects master enabled flag', () {
    final lines = <String>[];
    AppLogger.outputSink = lines.add;
    AppLogger.enabled = false;

    AppLogger.forTag('Test').error('nothing should appear');

    expect(lines, isEmpty);
  });

  test('ApiLogInterceptor redacts password in body and Authorization header',
      () {
    final lines = <String>[];
    AppLogger.outputSink = lines.add;

    final interceptor = ApiLogInterceptor(logBodies: true);
    final options = RequestOptions(
      method: 'POST',
      path: '/auth/login',
      baseUrl: 'https://example.com',
      headers: {'Authorization': 'Bearer secret-token-xyz'},
      data: {'username': 'admin', 'password': 'super-secret'},
    );

    interceptor.onRequest(options, RequestInterceptorHandler());

    final requestLine = lines.firstWhere((l) => l.contains('POST'));
    expect(requestLine, isNot(contains('secret-token-xyz')));
    expect(requestLine, contains('[REDACTED]'));

    final bodyLine = lines.firstWhere((l) => l.contains('body:'));
    expect(bodyLine, isNot(contains('super-secret')));
    expect(bodyLine, contains('[REDACTED]'));
    expect(bodyLine, contains('admin')); // non-sensitive value kept
  });

  test('ApiLogInterceptor tolerates null values in a response (regression)',
      () {
    final lines = <String>[];
    AppLogger.outputSink = lines.add;

    final interceptor = ApiLogInterceptor(logBodies: true);
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(
        method: 'POST',
        path: '/auth/login',
        baseUrl: 'https://example.com',
        extra: {'log_started_at': DateTime.now()},
      ),
      statusCode: 200,
      data: {
        'access': '46|token',
        'refresh': '45|token',
        'user': {
          'id': 1,
          'username': 'admin',
          'isActive': true,
          'student': null, // ← must not crash the redactor
          'teacher': null,
        },
      },
    );

    // Must not throw despite null values (that used to surface as a
    // DioExceptionType.unknown wrapper even on HTTP 200).
    interceptor.onResponse(response, ResponseInterceptorHandler());

    expect(
      lines.any((l) => l.contains('body:') && l.contains('[REDACTED]')),
      isTrue,
    );
  });
}