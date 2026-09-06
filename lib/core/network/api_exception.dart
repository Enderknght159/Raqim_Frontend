/// Maps backend error codes to user-friendly Arabic/English messages.
///
/// The Django API is expected to return errors shaped like:
/// ```json
/// { "code": "INVALID_CREDENTIALS", "message": { "ar": "...", "en": "..." }, "field": "password" }
/// ```
class ApiException implements Exception {
  const ApiException({
    this.code,
    this.messageAr,
    this.messageEn,
    this.field,
    this.statusCode,
  });

  const ApiException.network()
      : code = 'NETWORK',
        messageAr = 'تعذر الاتصال بالخادم',
        messageEn = 'Could not connect to the server',
        field = null,
        statusCode = null;

  const ApiException.unauthorized()
      : code = 'UNAUTHORIZED',
        messageAr = 'انتهت صلاحية الجلسة',
        messageEn = 'Your session has expired',
        field = null,
        statusCode = 401;

  const ApiException.server({this.statusCode})
      : code = 'SERVER',
        messageAr = 'حدث خطأ في الخادم',
        messageEn = 'A server error occurred',
        field = null;

  /// Machine-readable error code, e.g. `INVALID_CREDENTIALS`.
  final String? code;

  /// Arabic user-facing message.
  final String? messageAr;

  /// English user-facing message.
  final String? messageEn;

  /// Related form field, when the error is field-specific.
  final String? field;

  /// HTTP status code, when applicable.
  final int? statusCode;

  /// Message for the active locale (Arabic first).
  String message({bool arabic = true}) => arabic ? (messageAr ?? messageEn ?? '') : (messageEn ?? messageAr ?? '');

  bool get isNetwork => code == 'NETWORK';
  bool get isUnauthorized => code == 'UNAUTHORIZED' || statusCode == 401;
  bool get isForbidden => statusCode == 403;

  @override
  String toString() =>
      'ApiException($code, $statusCode, ${field ?? ''}): ${messageAr ?? messageEn}';
}