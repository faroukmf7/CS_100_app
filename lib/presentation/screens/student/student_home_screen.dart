// lib/presentation/screens/student/student_home_screen.dart
//
// CHANGE: StatefulWidget → StatelessWidget.
//
// WHY: State field declarations like:
//   final _auth = Get.find<AuthController>();
// run during State construction, which happens mid-navigation-push.
// At that moment GetX's route machinery may not have confirmed the
// controller is active on the new route. With lazyPut this caused
// _debugLocked. Even with permanent:true it is bad practice.
//
// FIX: Call Get.find<>() inside build() — always safe because build()
// only runs when the widget is fully in the tree and all controllers
// are confirmed active.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/class_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/class_card.dart';
import '../../widgets/stat_card.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ All finds inside build() — guaranteed safe
    final auth       = Get.find<AuthController>();
    final classes    = Get.find<ClassController>();
    final attendance = Get.find<AttendanceController>();
    final themeCtrl  = Get.find<ThemeController>();

    final user  = auth.currentUser.value!;
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (classes.classList.isEmpty && !classes.isLoading.value) {
        classes.fetchClasses();
      }
      if (attendance.history.isEmpty && !attendance.isLoadingHistory.value) {
        attendance.fetchHistory(user.id);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await classes.fetchClasses();
            await attendance.fetchHistory(user.id);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──────────────────────────────────────
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.kPrimary,
                            child: Text(user.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  fontFamily: 'Nunito',
                                )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello, ${user.firstname}! 👋',
                                    style: theme.textTheme.titleMedium),
                                Text(user.studentId,
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Obx(() => IconButton(
                            icon: Icon(themeCtrl.isDark.value
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded),
                            onPressed: themeCtrl.toggleTheme,
                          )),
                          IconButton(
                            icon: const Icon(Icons.person_outline_rounded),
                            onPressed: () => Get.toNamed(AppRoutes.profile),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 28),

                      // ── Stats ────────────────────────────────────────────
                      Obx(() {
                        final total   = attendance.history.length;
                        final present = attendance.history
                            .where((a) => a.withinRadius)
                            .length;
                        final rate =
                            AppFormatters.attendanceRate(present, total);
                        return Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                value: '$present',
                                label: 'Present',
                                icon: Icons.check_circle_outline_rounded,
                                color: AppTheme.kSecondary,
                              ).animate(delay: 100.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms)
                                  .fadeIn(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: '${rate.toStringAsFixed(0)}%',
                                label: 'Rate',
                                icon: Icons.bar_chart_rounded,
                                color: AppTheme.kPrimary,
                              ).animate(delay: 150.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms)
                                  .fadeIn(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: '${classes.classList.length}',
                                label: 'Classes',
                                icon: Icons.class_outlined,
                                color: AppTheme.kAccent,
                              ).animate(delay: 200.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms)
                                  .fadeIn(),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 28),

                      // ── Offline sync banner ──────────────────────────────
                      Obx(() {
                        if (attendance.offlineCount.value == 0) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: attendance.syncOffline,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.kWarning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.kWarning.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    color: AppTheme.kWarning, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${attendance.offlineCount.value} check-in(s) pending sync. Tap to sync.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.kWarning,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      Text('Today\'s Classes',
                              style: theme.textTheme.titleLarge)
                          .animate(delay: 250.ms)
                          .fadeIn(),
                      const SizedBox(height: 4),
                      Text(AppFormatters.formatDate(DateTime.now()),
                              style: theme.textTheme.bodySmall)
                          .animate(delay: 270.ms)
                          .fadeIn(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Class list ───────────────────────────────────────────────
              Obx(() {
                if (classes.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (classes.classList.isEmpty) {
                  return const SliverFillRemaining(child: _EmptyClasses());
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final cls = classes.classList[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClassCard(
                            classModel: cls,
                            isStudent: true,
                            onTap: () {
                              classes.selectedClass.value = cls;
                              Get.toNamed(AppRoutes.classDetail);
                            },
                            onCheckIn: () {
                              classes.selectedClass.value = cls;
                              Get.toNamed(AppRoutes.checkIn);
                            },
                          )
                              .animate(
                                  delay: Duration(milliseconds: 50 * i))
                              .slideY(
                                  begin: 0.15,
                                  end: 0,
                                  duration: 350.ms,
                                  curve: Curves.easeOut)
                              .fadeIn(),
                        );
                      },
                      childCount: classes.classList.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _StudentBottomNav(),
    );
  }
}

class _EmptyClasses extends StatelessWidget {
  const _EmptyClasses();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No classes yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Your classes will appear here once added by your rep.',
            style: TextStyle(color: AppTheme.kTextSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StudentBottomNav extends StatelessWidget {
  const _StudentBottomNav();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppTheme.kDivider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: true,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () => Get.toNamed(AppRoutes.history)),
              _NavItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan QR',
                  onTap: () => Get.toNamed(AppRoutes.qrScan)),
              _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () => Get.toNamed(AppRoutes.profile)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppTheme.kPrimary : AppTheme.kTextSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Nunito',
              )),
        ],
      ),
    );
  }
}
