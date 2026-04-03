// lib/presentation/screens/student/history_screen.dart
//
// Pure StatelessWidget. Get.find() inside build().
// fetchHistory triggered via addPostFrameCallback so it runs after
// the widget is mounted — same effect as initState without StatefulWidget.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl  = Get.find<AttendanceController>();
    final auth  = Get.find<AuthController>();
    final theme = Theme.of(context);

    // Trigger fetch after the first frame — equivalent to initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchHistory(auth.currentUser.value?.id ?? 0);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      // Single Obx wrapping the body — reads isLoadingHistory and history
      body: Obx(() {
        if (ctrl.isLoadingHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No attendance records yet',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Check in to a class to see your history here.',
                    style: TextStyle(
                        color: AppTheme.kTextSecondary, fontSize: 13)),
              ],
            ),
          );
        }

        final total   = ctrl.history.length;
        final present = ctrl.history.where((a) => a.withinRadius).length;
        final rate    = AppFormatters.attendanceRate(present, total);

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.kPrimary, AppTheme.kPrimaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(value: '$total',             label: 'Total'),
                  _VDivider(),
                  _Stat(value: '$present',           label: 'Present'),
                  _VDivider(),
                  _Stat(value: '${total - present}', label: 'Absent'),
                  _VDivider(),
                  _Stat(
                      value: '${rate.toStringAsFixed(0)}%',
                      label: 'Rate'),
                ],
              ),
            ).animate().slideY(begin: -0.1, end: 0, duration: 300.ms).fadeIn(),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.history.length,
                itemBuilder: (ctx, i) {
                  final record = ctrl.history[i];
                  return _HistoryTile(record: record)
                      .animate(delay: Duration(milliseconds: 30 * i))
                      .slideX(
                      begin: 0.1,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOut)
                      .fadeIn();
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito')),
      Text(label,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontFamily: 'Nunito')),
    ],
  );
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: Colors.white24);
}

class _HistoryTile extends StatelessWidget {
  final AttendanceModel record;
  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isPresent = record.withinRadius;
    final color     = isPresent ? AppTheme.kSecondary : AppTheme.kError;
    final icon      = isPresent
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.kDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.className,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Nunito')),
                const SizedBox(height: 2),
                Text(AppFormatters.formatDateTime(record.checkedInAt),
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.kTextSecondary,
                        fontFamily: 'Nunito')),
                if (record.distanceMetres > 0)
                  Text(
                      '${record.distanceMetres.toStringAsFixed(0)}m from classroom',
                      style: TextStyle(
                          fontSize: 11,
                          color: color.withOpacity(0.8),
                          fontFamily: 'Nunito')),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  record.method == CheckInMethod.qrCode
                      ? Icons.qr_code_rounded
                      : Icons.my_location_rounded,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  record.method == CheckInMethod.qrCode ? 'QR' : 'GPS',
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
