import 'package:hive/hive.dart';

class LocalDbService {
  static const String _boxName = 'fruttyBox';

  static Future<void> saveSession(String key, String value) async {
    final box = await Hive.openBox(_boxName);
    await box.put(key, value);
  }

  static Future<String?> getSession(String key) async {
    final box = await Hive.openBox(_boxName);
    return box.get(key);
  }

  static Future<void> clearSession() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
