// lib/presentation/screens/student/qr_scan_screen.dart
// QR code check-in as fallback when GPS is unavailable.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/attendance_model.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/class_controller.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _ctrl       = MobileScannerController();
  final _attCtrl    = Get.find<AttendanceController>();
  final _authCtrl   = Get.find<AuthController>();
  final _classCtrl  = Get.find<ClassController>();
  bool _scanned     = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final qrValue = barcode!.rawValue!;
    // Expected QR format: "attendease:class_id:SECRET_TOKEN"
    final parts = qrValue.split(':');
    if (parts.length >= 2 && parts[0] == 'attendease') {
      _scanned = true;
      _ctrl.stop();
      final classId = int.tryParse(parts[1]);
      final cls = _classCtrl.classList.firstWhereOrNull((c) => c.id == classId);
      if (cls != null) {
        final user = _authCtrl.currentUser.value!;
        _attCtrl.checkIn(
          classModel:  cls,
          studentId:   user.id,
          studentName: user.fullName,
          method:      CheckInMethod.qrCode,
        ).then((_) {
          Get.back();
          if (_attCtrl.checkInState.value == CheckInState.success) {
            _classCtrl.selectedClass.value = cls;
            Get.toNamed(AppRoutes.checkIn);
          }
        });
      } else {
        Get.snackbar('Invalid QR', 'This QR code does not match any active class.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.kError,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        Future.delayed(const Duration(seconds: 2), () {
          _scanned = false;
          _ctrl.start();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _ctrl.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),

          // Overlay frame
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.kPrimary, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Point camera at the class QR code',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Nunito'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
