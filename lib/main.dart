// lib/main.dart
// ─────────────────────────────────────────
// FIX: Removed Obx() wrapper from GetMaterialApp.
//
// GetMaterialApp must NEVER be wrapped in Obx(), StreamBuilder,
// or any reactive widget. Doing so causes GetX to destroy and
// re-create its internal Navigator key on every rebuild, which
// breaks all navigation with "contextless navigation" errors.
//
// Theme switching works via Get.changeTheme() in ThemeController
// which updates the theme IN-PLACE without rebuilding GetMaterialApp.
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bindings/app_bindings.dart';
import 'presentation/controllers/theme_controller.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Register ThemeController ONCE, BEFORE runApp, BEFORE the widget tree.
  // permanent: true = never disposed by GetX route management.
  Get.put<ThemeController>(ThemeController(), permanent: true);

  runApp(const AttendEaseApp());
}

class AttendEaseApp extends StatelessWidget {
  const AttendEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    // ✅ CORRECT: Return GetMaterialApp directly — NO Obx, NO wrapper.
    // Theme changes go through Get.changeTheme() which does not rebuild this.
    return GetMaterialApp(
      title: AppConstants.kAppName,
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeCtrl.isDark.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute:      AppRoutes.splash,
      getPages:          AppPages.routes,
      defaultTransition: Transition.fadeIn,
      initialBinding:    AppBindings(),
      locale:            const Locale('en', 'US'),
      fallbackLocale:    const Locale('en', 'US'),
    );
  }
}
