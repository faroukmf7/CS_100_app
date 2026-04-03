// lib/presentation/screens/student/qr_scan_screen.dart
//
// Pure StatelessWidget. All scanner lifecycle (MobileScannerController,
// scanned flag, dispose) lives in QrController.
//
// QrController is registered with Get.put() here — NOT permanent, so GetX
// disposes it (calling onClose → scanner.dispose()) when this screen is
// popped. Get.delete<QrController>() is called explicitly on back-press
// to ensure immediate cleanup.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/attendance_model.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/class_controller.dart';
import '../../controllers/qr_controller.dart';

class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register a fresh QrController for this visit — non-permanent so it
    // is automatically cleaned up when the screen leaves the stack.
    final qrCtrl    = Get.put(QrController());
    final attCtrl   = Get.find<AttendanceController>();
    final authCtrl  = Get.find<AuthController>();
    final classCtrl = Get.find<ClassController>();

    void onDetect(BarcodeCapture capture) {
      if (qrCtrl.scanned.value) return;
      final barcode = capture.barcodes.firstOrNull;
      if (barcode?.rawValue == null) return;

      final qrValue = barcode!.rawValue!;
      final parts   = qrValue.split(':');

      if (parts.length >= 2 && parts[0] == 'attendease') {
        qrCtrl.scanned.value = true;
        qrCtrl.stopScan();

        final classId = int.tryParse(parts[1]);
        final cls = classCtrl.classList
            .firstWhereOrNull((c) => c.id == classId);

        if (cls != null) {
          final user = authCtrl.currentUser.value!;
          attCtrl
              .checkIn(
            classModel:  cls,
            studentId:   user.id,
            studentName: user.fullName,
            method:      CheckInMethod.qrCode,
          )
              .then((_) {
            // Delete controller before navigating so it's cleaned up
            Get.delete<QrController>();
            Get.back();
            if (attCtrl.checkInState.value == CheckInState.success) {
              classCtrl.selectedClass.value = cls;
              Get.toNamed(AppRoutes.checkIn);
            }
          });
        } else {
          Get.snackbar(
            'Invalid QR',
            'This QR code does not match any active class.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.kError,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
          );
          Future.delayed(const Duration(seconds: 2), () {
            qrCtrl.resetScan();
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            Get.delete<QrController>();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => qrCtrl.scanner.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: qrCtrl.scanner,
            onDetect: onDetect,
          ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Point camera at the class QR code',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Nunito'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
