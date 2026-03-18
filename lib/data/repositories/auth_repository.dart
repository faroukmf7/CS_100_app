// lib/data/repositories/auth_repository.dart
// ─────────────────────────────────────────
// Handles login, registration, token persistence.
// PHP endpoints:
//   POST /auth/login.php    → {email, password}
//   POST /auth/register.php → {fname, sname, mname, email, password, student_id}
//   POST /auth/logout.php   → {} (Bearer token)
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final ApiProvider _api;
  final _storage = GetStorage();

  AuthRepository(this._api);

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post(
        '/auth/login.php',
        data: {'email': email.trim(), 'password': password},
      );
      // response.data can be null if the server returns an empty body, or a
      // String if the PHP script outputs non-JSON (e.g. a parse error). Guard
      // with an explicit type check before casting to avoid the
      // "null is not a subtype of Map<String, dynamic>" crash.
      final raw = response.data;
      if (raw == null || raw is! Map) {
        return {'success': false, 'message': 'Unexpected server response. Please try again.'};
      }
      final data = Map<String, dynamic>.from(raw);
      if (data['status'] == true) {
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String? ?? '';
        await _storage.write(AppConstants.kUserKey, jsonEncode(user.toJson()));
        await _storage.write(AppConstants.kTokenKey, token);
        return {'success': true, 'user': user, 'message': data['message'] ?? 'Welcome back!'};
      }
      return {'success': false, 'message': data['message'] ?? 'Invalid credentials'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String surname,
    required String middleName,
    required String studentId,
  }) async {
    try {
      final response = await _api.post(
        '/auth/register.php',
        data: {
          'fname':      firstName.trim(),
          'sname':      surname.trim(),
          'mname':      middleName.trim(),
          'email':      email.trim(),
          'password':   password,
          'student_id': studentId.trim(),
        },
      );
      final raw = response.data;
      if (raw == null || raw is! Map) {
        return {'success': false, 'message': 'Unexpected server response. Please try again.'};
      }
      final data = Map<String, dynamic>.from(raw);
      if (data['status'] == true) {
        return login(email, password);
      }
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── Restore Session ────────────────────────────────────────────────────────
  UserModel? getStoredUser() {
    final raw = _storage.read<String>(AppConstants.kUserKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool isLoggedIn() {
    final token = _storage.read<String>(AppConstants.kTokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout.php');
    } catch (_) {}
    await _storage.remove(AppConstants.kUserKey);
    await _storage.remove(AppConstants.kTokenKey);
  }
}
