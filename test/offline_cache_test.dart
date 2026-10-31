import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raqim/core/network/api_repository_base.dart';
import 'package:raqim/core/storage/app_database.dart';
import 'package:raqim/core/storage/cache_store.dart';
import 'package:raqim/features/auth/data/auth_remote_data_source.dart';

class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter(this.responses);

  final List<Object?> responses;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = calls++;
    if (index >= responses.length) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(responses[index]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late AppDatabase db;
  late CacheStore cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = CacheStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('GET falls back to the cached payload when offline', () async {
    final adapter = _FlakyAdapter([
      {'value': 42, 'name': 'cached'},
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = adapter;
    final repo = ApiRepositoryBase(dio, cache: cache);

    final first = await repo.getMap('/sample');
    expect(first['value'], 42);

    final second = await repo.getMap('/sample');
    expect(second['value'], 42);
    expect(second['name'], 'cached');
    expect(adapter.calls, 2);
  });

  test('GET list falls back to the cached list when offline', () async {
    final adapter = _FlakyAdapter([
      [
        {'id': 1},
        {'id': 2},
      ],
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = adapter;
    final repo = ApiRepositoryBase(dio, cache: cache);

    expect((await repo.getList('/list')).length, 2);
    expect((await repo.getList('/list')).length, 2);
  });

  test('/me falls back to the cached profile when offline', () async {
    final adapter = _FlakyAdapter([
      {
        'id': 29,
        'username': 'aby-29',
        'role': 'student',
        'sections': ['student'],
        'student': {'id': 29},
        'mosque': {'name': 'مسجد أبي', 'code': 'aby'},
      },
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = adapter;
    final remote = AuthRemoteDataSource(dio: dio, cache: cache);

    final first = await remote.me();
    expect(first.id, 29);
    expect(first.studentId, 29);
    expect(first.mosqueName, 'مسجد أبي');

    final second = await remote.me();
    expect(second.id, 29);
    expect(second.studentId, 29);
  });
}
