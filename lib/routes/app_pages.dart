// lib/routes/app_pages.dart

import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/student/student_home_screen.dart';
import '../presentation/screens/student/check_in_screen.dart';
import '../presentation/screens/student/history_screen.dart';
import '../presentation/screens/student/qr_scan_screen.dart';
import '../presentation/screens/admin/admin_home_screen.dart';
import '../presentation/screens/admin/create_class_screen.dart';
import '../presentation/screens/admin/analytics_screen.dart';
import '../presentation/screens/admin/class_report_screen.dart';
import '../presentation/screens/shared/profile_screen.dart';
import '../presentation/screens/shared/class_detail_screen.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.studentHome,
      page: () => const StudentHomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.checkIn,
      page: () => const CheckInScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.createClass,
      page: () => const CreateClassScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.classDetail,
      page: () => const ClassDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.qrScan,
      page: () => const QrScanScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ClassReportScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
