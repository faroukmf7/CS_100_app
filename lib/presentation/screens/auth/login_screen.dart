// lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey lives here in State — it is created once and destroyed when this
  // widget leaves the tree. This prevents the "GlobalKey used multiple times"
  // crash that occurred when the controller held the key and the widget tree
  // was rebuilt (e.g. on theme change via GetMaterialApp's Obx wrapper).
  final _formKey = GlobalKey<FormState>();

  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
  }

  @override
  Widget build(BuildContext context) {
    final auth = _auth;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            // Subtract both top (status bar) AND bottom (home indicator / nav bar)
            // insets. Previously only padding.top was subtracted, causing a 19px
            // overflow on devices with a bottom system inset.
            height: size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.08),

                // ── Hero section ────────────────────────────────────────────
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
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ))
                    .animate(delay: 100.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
                    .fadeIn(),

                const SizedBox(height: 6),

                Text('Sign in to track your attendance',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.kTextSecondary,
                    ))
                    .animate(delay: 150.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms)
                    .fadeIn(),

                const SizedBox(height: 40),

                // ── Form ─────────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: auth.emailCtrl,
                        label: AppStrings.email,
                        hint: 'you@university.edu',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.validateEmail,
                      ).animate(delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 400.ms).fadeIn(),

                      const SizedBox(height: 16),

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
                      )).animate(delay: 250.ms).slideY(begin: 0.2, end: 0, duration: 400.ms).fadeIn(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Forgot password (extension point)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.snackbar(
                      'Coming Soon', 'Password reset will be available soon.',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                    child: Text(AppStrings.forgotPass,
                        style: TextStyle(color: AppTheme.kPrimary, fontWeight: FontWeight.w600)),
                  ),
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 24),

                // ── Login button ──────────────────────────────────────────────
                Obx(() => AppButton(
                  label: AppStrings.login,
                  isLoading: auth.isLoading.value,
                  onPressed: () => auth.login(_formKey),
                  icon: Icons.login_rounded,
                )).animate(delay: 350.ms).slideY(begin: 0.2, end: 0, duration: 400.ms).fadeIn(),

                const SizedBox(height: 20),

                // ── Register link ─────────────────────────────────────────────
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

                // ── Role badges (info) ────────────────────────────────────────
               // _RoleInfoBadges().animate(delay: 500.ms).fadeIn(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleInfoBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.kPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.kPrimary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Roles', style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppTheme.kPrimary,
            fontFamily: 'Nunito',
          )),
          const SizedBox(height: 10),
          Row(
            children: [
              _Badge(icon: Icons.person_outline, label: 'Student', color: AppTheme.kSecondary),
              const SizedBox(width: 10),
              _Badge(icon: Icons.admin_panel_settings_outlined, label: 'Admin / Rep', color: AppTheme.kPrimary),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: color, fontFamily: 'Nunito',
          )),
        ],
      ),
    );
  }
}
