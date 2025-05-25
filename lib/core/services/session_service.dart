import 'local_db_service.dart';

class SessionService {
  static const String _sessionKey = 'user_session';

  static Future<void> saveSession(String sessionData) async {
    await LocalDbService.saveSession(_sessionKey, sessionData);
  }

  static Future<String?> getSession() async {
    return await LocalDbService.getSession(_sessionKey);
  }

  static Future<void> clearSession() async {
    await LocalDbService.clearSession();
  }

  static Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null && session.isNotEmpty;
  }
}
