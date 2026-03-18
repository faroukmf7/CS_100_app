// lib/main.dart
// ─────────────────────────────────────────
// App entry point. GetMaterialApp wired with:
//   - Named routes (AppPages)
//   - Global dependency injection (AppBindings)
//   - Theme (light + dark via ThemeController)
//   - Initial route: /splash
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

  // ── Initialise local storage ───────────────────────────────────────────────
  await GetStorage.init();

  // ── Lock orientation to portrait ───────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Transparent status bar ─────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Register ThemeController once here, permanently, before the widget tree
  // is built. Doing it inside build() caused it to re-register on every Obx
  // rebuild, which created subtle lifecycle issues.
  Get.put(ThemeController(), permanent: true);

  runApp(const AttendEaseApp());
}

class AttendEaseApp extends StatelessWidget {
  const AttendEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the already-registered ThemeController — never put() here.
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: AppConstants.kAppName,
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeCtrl.isDark.value ? ThemeMode.dark : ThemeMode.light,

      // ── Routes ───────────────────────────────────────────────────────────
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,

      // ── Global DI ────────────────────────────────────────────────────────
      initialBinding: AppBindings(),

      // ── Locale (multi-language ready) ─────────────────────────────────────
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    ));
  }
}
