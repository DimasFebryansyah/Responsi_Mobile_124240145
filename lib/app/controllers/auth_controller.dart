import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  AuthController(this._preferences, {required String? initialEmail})
    : email = (initialEmail?.trim() ?? '').obs,
      isAuthenticated = (initialEmail?.trim().isNotEmpty ?? false).obs;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _emailKey = 'email';
  static const _loggedInKey = 'isLoggedIn';

  final SharedPreferences _preferences;
  final RxString email;
  final RxBool isAuthenticated;

  static bool isValidEmail(String email) =>
      _emailPattern.hasMatch(email.trim());

  Future<bool> login({required String email, required String password}) async {
    final normalizedEmail = email.trim();
    if (!isValidEmail(normalizedEmail) || password.isEmpty) {
      return false;
    }

    final emailSaved = await _preferences.setString(_emailKey, normalizedEmail);
    if (!emailSaved) {
      throw const AuthException('Email tidak dapat disimpan.');
    }
    final sessionSaved = await _preferences.setBool(_loggedInKey, true);
    if (!sessionSaved) {
      await _preferences.remove(_emailKey);
      throw const AuthException('Sesi login tidak dapat disimpan.');
    }
    this.email.value = normalizedEmail;
    isAuthenticated.value = true;
    return true;
  }

  Future<void> logout() async {
    await _preferences.remove(_emailKey);
    await _preferences.remove(_loggedInKey);
    email.value = '';
    isAuthenticated.value = false;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
