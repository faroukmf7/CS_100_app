// lib/presentation/screens/student/check_in_screen.dart
// ─────────────────────────────────────────
// The heart of the app. This screen:
//   1. Shows class details + map preview
//   2. Triggers GPS → distance calculation → radius check
//   3. Provides real-time green/red visual feedback
//   4. QR code fallback option
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/attendance_model.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/class_controller.dart';
import '../../widgets/app_button.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classCtrl  = Get.find<ClassController>();
    final attCtrl    = Get.find<AttendanceController>();
    final authCtrl   = Get.find<AuthController>();
    final cls        = classCtrl.selectedClass.value!;
    final user       = authCtrl.currentUser.value!;
    final theme      = Theme.of(context);
    final mapCtrl    = MapController();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(cls.name),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            attCtrl.resetCheckInState();
            Get.back();
          },
        ),
        actions: [
          // QR backup
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'QR Code Check-in',
            onPressed: () => Get.toNamed(AppRoutes.qrScan),
          ),
        ],
      ),
      body: Obx(() {
        final state = attCtrl.checkInState.value;

        // ── SUCCESS state ──────────────────────────────────────────────────
        if (state == CheckInState.success) {
          return _SuccessView(
            className: cls.name,
            distance: attCtrl.lastDistance.value,
            onDone: () {
              attCtrl.resetCheckInState();
              Get.back();
            },
          );
        }

        // ── Normal + Error + Loading states ───────────────────────────────
        return SingleChildScrollView(
          child: Column(
            children: [
              // ── Map preview ───────────────────────────────────────────────
              _MapPreview(
                classLat: cls.classLat,
                classLng: cls.classLng,
                radiusM:  cls.radiusMetres,
                mapCtrl:  mapCtrl,
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Class info ──────────────────────────────────────────
                    _ClassInfoCard(cls: cls).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 20),

                    // ── Distance indicator (updates after attempt) ──────────
                    if (state == CheckInState.error || state == CheckInState.success)
                      _DistanceIndicator(
                        distanceM:    attCtrl.lastDistance.value,
                        withinRadius: attCtrl.lastWithinRadius.value,
                        radiusM:      cls.radiusMetres,
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                    if (state == CheckInState.error)
                      const SizedBox(height: 16),

                    // ── Error message ─────────────────────────────────────────
                    if (state == CheckInState.error)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.kError.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.kError.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTheme.kError, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                attCtrl.statusMessage.value,
                                style: const TextStyle(
                                  color: AppTheme.kError, fontSize: 13,
                                  fontWeight: FontWeight.w600, fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.2, end: 0, duration: 300.ms).fadeIn(),

                    const SizedBox(height: 24),

                    // ── Loading state message ─────────────────────────────────
                    if (state == CheckInState.fetchingLocation || state == CheckInState.calculating)
                      _LoadingIndicator(message: attCtrl.statusMessage.value)
                          .animate().fadeIn(),

                    if (state == CheckInState.idle || state == CheckInState.error)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // GPS check-in button
                          AppButton(
                            label: 'Check In with GPS',
                            icon: Icons.my_location_rounded,
                            isLoading: false,
                            onPressed: () => attCtrl.checkIn(
                              classModel:  cls,
                              studentId:   user.id,
                              studentName: user.fullName,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // QR fallback
                          OutlinedButton.icon(
                            icon: const Icon(Icons.qr_code_rounded, size: 18),
                            label: const Text('Use QR Code Instead'),
                            onPressed: () => Get.toNamed(AppRoutes.qrScan),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'You must be within ${cls.radiusMetres.toStringAsFixed(0)}m of the classroom',
                              style: const TextStyle(
                                fontSize: 12, color: AppTheme.kTextSecondary, fontFamily: 'Nunito',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Map preview with classroom marker + radius circle ──────────────────────
class _MapPreview extends StatelessWidget {
  final double classLat, classLng, radiusM;
  final MapController mapCtrl;
  const _MapPreview({required this.classLat, required this.classLng, required this.radiusM, required this.mapCtrl});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(classLat, classLng);
    return SizedBox(
      height: 220,
      child: FlutterMap(
        mapController: mapCtrl,
        options: MapOptions(
          initialCenter: point,
          initialZoom: 17,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.attendease.app',
          ),
          CircleLayer(
            circles: [
              CircleMarker(
                point: point,
                radius: radiusM,
                useRadiusInMeter: true,
                color: AppTheme.kPrimary.withOpacity(0.15),
                borderStrokeWidth: 2,
                borderColor: AppTheme.kPrimary,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.kPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.kPrimary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Class info summary card ──────────────────────────────────────────────────
class _ClassInfoCard extends StatelessWidget {
  final dynamic cls;
  const _ClassInfoCard({required this.cls});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.class_rounded, color: AppTheme.kPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.courseCode, style: const TextStyle(fontSize: 12, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
                    Text(cls.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
                  ],
                ),
              ),
              // Active badge
              if (cls.isCurrentlyActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.kSecondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.kSecondary, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      const Text('Live', style: TextStyle(fontSize: 11, color: AppTheme.kSecondary, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(icon: Icons.schedule_rounded, label: cls.timeRange),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.calendar_today_rounded, label: cls.dayName),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.radar_rounded, label: '${cls.radiusMetres.toStringAsFixed(0)}m'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.kDivider,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.kTextSecondary),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito'), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

// ── Distance visual indicator (green/red) ─────────────────────────────────────
class _DistanceIndicator extends StatelessWidget {
  final double distanceM;
  final bool withinRadius;
  final double radiusM;
  const _DistanceIndicator({required this.distanceM, required this.withinRadius, required this.radiusM});

  @override
  Widget build(BuildContext context) {
    final color  = withinRadius ? AppTheme.kSecondary : AppTheme.kError;
    final icon   = withinRadius ? Icons.check_circle_rounded : Icons.location_off_rounded;
    final label  = withinRadius ? 'Within range' : 'Out of range';
    final pct    = (math.min(distanceM / radiusM, 2.0) / 2.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Nunito')),
                    Text(GeoUtils.formatDistance(distanceM),
                        style: TextStyle(color: color.withOpacity(0.8), fontSize: 13, fontFamily: 'Nunito')),
                  ],
                ),
              ),
              Text(
                '${distanceM.toStringAsFixed(0)}m',
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Nunito'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: withinRadius ? (distanceM / radiusM).clamp(0.0, 1.0) : 1.0,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0m', style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontFamily: 'Nunito')),
              Text('Limit: ${radiusM.toStringAsFixed(0)}m', style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontFamily: 'Nunito')),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Loading indicator ─────────────────────────────────────────────────────────
class _LoadingIndicator extends StatelessWidget {
  final String message;
  const _LoadingIndicator({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.kPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.kPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(message,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Nunito'))),
        ],
      ),
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String className;
  final double distance;
  final VoidCallback onDone;
  const _SuccessView({required this.className, required this.distance, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppTheme.kSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
            )
                .animate()
                .scale(delay: 100.ms, duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 28),

            Text('Checked In! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))
                .animate(delay: 400.ms).slideY(begin: 0.2, end: 0, duration: 300.ms).fadeIn(),

            const SizedBox(height: 10),

            Text('You\'ve successfully checked into\n$className',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppTheme.kTextSecondary, fontFamily: 'Nunito'))
                .animate(delay: 500.ms).fadeIn(),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.kSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Distance: ${distance.toStringAsFixed(0)}m from classroom',
                style: const TextStyle(fontSize: 13, color: AppTheme.kSecondary, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
              ),
            ).animate(delay: 600.ms).fadeIn(),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text('Done'),
              ),
            ).animate(delay: 700.ms).slideY(begin: 0.2, end: 0, duration: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
