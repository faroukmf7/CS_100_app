// lib/presentation/controllers/auth_controller.dart
// ─────────────────────────────────────────
// MVC Controller (GetX) for authentication.
// Manages: login, register, session restoration, logout.
// Views bind to observables declared here.
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/constants/app_constants.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo;
  AuthController(this._authRepo);

  // ── Observables ───────────────────────────────────────────────────────────
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading       = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm  = true.obs;
  final RxInt  registerStep    = 0.obs;

  // ── Form Controllers ──────────────────────────────────────────────────────
  final emailCtrl      = TextEditingController();
  final passwordCtrl   = TextEditingController();
  final confirmCtrl    = TextEditingController();
  final firstNameCtrl  = TextEditingController();
  final surnameCtrl    = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final studentIdCtrl  = TextEditingController();

  // Note: loginFormKey and registerFormKey are intentionally NOT stored here.
  // GlobalKeys must be owned by the widget State that uses them, not by a
  // persistent singleton controller. Keeping a GlobalKey in a controller causes
  // "GlobalKey used multiple times" errors whenever the widget tree is rebuilt
  // (e.g. on theme change), because the controller's key instance outlives the
  // widget and Flutter finds the same key object in two different tree positions.

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _tryRestoreSession();
  }

  @override
  void onClose() {
    emailCtrl.dispose(); passwordCtrl.dispose(); confirmCtrl.dispose();
    firstNameCtrl.dispose(); surnameCtrl.dispose();
    middleNameCtrl.dispose(); studentIdCtrl.dispose();
    super.onClose();
  }

  // ── Session Restore ────────────────────────────────────────────────────────
  void _tryRestoreSession() {
    final stored = _authRepo.getStoredUser();
    if (stored != null && _authRepo.isLoggedIn()) {
      currentUser.value = stored;
      // Delay navigation until after the first frame so GetMaterialApp's
      // Navigator is fully registered. Calling Get.offAllNamed() synchronously
      // inside onInit() — which runs during AppBindings, before the widget tree
      // is built — triggers the _debugLocked assertion and the "contextless
      // navigation" error because the Navigator lock is still in its initial
      // state. addPostFrameCallback guarantees the tree and GetX's router are
      // ready before we push any route.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateByRole(stored);
      });
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
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
  Future<void> register(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
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

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authRepo.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Register Step Navigation ──────────────────────────────────────────────
  void nextRegisterStep() {
    if (registerStep.value < 2) registerStep.value++;
  }

  void prevRegisterStep() {
    if (registerStep.value > 0) registerStep.value--;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;
  void toggleConfirmVisibility()  => obscureConfirm.value  = !obscureConfirm.value;

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
