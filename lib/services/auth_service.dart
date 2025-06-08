import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'enkripsi_service.dart';

class User {
  final String username;
  final String hashedPassword;
  final String salt;
  final DateTime createdAt;

  User({
    required this.username,
    required this.hashedPassword,
    required this.salt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'hashedPassword': hashedPassword,
      'salt': salt,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      hashedPassword: json['hashedPassword'],
      salt: json['salt'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _usersBoxName = 'users';

  // Register user baru
  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      // Validasi input
      if (username.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Username dan password tidak boleh kosong'
        };
      }

      if (username.length < 3) {
        return {
          'success': false,
          'message': 'Username minimal 3 karakter'
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password minimal 6 karakter'
        };
      }

      // Buka box users
      final usersBox = await Hive.openBox(_usersBoxName);

      // Cek apakah username sudah ada
      if (usersBox.containsKey(username)) {
        return {
          'success': false,
          'message': 'Username sudah digunakan'
        };
      }

      // Generate salt dan hash password
      final salt = EnkripsiService.generateSalt();
      final hashedPassword = EnkripsiService.hashPasswordWithSalt(password, salt);

      // Buat user baru
      final user = User(
        username: username,
        hashedPassword: hashedPassword,
        salt: salt,
        createdAt: DateTime.now(),
      );

      // Simpan user ke Hive
      await usersBox.put(username, user.toJson());

      return {
        'success': true,
        'message': 'Pendaftaran berhasil!'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Validasi input
      if (username.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Username dan password tidak boleh kosong'
        };
      }

      // Buka box users
      final usersBox = await Hive.openBox(_usersBoxName);

      // Cek apakah user ada
      if (!usersBox.containsKey(username)) {
        return {
          'success': false,
          'message': 'Username tidak ditemukan'
        };
      }

      // Ambil data user
      final userData = usersBox.get(username);
      final user = User.fromJson(Map<String, dynamic>.from(userData));

      // Verifikasi password
      final hashedInputPassword = EnkripsiService.hashPasswordWithSalt(password, user.salt);
      
      if (hashedInputPassword != user.hashedPassword) {
        return {
          'success': false,
          'message': 'Password salah'
        };
      }

      // Simpan session
      await _saveSession(username);

      return {
        'success': true,
        'message': 'Masuk akun berhasil!',
        'user': user
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Ambil current user
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Simpan session
  static Future<void> _saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Ambil data user lengkap
  static Future<User?> getUserData(String username) async {
    try {
      final usersBox = await Hive.openBox(_usersBoxName);
      if (usersBox.containsKey(username)) {
        final userData = usersBox.get(username);
        return User.fromJson(Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
