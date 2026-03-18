// lib/data/repositories/attendance_repository.dart
// ─────────────────────────────────────────
// Core check-in logic:
//   1. Get live GPS location
//   2. Compute Haversine distance vs stored classroom coords
//   3. Allow or deny check-in based on radius
//   4. Cache offline; sync when connection restored
//
// PHP endpoints:
//   POST /attendance/checkin.php   → {class_id, student_lat, student_lng, method}
//   POST /attendance/checkout.php  → {attendance_id}
//   GET  /attendance/history.php   → ?student_id=X
//   GET  /attendance/report.php    → ?class_id=X  (admin)
//   GET  /attendance/today.php     → ?class_id=X&student_id=Y
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import '../models/attendance_model.dart';
import '../models/class_model.dart';
import '../providers/api_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';

class AttendanceRepository {
  final ApiProvider _api;
  final _storage = GetStorage();

  AttendanceRepository(this._api);

  // ── Shared guard ─────────────────────────────────────────────────────────
  // response.data can be null (empty body) or a raw String (PHP error page).
  // _toMap() checks the type before casting so none of the methods below can
  // throw "null is not a subtype of Map<String, dynamic>".
  Map<String, dynamic>? _toMap(dynamic raw) {
    if (raw == null || raw is! Map) return null;
    return Map<String, dynamic>.from(raw);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GEOLOCATION CHECK-IN (Core Feature)
  // ─────────────────────────────────────────────────────────────────────────

  Future<CheckInResult> checkIn({
    required ClassModel classModel,
    required int studentId,
    required String studentName,
    CheckInMethod method = CheckInMethod.gps,
  }) async {
    // ── Step 1: Permission check ─────────────────────────────────────────
    final permission = await _ensureLocationPermission();
    if (permission != null) {
      return CheckInResult(
        success: false, message: permission,
        distanceMetres: 0, withinRadius: false,
      );
    }

    // ── Step 2: Get live location ─────────────────────────────────────────
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: AppConstants.kLocationTimeout),
      );
    } catch (e) {
      return CheckInResult(
        success: false,
        message: 'Could not get your location. Please try again.',
        distanceMetres: 0,
        withinRadius: false,
      );
    }

    // ── Step 3: Haversine distance ─────────────────────────────────────────
    final distance = GeoUtils.distanceInMeters(
      lat1: position.latitude, lon1: position.longitude,
      lat2: classModel.classLat, lon2: classModel.classLng,
    );

    final withinRadius = distance <= classModel.radiusMetres;

    // ── Step 4: Radius gate ────────────────────────────────────────────────
    if (!withinRadius) {
      return CheckInResult(
        success: false,
        message: 'You are ${distance.toStringAsFixed(0)}m from the classroom. '
            'You must be within ${classModel.radiusMetres.toStringAsFixed(0)}m to check in.',
        distanceMetres: distance,
        withinRadius: false,
      );
    }

    // ── Step 5: POST to server ─────────────────────────────────────────────
    try {
      final response = await _api.post('/attendance/checkin.php', data: {
        'class_id':    classModel.id,
        'student_id':  studentId,
        'student_lat': position.latitude,
        'student_lng': position.longitude,
        'distance_m':  distance,
        'method':      method.name,
      });
      final data = _toMap(response.data);
      if (data == null) {
        // Server returned empty or non-JSON — fall through to offline queue.
        throw Exception('Non-map response, queuing offline.');
      }
      if (data['status'] == true) {
        final rawData = data['data'];
        final attendance = AttendanceModel.fromJson(
          rawData is Map ? Map<String, dynamic>.from(rawData) : {},
        );
        return CheckInResult(
          success: true,
          message: 'Check-in successful! You are ${distance.toStringAsFixed(0)}m from class.',
          distanceMetres: distance,
          withinRadius: true,
          attendance: attendance,
        );
      }
      return CheckInResult(
        success: false, message: data['message'] ?? 'Check-in failed.',
        distanceMetres: distance, withinRadius: true,
      );
    } catch (e) {
      // ── Offline fallback: queue locally ─────────────────────────────────
      final offline = AttendanceModel(
        id:             DateTime.now().millisecondsSinceEpoch,
        studentId:      studentId,
        classId:        classModel.id,
        studentName:    studentName,
        className:      classModel.name,
        studentLat:     position.latitude,
        studentLng:     position.longitude,
        distanceMetres: distance,
        withinRadius:   true,
        checkedInAt:    DateTime.now(),
        method:         method,
        status:         AttendanceStatus.present,
        syncedToServer: false,
      );
      await _queueOfflineCheckIn(offline);
      return CheckInResult(
        success: true,
        message: 'Check-in saved offline. Will sync when connected.',
        distanceMetres: distance,
        withinRadius: true,
        attendance: offline,
      );
    }
  }

  // ── Check-out ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> checkOut(int attendanceId) async {
    try {
      final response = await _api.post('/attendance/checkout.php', data: {'attendance_id': attendanceId});
      final data = _toMap(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      return {'success': data['status'] == true, 'message': data['message'] ?? 'Checked out.'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── History ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getStudentHistory(int studentId) async {
    try {
      final response = await _api.get('/attendance/history.php', params: {'student_id': studentId});
      final data = _toMap(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      if (data['status'] == true) {
        final raw = data['data'];
        if (raw is! List) {
          return {'success': false, 'message': 'Invalid history format.'};
        }
        final list = raw
            .whereType<Map>()
            .map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return {'success': true, 'records': list};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load history.'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── Admin Report ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getClassReport(int classId) async {
    try {
      final response = await _api.get('/attendance/report.php', params: {'class_id': classId});
      final data = _toMap(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      if (data['status'] == true) {
        final raw = data['data'];
        if (raw is! List) {
          return {'success': false, 'message': 'Invalid report format.'};
        }
        final list = raw
            .whereType<Map>()
            .map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return {'success': true, 'records': list, 'stats': data['stats']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load report.'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── Today's check-in status ────────────────────────────────────────────────
  Future<bool> isAlreadyCheckedIn(int classId, int studentId) async {
    try {
      final response = await _api.get('/attendance/today.php',
          params: {'class_id': classId, 'student_id': studentId});
      final data = _toMap(response.data);
      return data != null && data['checked_in'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── Offline Queue ─────────────────────────────────────────────────────────
  Future<void> _queueOfflineCheckIn(AttendanceModel record) async {
    final queue = _getOfflineQueue();
    queue.add(record.toJson());
    await _storage.write(AppConstants.kAttendanceKey, jsonEncode(queue));
  }

  List<Map<String, dynamic>> _getOfflineQueue() {
    final raw = _storage.read<String>(AppConstants.kAttendanceKey);
    if (raw == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  Future<void> syncOfflineQueue() async {
    final queue = _getOfflineQueue();
    if (queue.isEmpty) return;
    final syncedIndices = <int>[];
    for (int i = 0; i < queue.length; i++) {
      try {
        final response = await _api.post('/attendance/checkin.php', data: queue[i]);
        final data = _toMap(response.data);
        if (data != null && data['status'] == true) {
          syncedIndices.add(i);
        }
      } catch (_) {}
    }
    final remaining = [
      for (int i = 0; i < queue.length; i++)
        if (!syncedIndices.contains(i)) queue[i],
    ];
    await _storage.write(AppConstants.kAttendanceKey, jsonEncode(remaining));
  }

  int get offlineQueueCount => _getOfflineQueue().length;

  // ── Permission Helper ─────────────────────────────────────────────────────
  Future<String?> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'Location services are disabled. Please enable them.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return AppStrings.permDenied;
    }
    if (permission == LocationPermission.deniedForever) return AppStrings.permPermanently;
    return null;
  }
}
