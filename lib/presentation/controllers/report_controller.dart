// lib/presentation/controllers/report_controller.dart
//
// Owns all state for ClassReportScreen so it can be a pure StatelessWidget.
// Registered as NON-permanent with Get.put() inside ClassReportScreen.build().
// A fresh instance is created every visit and disposed when the screen pops.

import 'dart:io';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/utils/app_utils.dart';
import '../../data/models/attendance_model.dart';
import 'attendance_controller.dart';
import 'class_controller.dart';

class ReportController extends GetxController {
  final RxList<AttendanceModel> records   = <AttendanceModel>[].obs;
  final RxBool                  isLoading = false.obs;
  final RxBool                  exporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReport();
  }

  void _loadReport() {
    isLoading.value = true;
    final classCtrl = Get.find<ClassController>();
    final attCtrl   = Get.find<AttendanceController>();
    final cls       = classCtrl.selectedClass.value;
    if (cls != null) {
      records.value = attCtrl.history
          .where((r) => r.classId == cls.id)
          .toList();
    }
    isLoading.value = false;
  }

  Future<void> exportPdf() async {
    final classCtrl = Get.find<ClassController>();
    final cls = classCtrl.selectedClass.value;
    if (cls == null) return;

    exporting.value = true;

    final pdf     = pw.Document();
    final present = records.where((r) => r.withinRadius).length;
    final total   = records.length;

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
          pw.Row(children: [
            _pdfStat('Total',   '$total'),
            pw.SizedBox(width: 20),
            _pdfStat('Present', '$present'),
            pw.SizedBox(width: 20),
            _pdfStat('Absent',  '${total - present}'),
            pw.SizedBox(width: 20),
            _pdfStat('Rate',
                '${AppFormatters.attendanceRate(present, total).toStringAsFixed(1)}%'),
          ]),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Student', 'Date & Time', 'Method', 'Distance', 'Status'],
            data: records.map((r) => [
              r.studentName,
              AppFormatters.formatDateTime(r.checkedInAt),
              r.method.name.toUpperCase(),
              '${r.distanceMetres.toStringAsFixed(0)}m',
              r.withinRadius ? 'Present' : 'Out of range',
            ]).toList(),
            cellStyle:        const pw.TextStyle(fontSize: 10),
            headerStyle:      pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
            border: const pw.TableBorder(
              bottom:          pw.BorderSide(width: 0.5),
              horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
            ),
          ),
        ],
      ),
    );

    final dir  = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/attendance_${cls.courseCode}_'
            '${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    exporting.value = false;
    await OpenFile.open(file.path);
  }

  pw.Widget _pdfStat(String label, String value) => pw.Column(
    children: [
      pw.Text(value,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
    ],
  );
}
