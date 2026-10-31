/// A saved account session. Tokens are kept so switching accounts does not
/// require logging out the current one.
class StoredAccount {
  const StoredAccount({
    required this.userId,
    required this.username,
    required this.name,
    required this.role,
    required this.access,
    required this.refresh,
    required this.profileJson,
    this.mosqueName,
    this.mosqueCode,
  });

  final int userId;
  final String username;
  final String name;
  final String role;
  final String access;
  final String refresh;
  final Map<String, dynamic> profileJson;
  final String? mosqueName;
  final String? mosqueCode;

  String get displayName => name.trim().isEmpty ? username : name;

  String get mosqueLabel {
    final name = mosqueName?.trim() ?? '';
    final code = mosqueCode?.trim() ?? '';
    if (name.isEmpty && code.isEmpty) return '';
    if (code.isEmpty) return name;
    if (name.isEmpty) return code;
    return '$name · $code';
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'name': name,
    'role': role,
    'access': access,
    'refresh': refresh,
    'profileJson': profileJson,
    'mosqueName': mosqueName,
    'mosqueCode': mosqueCode,
  };

  factory StoredAccount.fromJson(Map<String, dynamic> json) => StoredAccount(
    userId: json['userId'] as int? ?? 0,
    username: json['username'] as String? ?? '',
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? 'student',
    access: json['access'] as String? ?? '',
    refresh: json['refresh'] as String? ?? '',
    profileJson: json['profileJson'] is Map
        ? Map<String, dynamic>.from(json['profileJson'] as Map)
        : const <String, dynamic>{},
    mosqueName: json['mosqueName'] as String?,
    mosqueCode: json['mosqueCode'] as String?,
  );
}
