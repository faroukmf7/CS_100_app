// lib/presentation/controllers/theme_controller.dart
//
// Get.changeTheme() applies the new theme to the running app in-place.
// It does NOT rebuild GetMaterialApp, so the navigation key is safe.
// isDark is still observable so the toggle icon in the UI reacts instantly.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final RxBool isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = _storage.read<bool>(AppConstants.kThemeKey) ?? false;
    // Apply on startup without rebuilding GetMaterialApp
    _applyTheme();
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    _storage.write(AppConstants.kThemeKey, isDark.value);
    _applyTheme();
  }

  void _applyTheme() {
    // ✅ This swaps the theme in-place on the existing GetMaterialApp.
    // It does NOT trigger a rebuild of GetMaterialApp itself.
    Get.changeTheme(isDark.value ? AppTheme.darkTheme : AppTheme.lightTheme);
  }

  ThemeData get currentTheme =>
      isDark.value ? AppTheme.darkTheme : AppTheme.lightTheme;
}
