// lib/presentation/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/constants/app_constants.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo;
  AuthController(this._authRepo);

  // ── Observables ──────────────────────────────────────────────────────────
  final Rx<UserModel?> currentUser   = Rx<UserModel?>(null);
  final RxBool         isLoading     = false.obs;
  final RxBool         obscurePassword = true.obs;
  final RxBool         obscureConfirm  = true.obs;
  final RxInt          registerStep  = 0.obs;

  // ── Text controllers ─────────────────────────────────────────────────────
  final emailCtrl      = TextEditingController();
  final passwordCtrl   = TextEditingController();
  final confirmCtrl    = TextEditingController();
  final firstNameCtrl  = TextEditingController();
  final surnameCtrl    = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final studentIdCtrl  = TextEditingController();

  // ── Form keys ────────────────────────────────────────────────────────────
  // These live in the controller because LoginScreen and RegisterScreen
  // are never open simultaneously, so the same GlobalKey instance is
  // never attached to two widget positions at the same time.
  // If they were ever open at the same time (e.g. both in a navigation
  // stack), they would need to live in State instead.
  final loginFormKey    = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _tryRestoreSession();
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    firstNameCtrl.dispose();
    surnameCtrl.dispose();
    middleNameCtrl.dispose();
    studentIdCtrl.dispose();
    super.onClose();
  }

  // ── Session restore ───────────────────────────────────────────────────────
  void _tryRestoreSession() {
    final stored = _authRepo.getStoredUser();
    if (stored != null && _authRepo.isLoggedIn()) {
      currentUser.value = stored;
      // addPostFrameCallback: delays until the widget tree + Navigator are
      // fully mounted. Calling Get.offAllNamed() synchronously inside onInit
      // fires before GetMaterialApp is ready and throws _debugLocked.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateByRole(stored);
      });
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;
    final result = await _authRepo.login(
      emailCtrl.text.trim(),
      passwordCtrl.text,
    );
    isLoading.value = false;
    if (result['success'] == true) {
      currentUser.value = result['user'] as UserModel;
      _showSuccess(result['message'] as String);
      _navigateByRole(currentUser.value!);
    } else {
      _showError(result['message'] as String);
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    isLoading.value = true;
    final result = await _authRepo.register(
      email:      emailCtrl.text.trim(),
      password:   passwordCtrl.text,
      firstName:  firstNameCtrl.text.trim(),
      surname:    surnameCtrl.text.trim(),
      middleName: middleNameCtrl.text.trim(),
      studentId:  studentIdCtrl.text.trim(),
    );
    isLoading.value = false;
    if (result['success'] == true) {
      currentUser.value = result['user'] as UserModel;
      _showSuccess('Account created! Welcome.');
      _navigateByRole(currentUser.value!);
    } else {
      _showError(result['message'] as String);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authRepo.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Register step navigation ──────────────────────────────────────────────
  void nextRegisterStep() {
    if (registerStep.value < 2) registerStep.value++;
  }

  void prevRegisterStep() {
    if (registerStep.value > 0) registerStep.value--;
  }

  // ── Visibility toggles ────────────────────────────────────────────────────
  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleConfirmVisibility() =>
      obscureConfirm.value = !obscureConfirm.value;

  // ── Internal helpers ──────────────────────────────────────────────────────
  void _navigateByRole(UserModel user) {
    if (user.isAdmin) {
      Get.offAllNamed(AppRoutes.adminHome);
    } else {
      Get.offAllNamed(AppRoutes.studentHome);
    }
  }

  void _showSuccess(String msg) => Get.snackbar(
    '✓ Success', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF10B981),
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );

  void _showError(String msg) => Get.snackbar(
    'Error', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFFEF4444),
    colorText: Colors.white,
    duration: const Duration(seconds: 4),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );
}
