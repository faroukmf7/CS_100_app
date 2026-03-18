// lib/core/utils/app_utils.dart
// ─────────────────────────────────────────
// Utility functions: validation, geo math, formatting, etc.
// ─────────────────────────────────────────

import 'dart:math';
import 'package:intl/intl.dart';

class AppValidators {
  AppValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Student ID is required';
    if (value.trim().length < 4) return 'Enter a valid student ID';
    return null;
  }

  static String? validatePasswordMatch(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}

class GeoUtils {
  GeoUtils._();

  /// Haversine formula – returns distance in metres between two coordinates.
  static double distanceInMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadius = 6371000.0; // metres
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// Returns human-readable distance string.
  static String formatDistance(double metres) {
    if (metres < 1000) return '${metres.toStringAsFixed(0)}m away';
    return '${(metres / 1000).toStringAsFixed(1)}km away';
  }

  /// Whether student is within the class radius.
  static bool isWithinRadius({
    required double studentLat,
    required double studentLng,
    required double classLat,
    required double classLng,
    required double radiusMetres,
  }) {
    final d = distanceInMeters(
      lat1: studentLat, lon1: studentLng,
      lat2: classLat, lon2: classLng,
    );
    return d <= radiusMetres;
  }
}

class AppFormatters {
  AppFormatters._();

  static String formatDate(DateTime dt) => DateFormat('EEE, MMM d, yyyy').format(dt);
  static String formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);
  static String formatDateTime(DateTime dt) => DateFormat('MMM d, h:mm a').format(dt);
  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String getDayName(int dayIndex) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (dayIndex < 0 || dayIndex > 6) return 'Unknown';
    return days[dayIndex];
  }

  static String timeOfDayToString(int hour, int minute) {
    final dt = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(dt);
  }

  static double attendanceRate(int present, int total) {
    if (total == 0) return 0;
    return (present / total) * 100;
  }
}
