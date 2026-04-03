// lib/presentation/screens/admin/class_report_screen.dart
//
// Pure StatelessWidget. All state (records, isLoading, exporting, PDF export)
// lives in ReportController which is registered as non-permanent here.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../controllers/class_controller.dart';
import '../../controllers/report_controller.dart';

class ClassReportScreen extends StatelessWidget {
  const ClassReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fresh ReportController per visit — disposed automatically when screen pops.
    final report    = Get.put(ReportController());
    final classCtrl = Get.find<ClassController>();
    final cls       = classCtrl.selectedClass.value!;
    final theme     = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(cls.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Get.delete<ReportController>();
            Get.back();
          },
        ),
        actions: [
          // Obx wraps ONLY this icon — observes exporting.value
          Obx(() => IconButton(
            icon: report.exporting.value
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export PDF',
            onPressed:
            report.exporting.value ? null : report.exportPdf,
          )),
        ],
      ),
      // Single Obx wrapping the body — reads isLoading and records
      body: Obx(() {
        if (report.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final present = report.records.where((r) => r.withinRadius).length;
        final total   = report.records.length;

        return Column(
          children: [
            // ── Summary bar ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.kPrimary, AppTheme.kPrimaryLight]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(value: '$total',             label: 'Records'),
                  _VDivider(),
                  _Stat(value: '$present',           label: 'Present'),
                  _VDivider(),
                  _Stat(value: '${total - present}', label: 'Absent'),
                  _VDivider(),
                  _Stat(
                    value:
                    '${AppFormatters.attendanceRate(present, total).toStringAsFixed(0)}%',
                    label: 'Rate',
                  ),
                ],
              ),
            ).animate().fadeIn(),

            if (report.records.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No attendance records for this class.',
                      style: theme.textTheme.bodyMedium),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: report.records.length,
                  itemBuilder: (ctx, i) {
                    final r     = report.records[i];
                    final color = r.withinRadius
                        ? AppTheme.kSecondary
                        : AppTheme.kError;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.kDivider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              r.withinRadius
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(r.studentName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        fontFamily: 'Nunito')),
                                Text(
                                    AppFormatters.formatDateTime(
                                        r.checkedInAt),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.kTextSecondary,
                                        fontFamily: 'Nunito')),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  '${r.distanceMetres.toStringAsFixed(0)}m',
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      fontFamily: 'Nunito')),
                              Text(
                                  r.withinRadius
                                      ? 'Present'
                                      : 'Out of range',
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontFamily: 'Nunito')),
                            ],
                          ),
                        ],
                      ),
                    ).animate(
                        delay: Duration(milliseconds: 30 * i))
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
