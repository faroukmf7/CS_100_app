// lib/presentation/bindings/app_bindings.dart
//
// KEY CHANGES:
//   1. ThemeController is REMOVED — it is registered in main() instead.
//      Having it here AND in main() caused a double-registration that
//      corrupted the instance and triggered _debugLocked.
//
//   2. All lazyPut → Get.put(permanent: true).
//      lazyPut controllers are destroyed when their route is popped.
//      When a child screen calls Get.find<Controller>() during a push
//      transition, the controller may already be in a "closing" state.
//      permanent: true means they are NEVER destroyed — exactly right
//      for app-wide shared state like Auth, Classes, and Attendance.

import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../controllers/auth_controller.dart';
import '../controllers/class_controller.dart';
import '../controllers/attendance_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Infrastructure
    Get.put<ApiProvider>(ApiProvider(), permanent: true);

    // Repositories
    Get.put<AuthRepository>(
      AuthRepository(Get.find<ApiProvider>()),
      permanent: true,
    );
    Get.put<ClassRepository>(
      ClassRepository(Get.find<ApiProvider>()),
      permanent: true,
    );
    Get.put<AttendanceRepository>(
      AttendanceRepository(Get.find<ApiProvider>()),
      permanent: true,
    );

    // Controllers
    Get.put<AuthController>(
      AuthController(Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.put<ClassController>(
      ClassController(Get.find<ClassRepository>()),
      permanent: true,
    );
    Get.put<AttendanceController>(
      AttendanceController(Get.find<AttendanceRepository>()),
      permanent: true,
    );
  }
}
