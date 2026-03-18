// lib/presentation/screens/admin/class_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/class_controller.dart';

class ClassReportScreen extends StatefulWidget {
  const ClassReportScreen({super.key});

  @override
  State<ClassReportScreen> createState() => _ClassReportScreenState();
}

class _ClassReportScreenState extends State<ClassReportScreen> {
  final _attCtrl   = Get.find<AttendanceController>();
  final _classCtrl = Get.find<ClassController>();
  final RxList<AttendanceModel> _records = <AttendanceModel>[].obs;
  final RxBool _isLoading  = false.obs;
  final RxBool _exporting  = false.obs;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    _isLoading.value = true;
    final cls    = _classCtrl.selectedClass.value!;
    final result = await Get.find<AttendanceController>(); // just to ensure instantiated
    // NOTE: Since AttendanceRepository is lazily fetched, call through attCtrl
    // In a real app this would hit /attendance/report.php?class_id=X
    _isLoading.value = false;
    // For now shows attCtrl.history as demo; swap for class-specific API call
    _records.value = _attCtrl.history.where((r) => r.classId == cls.id).toList();
  }

  Future<void> _exportPdf() async {
    _exporting.value = true;
    final cls     = _classCtrl.selectedClass.value!;
    final pdf     = pw.Document();
    final present = _records.where((r) => r.withinRadius).length;
    final total   = _records.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('AttendEase – Attendance Report',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Class: ${cls.name} (${cls.courseCode})',
                style: const pw.TextStyle(fontSize: 13)),
            pw.Text('Instructor: ${cls.instructor}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Generated: ${AppFormatters.formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 11)),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          // Summary
          pw.Row(children: [
            _pdfStat('Total', '$total'),
            pw.SizedBox(width: 20),
            _pdfStat('Present', '$present'),
            pw.SizedBox(width: 20),
            _pdfStat('Absent', '${total - present}'),
            pw.SizedBox(width: 20),
            _pdfStat('Rate', '${AppFormatters.attendanceRate(present, total).toStringAsFixed(1)}%'),
          ]),
          pw.SizedBox(height: 16),

          // Table
          pw.TableHelper.fromTextArray(
            headers: ['Student', 'Date & Time', 'Method', 'Distance', 'Status'],
            data: _records.map((r) => [
              r.studentName,
              AppFormatters.formatDateTime(r.checkedInAt),
              r.method.name.toUpperCase(),
              '${r.distanceMetres.toStringAsFixed(0)}m',
              r.withinRadius ? 'Present' : 'Out of range',
            ]).toList(),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
            border: const pw.TableBorder(
              bottom: pw.BorderSide(width: 0.5),
              horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
            ),
          ),
        ],
      ),
    );

    final dir  = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/attendance_${cls.courseCode}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    _exporting.value = false;
    await OpenFile.open(file.path);
  }

  pw.Widget _pdfStat(String label, String value) => pw.Column(
    children: [
      pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final cls   = _classCtrl.selectedClass.value!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(cls.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => IconButton(
            icon: _exporting.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export PDF',
            onPressed: _exporting.value ? null : _exportPdf,
          )),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final present = _records.where((r) => r.withinRadius).length;
        final total   = _records.length;

        return Column(
          children: [
            // ── Summary ──────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.kPrimary, AppTheme.kPrimaryLight],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(value: '$total', label: 'Records'),
                  _VDivider(),
                  _Stat(value: '$present', label: 'Present'),
                  _VDivider(),
                  _Stat(value: '${total - present}', label: 'Absent'),
                  _VDivider(),
                  _Stat(value: '${AppFormatters.attendanceRate(present, total).toStringAsFixed(0)}%', label: 'Rate'),
                ],
              ),
            ).animate().fadeIn(),

            if (_records.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No attendance records for this class.',
                      style: theme.textTheme.bodyMedium),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _records.length,
                  itemBuilder: (ctx, i) {
                    final r     = _records[i];
                    final color = r.withinRadius ? AppTheme.kSecondary : AppTheme.kError;
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
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              r.withinRadius ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: color, size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
                                Text(AppFormatters.formatDateTime(r.checkedInAt),
                                    style: const TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${r.distanceMetres.toStringAsFixed(0)}m',
                                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
                              Text(r.withinRadius ? 'Present' : 'Out of range',
                                  style: TextStyle(color: color, fontSize: 11, fontFamily: 'Nunito')),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: Duration(milliseconds: 30 * i)).fadeIn();
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
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Nunito')),
    ],
  );
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: Colors.white24);
}
