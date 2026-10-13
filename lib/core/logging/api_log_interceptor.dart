import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'app_logger.dart';

/// Dio interceptor that logs every API request, response and error with
/// timing and (optionally) bodies — with sensitive values redacted.
///
/// Redaction: values under keys like `password`, `token`, `access`, `refresh`,
/// `authorization` are replaced with `[REDACTED]`.
class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({
    bool? logBodies,
    AppLogger? logger,
  })  : _logBodies = logBodies ?? AppConfig.logApiBodies,
        _logger = logger ?? AppLogger.forTag('API');

  static const _startTimeKey = 'log_started_at';

  final bool _logBodies;
  final AppLogger _logger;

  static const _sensitiveKeys = {
    'password',
    'pin',
    'secret',
    'token',
    'access',
    'refresh',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now();
    final headerPart = _headersLine(options.headers);
    _logger.debug(
      '→ ${options.method} ${options.uri}$headerPart',
    );
    if (_logBodies && options.data != null) {
      _logger.debug('  body: ${_redactBody(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final ms = _elapsed(response.requestOptions);
    final uri = response.requestOptions.uri;
    final status = response.statusCode;
    _logger.debug('← $status ${response.requestOptions.method} $uri ($ms ms)');
    if (_logBodies && response.data != null) {
      _logger.debug('  body: ${_redactBody(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ms = _elapsed(err.requestOptions);
    final uri = err.requestOptions.uri;
    final status = err.response?.statusCode;
    _logger.error(
      '✗ ${status ?? '-'} ${err.requestOptions.method} $uri ($ms ms) '
      '${err.type.name}',
      error: err.message,
    );
    if (_logBodies && err.response?.data != null) {
      _logger.debug('  body: ${_redactBody(err.response!.data)}');
    }
    handler.next(err);
  }

  String _headersLine(Map<String, dynamic> headers) {
    if (headers.isEmpty) return '';
    final buffer = StringBuffer(' headers={');
    var first = true;
    headers.forEach((key, value) {
      if (!first) buffer.write(', ');
      first = false;
      final isSensitive = key.toLowerCase().contains('authorization');
      buffer.write('$key=${isSensitive ? '[REDACTED]' : value}');
    });
    buffer.write('}');
    return buffer.toString();
  }

  int _elapsed(RequestOptions options) {
    final start = options.extra[_startTimeKey] as DateTime?;
    if (start == null) return 0;
    return DateTime.now().difference(start).inMilliseconds;
  }

  /// Redacts sensitive keys recursively in maps/lists; falls back to the raw
  /// string for non-JSON bodies. `null` values are kept as-is (a backend
  /// may return `"field": null` — e.g. `student: null` in the login payload).
  Object? _redactBody(Object? data) {
    if (data == null) return null;
    if (data is Map) return _redactMap(data);
    if (data is List) {
      return data.map((item) => _redactBody(item)).toList();
    }
    if (data is String) return _redactJsonString(data);
    return data;
  }

  Map<String, dynamic> _redactMap(Map data) {
    return data.map((key, value) {
      final isSensitive = _sensitiveKeys.contains(key.toString().toLowerCase());
      return MapEntry(
        key.toString(),
        isSensitive ? '[REDACTED]' : _redactBody(value),
      );
    });
  }

  String _redactJsonString(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return raw;
    try {
      final decoded = jsonDecode(trimmed);
      return jsonEncode(_redactBody(decoded));
    } on FormatException {
      return raw;
    }
  }
}