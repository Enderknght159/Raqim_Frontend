import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Thin, typed wrapper around [Dio] used by the API repositories.
///
/// It normalises paginated (`{results: [...]}`) and plain-list responses, and
/// rethrows the [ApiException] produced by [ApiClient]'s error interceptor.
class ApiRepositoryBase {
  ApiRepositoryBase(this.dio);

  final Dio dio;

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.get<dynamic>(path, queryParameters: query);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.get<dynamic>(path, queryParameters: query);
      return _asList(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Fetches every page of a paginated endpoint (Laravel `{results, next}`)
  /// or a plain list.
  Future<List<Map<String, dynamic>>> getAllPages(
    String path, {
    Map<String, dynamic>? query,
    int pageSize = 500,
  }) async {
    final out = <Map<String, dynamic>>[];
    String? next = path;
    var first = true;
    while (next != null && next.isNotEmpty) {
      try {
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
      } on DioException catch (e) {
        throw _mapError(e);
      }
      first = false;
    }
    return out;
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
