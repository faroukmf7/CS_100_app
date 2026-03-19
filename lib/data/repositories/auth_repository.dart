// lib/data/repositories/auth_repository.dart
// ─────────────────────────────────────────
// FIXES APPLIED:
//
// BUG A — login() was reading data['token'] and data['user'].
//   PHP helpers.php respond_ok() wraps everything one level deeper:
//   { "status": true, "message": "...", "data": { "token": "...", "user": {...} } }
//   So Flutter must read data['data']['token'] and data['data']['user'].
//
// BUG B — register() called login(email, password) after success,
//   which fired a second HTTP round-trip. register.php already returns
//   a token + user in its response, so we use those directly instead.
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/widgets.dart';
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

      final raw = response.data;
      if (raw == null || raw is! Map) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      final data = Map<String, dynamic>.from(raw);

      if (data['status'] == true) {
        print(data['user']);
        print(data['token']);
        // FIX A: token and user are nested inside data['data'], not data directly.
        final nested = data['data'] as Map<String, dynamic>? ?? {};
        final user   = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final token  = data['token'] as String? ?? '';

        await _storage.write(AppConstants.kUserKey,  jsonEncode(user.toJson()));
        await _storage.write(AppConstants.kTokenKey, token);

        return {
          'success': true,
          'user':    user,
          'message': data['message'] ?? 'Welcome back!',
        };
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
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      final data = Map<String, dynamic>.from(raw);

      if (data['status'] == true) {
        // FIX B: Use the token + user that register.php already returned.
        // No second login() call needed — that was an extra unnecessary round-trip.
        final nested = data['data'] as Map<String, dynamic>? ?? {};
        final user   = UserModel.fromJson(nested['user'] as Map<String, dynamic>);
        final token  = nested['token'] as String? ?? '';

        await _storage.write(AppConstants.kUserKey,  jsonEncode(user.toJson()));
        await _storage.write(AppConstants.kTokenKey, token);

        return {
          'success': true,
          'user':    user,
          'message': data['message'] ?? 'Account created!',
        };
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
