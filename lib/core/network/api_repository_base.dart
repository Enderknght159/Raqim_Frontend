import 'package:dio/dio.dart';

import '../storage/cache_store.dart';
import 'api_exception.dart';

/// Thin, typed wrapper around [Dio] used by the API repositories.
///
/// It normalises paginated (`{results: [...]}`) and plain-list responses, and
/// rethrows the [ApiException] produced by [ApiClient]'s error interceptor.
///
/// Successful GETs are cached in the local drift database. When the network
/// is unavailable the same GET returns the last cached payload (read-only
/// fallback); writes still fail with a network error.
class ApiRepositoryBase {
  ApiRepositoryBase(this.dio, {this.cache});

  final Dio dio;
  final CacheStore? cache;

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final key = _cacheKey(path, query);
    try {
      final response = await dio.get<dynamic>(path, queryParameters: query);
      final data = _asMap(response.data);
      await cache?.writeJson(key, data, entityType: 'map');
      return data;
    } on DioException catch (e) {
      final mapped = _mapError(e);
      if (_isNetwork(e) || mapped.isNetwork) {
        final cached = await cache?.readJson(key);
        if (cached is Map) return _asMap(cached);
      }
      throw mapped;
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final key = _cacheKey(path, query);
    try {
      final response = await dio.get<dynamic>(path, queryParameters: query);
      final data = _asList(response.data);
      await cache?.writeJson(key, data, entityType: 'list');
      return data;
    } on DioException catch (e) {
      final mapped = _mapError(e);
      if (_isNetwork(e) || mapped.isNetwork) {
        final cached = await cache?.readJson(key);
        if (cached is List) return cached;
      }
      throw mapped;
    }
  }

  /// Fetches every page of a paginated endpoint (Laravel `{results, next}`)
  /// or a plain list.
  Future<List<Map<String, dynamic>>> getAllPages(
    String path, {
    Map<String, dynamic>? query,
    int pageSize = 500,
  }) async {
    final key = _cacheKey('all:$path', {...?query, 'page_size': pageSize});
    final out = <Map<String, dynamic>>[];
    String? next = path;
    var first = true;
    try {
      while (next != null && next.isNotEmpty) {
        final response = await dio.get<dynamic>(
          next,
          queryParameters: first
              ? <String, dynamic>{...?query, 'page_size': pageSize}
              : null,
        );
        final data = response.data;
        if (data is Map) {
          final results = data['results'];
          if (results is List) {
            out.addAll(
              results.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
            );
          }
          final candidate = data['next'];
          next = candidate is String && candidate.isNotEmpty ? candidate : null;
        } else if (data is List) {
          out.addAll(
            data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
          );
          next = null;
        } else {
          next = null;
        }
        first = false;
      }
      await cache?.writeJson(key, out, entityType: 'list');
      return out;
    } on DioException catch (e) {
      final mapped = _mapError(e);
      if (_isNetwork(e) || mapped.isNetwork) {
        final cached = await cache?.readJson(key);
        if (cached is List) {
          return cached
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
      throw mapped;
    }
  }

  /// Reads a previously cached map without touching the network.
  Future<Map<String, dynamic>?> cachedMap(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final cached = await cache?.readJson(_cacheKey(path, query));
    return cached is Map ? _asMap(cached) : null;
  }

  /// Reads a previously cached list without touching the network.
  Future<List<dynamic>?> cachedList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final cached = await cache?.readJson(_cacheKey(path, query));
    return cached is List ? cached : null;
  }

  /// Reads a previously cached aggregated list (getAllPages key).
  Future<List<Map<String, dynamic>>?> cachedAllPages(
    String path, {
    Map<String, dynamic>? query,
    int pageSize = 500,
  }) async {
    final cached = await cache?.readJson(
      _cacheKey('all:$path', {...?query, 'page_size': pageSize}),
    );
    if (cached is! List) return null;
    return cached
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<dynamic>> postList(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
      );
      return _asList(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Some endpoints return an object for one item and a list for many.
  Future<dynamic> postDynamic(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patchMap(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: query,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> putMap(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.put<dynamic>(
        path,
        data: data,
        queryParameters: query,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> patchVoid(String path, {Object? data}) async {
    try {
      await dio.patch<dynamic>(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteVoid(String path, {Object? data}) async {
    try {
      await dio.delete<dynamic>(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  String _cacheKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return path;
    final keys = query.keys.toList()..sort();
    final suffix = keys.map((key) => '$key=${query[key]}').join('&');
    return '$path?$suffix';
  }

  bool _isNetwork(DioException error) =>
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout;

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }
    if (data is Map && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    return const <dynamic>[];
  }

  ApiException _mapError(DioException error) {
    final mapped = error.error;
    if (mapped is ApiException) return mapped;
    return ApiException.server(statusCode: error.response?.statusCode);
  }
}
