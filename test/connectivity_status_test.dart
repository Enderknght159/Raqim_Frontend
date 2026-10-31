import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/network/api_client.dart';
import 'package:raqim/core/network/connectivity_status.dart';
import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/core/widgets/connectivity_banner.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  group('ConnectivityStatus hysteresis', () {
    late ConnectivityStatus status;

    setUp(() {
      status = ConnectivityStatus.forTest(
        failureThreshold: 3,
        failureWindow: const Duration(seconds: 8),
        offlineAfter: const Duration(milliseconds: 50),
      );
    });

    tearDown(() => status.reset());

    test('a single failure then success keeps the app online', () async {
      status.markOffline();
      status.markOnline();

      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(status.online.value, isTrue);
      expect(status.hasPendingTimer, isFalse);
      expect(status.pendingFailureCount, 0);
    });

    test('three failures within the window flip offline immediately', () {
      status.markOffline();
      status.markOffline();
      status.markOffline();

      expect(status.online.value, isFalse);
    });

    test('a success after offline restores online', () {
      status.markOffline();
      status.markOffline();
      status.markOffline();
      expect(status.online.value, isFalse);

      status.markOnline();

      expect(status.online.value, isTrue);
    });

    test(
      'a sustained single failure flips offline after the grace period',
      () async {
        status.markOffline();
        expect(status.online.value, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 120));

        expect(status.online.value, isFalse);
      },
    );

    test('failures outside the window are discarded', () {
      var now = DateTime(2026, 1, 1, 12);
      final windowed = ConnectivityStatus.forTest(
        failureWindow: const Duration(seconds: 8),
        offlineAfter: const Duration(seconds: 30),
        clock: () => now,
      );

      windowed.markOffline();
      now = now.add(const Duration(seconds: 5));
      windowed.markOffline();
      now = now.add(const Duration(seconds: 4));
      windowed.markOffline();

      expect(windowed.pendingFailureCount, 2);
      expect(windowed.online.value, isTrue);
      windowed.reset();
    });
  });

  group('Connectivity error classification', () {
    final options = RequestOptions(path: '/x');

    test('timeouts and connection errors are connectivity failures', () {
      for (final type in const [
        DioExceptionType.connectionTimeout,
        DioExceptionType.connectionError,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          isConnectivityFailure(
            DioException(requestOptions: options, type: type),
          ),
          isTrue,
          reason: '$type',
        );
      }
    });

    test('cancellations and HTTP responses are not connectivity failures', () {
      expect(
        isConnectivityFailure(
          DioException(requestOptions: options, type: DioExceptionType.cancel),
        ),
        isFalse,
      );
      for (final code in const [401, 403, 404, 422, 500]) {
        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: code,
          ),
        );
        expect(isConnectivityFailure(error), isFalse, reason: 'HTTP $code');
      }
    });
  });

  group('Connectivity interceptor (single source of truth)', () {
    test('a 500 response does not change the status', () async {
      final status = ConnectivityStatus.forTest(
        offlineAfter: const Duration(milliseconds: 10),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.httpClientAdapter = _FakeAdapter((options) async {
        return ResponseBody.fromString(
          '{"code":"ERR"}',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      dio.interceptors.add(
        ApiClient.createConnectivityInterceptor(status: status),
      );

      await expectLater(dio.get<dynamic>('/x'), throwsA(isA<DioException>()));
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(status.online.value, isTrue);
      expect(status.pendingFailureCount, 0);
      status.reset();
    });

    test('a connection timeout is recorded as a failure', () async {
      final status = ConnectivityStatus.forTest(
        offlineAfter: const Duration(milliseconds: 10),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.httpClientAdapter = _FakeAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });
      dio.interceptors.add(
        ApiClient.createConnectivityInterceptor(status: status),
      );

      await expectLater(dio.get<dynamic>('/x'), throwsA(isA<DioException>()));
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(status.online.value, isFalse);
      status.reset();
    });
  });

  group('ConnectivityBanner', () {
    testWidgets('stays hidden while online', (tester) async {
      final status = ConnectivityStatus.forTest(
        offlineAfter: const Duration(milliseconds: 10),
      );
      await tester.pumpWidget(_wrap(ConnectivityBanner(status: status)));

      expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
      status.reset();
    });

    testWidgets(
      'appears after a sustained offline signal and hides on recovery',
      (tester) async {
        final status = ConnectivityStatus.forTest(
          offlineAfter: const Duration(milliseconds: 10),
        );
        await tester.pumpWidget(_wrap(ConnectivityBanner(status: status)));

        status.markOffline();
        await tester.pump(const Duration(milliseconds: 20));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

        status.markOnline();
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
        status.reset();
      },
    );
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}
