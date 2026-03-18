// lib/presentation/screens/shared/class_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/class_controller.dart';

class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classCtrl = Get.find<ClassController>();
    final authCtrl  = Get.find<AuthController>();
    final cls       = classCtrl.selectedClass.value!;
    final user      = authCtrl.currentUser.value!;
    final theme     = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(cls.courseCode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (user.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                classCtrl.prepareEditForm(cls);
                Get.toNamed(AppRoutes.createClass, arguments: {'editing': true, 'id': cls.id});
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Map header ─────────────────────────────────────────────────
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(cls.classLat, cls.classLng),
                  initialZoom: 17,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.attendease.app',
                  ),
                  CircleLayer(circles: [
                    CircleMarker(
                      point: LatLng(cls.classLat, cls.classLng),
                      radius: cls.radiusMetres,
                      useRadiusInMeter: true,
                      color: AppTheme.kPrimary.withOpacity(0.15),
                      borderStrokeWidth: 2,
                      borderColor: AppTheme.kPrimary,
                    ),
                  ]),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(cls.classLat, cls.classLng),
                      width: 40, height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.kPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppTheme.kPrimary.withOpacity(0.4), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ──────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cls.courseCode, style: theme.textTheme.bodySmall),
                            Text(cls.name, style: theme.textTheme.headlineSmall),
                          ],
                        ),
                      ),
                      if (cls.isCurrentlyActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.kSecondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppTheme.kSecondary, shape: BoxShape.circle)),
                              const SizedBox(width: 5),
                              const Text('In Session', style: TextStyle(color: AppTheme.kSecondary, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito')),
                            ],
                          ),
                        ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: 20),

                  // ── Info grid ──────────────────────────────────────────────
                  _InfoGrid(cls: cls).animate(delay: 100.ms).fadeIn(),

                  if (cls.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Description', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(cls.description, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.kTextSecondary)),
                  ],

                  const SizedBox(height: 24),

                  // ── QR Code (admin can show students this) ─────────────────
                  if (user.isAdmin) ...[
                    Text('QR Code', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Students can scan this as a GPS fallback', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 14),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.kDivider),
                        ),
                        child: QrImageView(
                          data: 'attendease:${cls.id}:${cls.courseCode}',
                          version: QrVersions.auto,
                          size: 180,
                        ),
                      ),
                    ).animate(delay: 200.ms).scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'attendease:${cls.id}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.kTextSecondary, fontFamily: 'Nunito'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Check-in / Report button ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: user.isAdmin
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.analytics_outlined),
                            label: const Text('View Attendance Report'),
                            onPressed: () => Get.toNamed(AppRoutes.report),
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Check In Now'),
                            onPressed: () => Get.toNamed(AppRoutes.checkIn),
                          ),
                  ).animate(delay: 300.ms).slideY(begin: 0.2, end: 0, duration: 300.ms).fadeIn(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final dynamic cls;
  const _InfoGrid({required this.cls});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: [
        _Tile(icon: Icons.person_outline_rounded, label: 'Instructor', value: cls.instructor),
        _Tile(icon: Icons.calendar_today_rounded, label: 'Day', value: cls.dayName),
        _Tile(icon: Icons.schedule_rounded, label: 'Time', value: cls.timeRange),
        _Tile(icon: Icons.radar_rounded, label: 'Radius', value: '${cls.radiusMetres.toStringAsFixed(0)}m'),
        _Tile(icon: Icons.school_outlined, label: 'Semester', value: cls.semester.isNotEmpty ? cls.semester : 'N/A'),
        _Tile(icon: Icons.timer_outlined, label: 'Duration', value: AppFormatters.formatDuration(cls.classDuration)),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Tile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.kDivider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.kPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito'), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
