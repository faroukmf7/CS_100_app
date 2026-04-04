// lib/presentation/controllers/attendance_controller.dart
// ─────────────────────────────────────────
// Controls check-in UX state machine:
//   idle → fetching_location → calculating → success / error
// Also manages: history, offline sync, check-out timer.
// ─────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/class_model.dart';
import '../../data/repositories/attendance_repository.dart';

enum CheckInState { idle, fetchingLocation, calculating, success, error }

class AttendanceController extends GetxController {
  final AttendanceRepository _repo;
  AttendanceController(this._repo);

  // ── Observables ───────────────────────────────────────────────────────────
  final Rx<CheckInState>       checkInState     = CheckInState.idle.obs;
  final RxList<AttendanceModel> history         = <AttendanceModel>[].obs;
  final RxBool                 isLoadingHistory = false.obs;
  final RxDouble               lastDistance     = 0.0.obs;
  final RxBool                 lastWithinRadius = false.obs;
  final RxString               statusMessage    = ''.obs;
  final Rx<AttendanceModel?>   latestRecord     = Rx<AttendanceModel?>(null);
  final RxInt                  offlineCount     = 0.obs;

  // Auto check-out timer (extension point)
  Timer? _checkOutTimer;

  late final FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    offlineCount.value = _repo.offlineQueueCount;
  }

  @override
  void onClose() {
    _checkOutTimer?.cancel();
    super.onClose();
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  Future<void> _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<void> _showCheckInNotification(String className) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'checkin_channel', 'Check-In',
        channelDescription: 'Attendance check-in notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _notificationsPlugin.show(
      0, 'Check-in Successful ✓',
      'You have checked in to $className',
      details,
    );
  }

  // ── Check-In ──────────────────────────────────────────────────────────────
  Future<void> checkIn({
    required ClassModel classModel,
    required int studentId,
    required String studentName,
    CheckInMethod method = CheckInMethod.gps,
  }) async {
    checkInState.value = CheckInState.fetchingLocation;
    statusMessage.value = 'Getting your location…';

    await Future.delayed(const Duration(milliseconds: 300)); // UX breathing room

    checkInState.value = CheckInState.calculating;
    statusMessage.value = 'Verifying distance…';

    final result = await _repo.checkIn(
      classModel:  classModel,
      studentId:   studentId,
      studentName: studentName,
      method:      method,
    );

    lastDistance.value     = result.distanceMetres;
    lastWithinRadius.value = result.withinRadius;
    statusMessage.value    = result.message;

    if (result.success) {
      checkInState.value = CheckInState.success;
      latestRecord.value = result.attendance;
      // Notification
      await _showCheckInNotification(classModel.name);
      // Add to history
      if (result.attendance != null) {
        history.insert(0, result.attendance!);
      }
      // Schedule auto check-out if class has an end time
      _scheduleAutoCheckOut(classModel, result.attendance?.id ?? 0);
      // Update offline count
      offlineCount.value = _repo.offlineQueueCount;
      _showSuccessSnack(result.message);
    } else {
      checkInState.value = CheckInState.error;
      _showErrorSnack(result.message);
    }
  }

  void resetCheckInState() => checkInState.value = CheckInState.idle;

  // ── Auto Check-Out ─────────────────────────────────────────────────────────
  void _scheduleAutoCheckOut(ClassModel classModel, int attendanceId) {
    _checkOutTimer?.cancel();
    final now = DateTime.now();
    final endTime = DateTime(now.year, now.month, now.day,
        classModel.endHour, classModel.endMinute);
    if (endTime.isAfter(now)) {
      final delay = endTime.difference(now);
      _checkOutTimer = Timer(delay, () => _autoCheckOut(attendanceId));
    }
  }

  Future<void> _autoCheckOut(int attendanceId) async {
    await _repo.checkOut(attendanceId);
    Get.snackbar('Auto Check-out', 'You have been checked out as class ended.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFF59E0B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  // ── History ────────────────────────────────────────────────────────────────
  Future<void> fetchHistory(int studentId) async {
    isLoadingHistory.value = true;
    final result = await _repo.getStudentHistory(studentId);
    isLoadingHistory.value = false;
    if (result['success'] == true) {
      history.value = result['records'] as List<AttendanceModel>;
    }
  }

  // ── Offline Sync ───────────────────────────────────────────────────────────
  Future<void> syncOffline() async {
    await _repo.syncOfflineQueue();
    offlineCount.value = _repo.offlineQueueCount;
    if (offlineCount.value == 0) {
      Get.snackbar('Synced', 'All offline check-ins have been synced.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  void _showSuccessSnack(String msg) => Get.snackbar('✓ Checked In', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF10B981),
    colorText: Colors.white,
    duration: const Duration(seconds: 4),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );

  void _showErrorSnack(String msg) => Get.snackbar('Check-in Failed', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFFEF4444),
    colorText: Colors.white,
    duration: const Duration(seconds: 5),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );
}
