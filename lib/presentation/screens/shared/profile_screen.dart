// lib/presentation/screens/shared/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth  = Get.find<AuthController>();
    final theme = Get.find<ThemeController>();
    final user  = auth.currentUser.value!;
    final t     = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Avatar card ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.kPrimary, AppTheme.kPrimaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(user.initials,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 24,
                        fontWeight: FontWeight.w800, fontFamily: 'Nunito',
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w800, fontFamily: 'Nunito',
                          )),
                      const SizedBox(height: 2),
                      Text(user.email,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontFamily: 'Nunito')),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.isAdmin ? 'Admin / Rep' : 'Student',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // ── Info fields ─────────────────────────────────────────────────
          _Section(title: 'Account Info'),
          _ProfileTile(icon: Icons.badge_outlined, label: 'Student ID', value: user.studentId),
          _ProfileTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
          _ProfileTile(icon: Icons.security_rounded, label: 'Role', value: user.isAdmin ? 'Admin / Rep' : 'Student'),

          const SizedBox(height: 20),

          // ── Settings ────────────────────────────────────────────────────
          _Section(title: 'Settings'),
          Obx(() => _ToggleTile(
            icon: theme.isDark.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            label: 'Dark Mode',
            value: theme.isDark.value,
            onToggle: theme.toggleTheme,
          )),

          const SizedBox(height: 20),

          // ── App info ─────────────────────────────────────────────────────
          _Section(title: 'App'),
          _ProfileTile(icon: Icons.info_outline_rounded, label: 'Version', value: '1.0.0'),
          _ProfileTile(icon: Icons.code_rounded, label: 'Built with', value: 'Flutter + GetX'),

          const SizedBox(height: 28),

          // ── Logout ────────────────────────────────────────────────────────
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.kError),
            label: const Text('Log Out', style: TextStyle(color: AppTheme.kError, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            onPressed: () => _confirmLogout(auth),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.kError),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ).animate(delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 300.ms).fadeIn(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmLogout(AuthController auth) {
    Get.dialog(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Get.back(); auth.logout(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.kError),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700,
      color: AppTheme.kTextSecondary, fontFamily: 'Nunito',
      letterSpacing: 0.5,
    )),
  );
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProfileTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.kDivider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.kPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final VoidCallback onToggle;
  const _ToggleTile({required this.icon, required this.label, required this.value, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.kDivider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.kPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Nunito'))),
          Switch(value: value, onChanged: (_) => onToggle(), activeColor: AppTheme.kPrimary),
        ],
      ),
    );
  }
}
