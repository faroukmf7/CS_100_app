// lib/presentation/screens/admin/admin_home_screen.dart
//
// Same fix as student_home_screen: Get.find() moved inside build().

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/class_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/class_card.dart';
import '../../widgets/stat_card.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth    = Get.find<AuthController>();
    final classes = Get.find<ClassController>();
    final theme   = Get.find<ThemeController>();

    final user = auth.currentUser.value!;
    final t    = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (classes.classList.isEmpty && !classes.isLoading.value) {
        classes.fetchClasses();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: classes.fetchClasses,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    fontFamily: 'Nunito')),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Admin Dashboard',
                                    style: t.textTheme.bodySmall),
                                Text(user.fullName,
                                    style: t.textTheme.titleMedium),
                              ],
                            ),
                          ),
                          Obx(() => IconButton(
                            icon: Icon(theme.isDark.value
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded),
                            onPressed: theme.toggleTheme,
                          )),
                          IconButton(
                            icon: const Icon(Icons.bar_chart_rounded),
                            onPressed: () => Get.toNamed(AppRoutes.analytics),
                            tooltip: 'Analytics',
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_outline_rounded),
                            onPressed: () => Get.toNamed(AppRoutes.profile),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 28),

                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              value: '${classes.classList.length}',
                              label: 'Total Classes',
                              icon: Icons.class_outlined,
                              color: AppTheme.kPrimary,
                            ).animate(delay: 100.ms)
                                .slideY(begin: 0.2, end: 0, duration: 400.ms)
                                .fadeIn(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              value:
                                  '${classes.classList.where((c) => c.isCurrentlyActive).length}',
                              label: 'Active Now',
                              icon: Icons.sensors_rounded,
                              color: AppTheme.kSecondary,
                            ).animate(delay: 150.ms)
                                .slideY(begin: 0.2, end: 0, duration: 400.ms)
                                .fadeIn(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              value:
                                  '${classes.classList.where((c) => !c.isActive).length}',
                              label: 'Inactive',
                              icon: Icons.pause_circle_outline_rounded,
                              color: AppTheme.kTextSecondary,
                            ).animate(delay: 200.ms)
                                .slideY(begin: 0.2, end: 0, duration: 400.ms)
                                .fadeIn(),
                          ),
                        ],
                      )),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Classes',
                              style: t.textTheme.titleLarge),
                          TextButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Class'),
                            onPressed: () =>
                                Get.toNamed(AppRoutes.createClass),
                          ),
                        ],
                      ).animate(delay: 250.ms).fadeIn(),

                      const SizedBox(height: 4),
                      Text(AppFormatters.formatDate(DateTime.now()),
                              style: t.textTheme.bodySmall)
                          .animate(delay: 270.ms)
                          .fadeIn(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              Obx(() {
                if (classes.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (classes.classList.isEmpty) {
                  return const SliverFillRemaining(child: _EmptyAdmin());
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
                            isStudent: false,
                            onTap: () {
                              classes.selectedClass.value = cls;
                              Get.toNamed(AppRoutes.classDetail);
                            },
                            onEdit: () {
                              classes.prepareEditForm(cls);
                              Get.toNamed(AppRoutes.createClass,
                                  arguments: {
                                    'editing': true,
                                    'id': cls.id
                                  });
                            },
                            onDelete: () => _confirmDelete(cls.id, cls.name, classes),
                            onViewReport: () {
                              classes.selectedClass.value = cls;
                              Get.toNamed(AppRoutes.report);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createClass),
        backgroundColor: AppTheme.kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Class',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
      ),
      bottomNavigationBar: const _AdminBottomNav(),
    );
  }

  void _confirmDelete(int id, String name, ClassController classes) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Class'),
      content: Text(
          'Are you sure you want to delete "$name"? This cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            classes.deleteClass(id);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kError),
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}

class _EmptyAdmin extends StatelessWidget {
  const _EmptyAdmin();
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
          const Text('Tap the button below to create your first class.',
              style: TextStyle(
                  color: AppTheme.kTextSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Class'),
            onPressed: () => Get.toNamed(AppRoutes.createClass),
          ),
        ],
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppTheme.kDivider)),
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
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  onTap: () => Get.toNamed(AppRoutes.analytics)),
              _NavItem(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Add Class',
                  onTap: () => Get.toNamed(AppRoutes.createClass)),
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
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontFamily: 'Nunito')),
        ],
      ),
    );
  }
}
