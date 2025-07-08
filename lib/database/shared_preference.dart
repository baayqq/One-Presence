import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyToken = 'token';

  // Simpan data user
  Future<void> saveUserData({
    required String username,
    required String email,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyToken, token);
  }

  // Ambil username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // Ambil email
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // Ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Hapus semua data user (digunakan saat logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyToken);
  }
}
