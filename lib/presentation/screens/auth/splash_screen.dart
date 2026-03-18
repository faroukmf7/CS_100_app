// lib/presentation/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    final auth = Get.find<AuthController>();
    if (auth.currentUser.value != null) {
      final user = auth.currentUser.value!;
      Get.offAllNamed(user.isAdmin ? AppRoutes.adminHome : AppRoutes.studentHome);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.how_to_reg_rounded,
                  size: 56, color: AppTheme.kPrimary),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            Text(
              AppConstants.kAppName,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                fontFamily: 'Nunito',
              ),
            )
                .animate(delay: 300.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut)
                .fadeIn(duration: 500.ms),

            const SizedBox(height: 8),

            Text(
              'Smart Class Attendance',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
              ),
            )
                .animate(delay: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut)
                .fadeIn(duration: 500.ms),

            const SizedBox(height: 60),

            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.7),
                ),
              ),
            )
                .animate(delay: 700.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
