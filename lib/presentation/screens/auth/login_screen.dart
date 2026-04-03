// lib/presentation/screens/auth/login_screen.dart
//
// Pure StatelessWidget. All state (formKey, text controllers, loading flag,
// password visibility) lives in AuthController which is a permanent singleton.
// Get.find<AuthController>() called inside build() — always safe.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Always call Get.find inside build() — never as a field.
    final auth  = Get.find<AuthController>();
    final theme = Theme.of(context);
    final size  = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.08),

                // ── Brand ──────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.kPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.how_to_reg_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.kAppName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.kPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 36),

                Text('Welcome back',
                    style: theme.textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w800))
                    .animate(delay: 100.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
                    .fadeIn(),

                const SizedBox(height: 6),

                Text('Sign in to track your attendance',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: AppTheme.kTextSecondary))
                    .animate(delay: 150.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms)
                    .fadeIn(),

                const SizedBox(height: 40),

                // ── Form ───────────────────────────────────────────────────
                // formKey lives in AuthController — safe because LoginScreen
                // is never open simultaneously with another LoginScreen.
                Form(
                  key: auth.loginFormKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: auth.emailCtrl,
                        label: AppStrings.email,
                        hint: 'you@university.edu',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.validateEmail,
                      ).animate(delay: 200.ms)
                          .slideY(begin: 0.2, end: 0, duration: 400.ms)
                          .fadeIn(),

                      const SizedBox(height: 16),

                      // Obx wraps ONLY this one field — it observes obscurePassword.value
                      Obx(() => AppTextField(
                        controller: auth.passwordCtrl,
                        label: AppStrings.password,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: auth.obscurePassword.value,
                        validator: AppValidators.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            auth.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.kTextSecondary,
                            size: 20,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                      )).animate(delay: 250.ms)
                          .slideY(begin: 0.2, end: 0, duration: 400.ms)
                          .fadeIn(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.snackbar(
                      'Coming Soon', 'Password reset will be available soon.',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                    child: Text(AppStrings.forgotPass,
                        style: const TextStyle(
                            color: AppTheme.kPrimary,
                            fontWeight: FontWeight.w600)),
                  ),
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 24),

                // Obx wraps ONLY the button — it observes isLoading.value
                Obx(() => AppButton(
                  label:     AppStrings.login,
                  isLoading: auth.isLoading.value,
                  onPressed: auth.login,
                  icon:      Icons.login_rounded,
                )).animate(delay: 350.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms)
                    .fadeIn(),

                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: theme.textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: Text('Sign Up',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.kPrimary,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
