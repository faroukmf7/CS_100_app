// lib/presentation/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // GlobalKey lives here in State — created once, destroyed with the widget.
  // See LoginScreen for full explanation of why this can't live in the controller.
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Obx(() {
            final step = auth.registerStep.value;
            return Column(
              children: [
                // ── Step indicator ──────────────────────────────────────────
                _StepIndicator(currentStep: step, totalSteps: 3),

                const SizedBox(height: 8),

                // ── Step content ────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey<int>(step),
                        child: _stepContent(step, auth, theme),
                      ),
                    ),
                  ),
                ),

                // ── Navigation buttons ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Obx(() => Row(
                    children: [
                      if (step > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: auth.isLoading.value ? null : auth.prevRegisterStep,
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: step == 2 ? 'Create Account' : 'Continue',
                          isLoading: auth.isLoading.value,
                          onPressed: step == 2 ? () => auth.register(_formKey) : auth.nextRegisterStep,
                          icon: step == 2
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                      ),
                    ],
                  )),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _stepContent(int step, AuthController auth, ThemeData theme) {
    switch (step) {
      case 0:
        return _buildStep(
          title: 'Account Details',
          subtitle: 'Your university email and student ID',
          icon: Icons.badge_outlined,
          children: [
            const SizedBox(height: 20),
            AppTextField(
              controller: auth.emailCtrl,
              label: AppStrings.email,
              hint: 'you@university.edu',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: AppValidators.validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: auth.studentIdCtrl,
              label: AppStrings.studentId,
              hint: 'e.g. 10987654',
              prefixIcon: Icons.numbers_rounded,
              validator: AppValidators.validateStudentId,
            ),
          ],
        );

      case 1:
        return _buildStep(
          title: 'Your Name',
          subtitle: 'As it appears on your student ID',
          icon: Icons.person_outline_rounded,
          children: [
            const SizedBox(height: 20),
            AppTextField(
              controller: auth.firstNameCtrl,
              label: AppStrings.firstName,
              hint: 'e.g. Kwame',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) => AppValidators.validateRequired(v, 'First name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: auth.surnameCtrl,
              label: AppStrings.surname,
              hint: 'e.g. Mensah',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) => AppValidators.validateRequired(v, 'Surname'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: auth.middleNameCtrl,
              label: AppStrings.middleName,
              hint: 'Optional',
              prefixIcon: Icons.person_outline_rounded,
            ),
          ],
        );

      case 2:
      default:
        return _buildStep(
          title: 'Set Password',
          subtitle: 'Choose a secure password (min. 6 characters)',
          icon: Icons.lock_outline_rounded,
          children: [
            const SizedBox(height: 20),
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
                  color: AppTheme.kTextSecondary, size: 20,
                ),
                onPressed: auth.togglePasswordVisibility,
              ),
            )),
            const SizedBox(height: 16),
            Obx(() => AppTextField(
              controller: auth.confirmCtrl,
              label: AppStrings.confirmPass,
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: auth.obscureConfirm.value,
              validator: (v) => AppValidators.validatePasswordMatch(v, auth.passwordCtrl.text),
              suffixIcon: IconButton(
                icon: Icon(
                  auth.obscureConfirm.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.kTextSecondary, size: 20,
                ),
                onPressed: auth.toggleConfirmVisibility,
              ),
            )),
          ],
        );
    }
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.kPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Nunito',
                  )),
                  Text(subtitle, style: const TextStyle(
                    fontSize: 13, color: AppTheme.kTextSecondary, fontFamily: 'Nunito',
                  )),
                ],
              ),
            ),
          ],
        ),
        ...children,
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final labels = ['Account', 'Name', 'Password'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive   = i == currentStep;
          final isComplete = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isComplete || isActive
                              ? AppTheme.kPrimary
                              : AppTheme.kDivider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppTheme.kPrimary : AppTheme.kTextSecondary,
                          fontFamily: 'Nunito',
                        ),
                        child: Text(labels[i]),
                      ),
                    ],
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}
