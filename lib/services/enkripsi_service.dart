import 'dart:convert';
import 'package:crypto/crypto.dart';

class EnkripsiService {
  // Enkripsi password menggunakan SHA256
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verifikasi password
  static bool verifyPassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }

  // Generate salt untuk keamanan tambahan (opsional)
  static String generateSalt() {
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var bytes = utf8.encode(timestamp);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // Hash password dengan salt
  static String hashPasswordWithSalt(String password, String salt) {
    var combined = password + salt;
    var bytes = utf8.encode(combined);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
