// lib/presentation/controllers/qr_controller.dart
//
// Owns the MobileScannerController so QrScanScreen can be a pure
// StatelessWidget. Registered as NON-permanent with Get.put() inside
// QrScanScreen.build() — a fresh instance is created every visit and
// disposed (via onClose) when the screen is popped.

import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrController extends GetxController {
  // The scanner controller — its lifecycle is tied to this GetX controller.
  final MobileScannerController scanner = MobileScannerController();

  // Prevents double-processing the same QR code.
  final RxBool scanned = false.obs;

  void resetScan() {
    scanned.value = false;
    scanner.start();
  }

  void stopScan() {
    scanner.stop();
  }

  @override
  void onClose() {
    scanner.dispose();
    super.onClose();
  }
}
