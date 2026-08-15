import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static const _storage = FlutterSecureStorage();

  static const String _keyToken = 'parent_session_token';
  static const String _keyEnrollment = 'parent_enrollment';
  static const String _keyMobile = 'parent_mobile';
  static const String _keyRole = 'active_user_role';
  static const String _keyExpiresAt = 'session_expires_at';

  static Future<void> saveSession({
    required String sessionToken,
    required String enrollmentNo,
    required String mobileNo,
    String role = 'student',
    int durationMinutes = 60 * 24 * 7, // 7 days
  }) async {
    final expiresAt = DateTime.now().add(Duration(minutes: durationMinutes)).toIso8601String();
    await _storage.write(key: _keyToken, value: sessionToken);
    await _storage.write(key: _keyEnrollment, value: enrollmentNo);
    await _storage.write(key: _keyMobile, value: mobileNo);
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyExpiresAt, value: expiresAt);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: _keyRole, value: role);
  }

  static Future<String> getRole() async {
    return (await _storage.read(key: _keyRole)) ?? 'student';
  }

  static Future<bool> isSessionValid() async {
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    if (expiresAtStr == null) return false;
    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  static Future<String?> getSessionToken() async {
    if (!await isSessionValid()) return null;
    return await _storage.read(key: _keyToken);
  }

  static Future<String?> getEnrollmentNo() async {
    return await _storage.read(key: _keyEnrollment);
  }

  static Future<String?> getMobileNo() async {
    return await _storage.read(key: _keyMobile);
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
