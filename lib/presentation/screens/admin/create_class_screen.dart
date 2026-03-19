// lib/presentation/screens/admin/create_class_screen.dart
// ─────────────────────────────────────────
// FIX: formKey now lives here as a StatefulWidget State field, not in the
// controller. This prevents "Multiple widgets used the same GlobalKey".
// Controller methods createClass() and updateClass() now receive the key.
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/class_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  // formKey lives here — created once per widget instance, disposed with it.
  final _formKey = GlobalKey<FormState>();

  late final ClassController _ctrl;
  late final AuthController  _auth;
  late final bool  _isEditing;
  late final int   _classId;

  @override
  void initState() {
    super.initState();
    _ctrl      = Get.find<ClassController>();
    _auth      = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _isEditing = args['editing'] == true;
    _classId   = args['id'] as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Class' : 'New Class'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── Section: Basic Info ───────────────────────────────────────
              _SectionHeader(title: 'Class Information', icon: Icons.info_outline_rounded)
                  .animate().fadeIn(),

              const SizedBox(height: 14),

              AppTextField(
                controller: _ctrl.nameCtrl,
                label: 'Class Name',
                hint: 'e.g. Introduction to Computer Science',
                prefixIcon: Icons.class_rounded,
                validator: (v) => AppValidators.validateRequired(v, 'Class name'),
              ).animate(delay: 50.ms).fadeIn(),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _ctrl.courseCodeCtrl,
                      label: 'Course Code',
                      hint: 'CS 100',
                      prefixIcon: Icons.tag_rounded,
                      validator: (v) => AppValidators.validateRequired(v, 'Course code'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _ctrl.semesterCtrl,
                      label: 'Semester',
                      hint: '2025/26 Sem 1',
                      prefixIcon: Icons.calendar_month_outlined,
                    ),
                  ),
                ],
              ).animate(delay: 80.ms).fadeIn(),

              const SizedBox(height: 14),

              AppTextField(
                controller: _ctrl.instructorCtrl,
                label: 'Instructor',
                hint: 'Prof. Kofi Asante',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) => AppValidators.validateRequired(v, 'Instructor'),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 14),

              AppTextField(
                controller: _ctrl.descCtrl,
                label: 'Description (optional)',
                hint: 'Brief description…',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
              ).animate(delay: 120.ms).fadeIn(),

              const SizedBox(height: 24),

              // ── Section: Schedule ─────────────────────────────────────────
              _SectionHeader(title: 'Schedule', icon: Icons.schedule_rounded)
                  .animate(delay: 140.ms).fadeIn(),

              const SizedBox(height: 14),

              Obx(() => _DayPicker(
                selectedDay: _ctrl.selectedDay.value,
                onSelect: (d) => _ctrl.selectedDay.value = d,
              )).animate(delay: 160.ms).fadeIn(),

              const SizedBox(height: 14),

              Obx(() => Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Start Time',
                      hour: _ctrl.startHour.value,
                      minute: _ctrl.startMinute.value,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: _ctrl.startHour.value,
                              minute: _ctrl.startMinute.value),
                        );
                        if (t != null) {
                          _ctrl.startHour.value   = t.hour;
                          _ctrl.startMinute.value = t.minute;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.kTextSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'End Time',
                      hour: _ctrl.endHour.value,
                      minute: _ctrl.endMinute.value,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: _ctrl.endHour.value,
                              minute: _ctrl.endMinute.value),
                        );
                        if (t != null) {
                          _ctrl.endHour.value   = t.hour;
                          _ctrl.endMinute.value = t.minute;
                        }
                      },
                    ),
                  ),
                ],
              )).animate(delay: 180.ms).fadeIn(),

              const SizedBox(height: 24),

              // ── Section: Location ─────────────────────────────────────────
              _SectionHeader(title: 'Classroom Location', icon: Icons.location_on_rounded)
                  .animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 8),

              Text(
                'Tap on the map to pin the exact classroom location. '
                    'Students must be within the radius to check in.',
                style: theme.textTheme.bodySmall,
              ).animate(delay: 210.ms).fadeIn(),

              const SizedBox(height: 14),

              Obx(() => _RadiusSlider(
                value: double.tryParse(_ctrl.radiusCtrl.text) ?? 50,
                onChanged: (v) => _ctrl.radiusCtrl.text = v.toStringAsFixed(0),
              )).animate(delay: 220.ms).fadeIn(),

              const SizedBox(height: 14),

              _LocationPicker(ctrl: _ctrl).animate(delay: 240.ms).fadeIn(),

              const SizedBox(height: 8),

              Obx(() => _ctrl.locationPicked.value
                  ? Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.kSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.kSecondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.kSecondary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${_ctrl.pickedLat.value.toStringAsFixed(6)}, '
                            'Lng: ${_ctrl.pickedLng.value.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', color: AppTheme.kSecondary),
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.kWarning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.kWarning.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.kWarning, size: 16),
                    SizedBox(width: 8),
                    Text('Tap map to set classroom location',
                        style: TextStyle(fontSize: 12, fontFamily: 'Nunito', color: AppTheme.kWarning)),
                  ],
                ),
              )),

              const SizedBox(height: 32),

              // ── Save button — passes _formKey to controller ────────────────
              Obx(() => AppButton(
                label:    _isEditing ? 'Save Changes' : 'Create Class',
                icon:     _isEditing ? Icons.save_rounded : Icons.check_rounded,
                isLoading: _ctrl.isSaving.value,
                onPressed: () => _isEditing
                    ? _ctrl.updateClass(_classId, _formKey)
                    : _ctrl.createClass(_auth.currentUser.value!.id, _formKey),
              )).animate(delay: 280.ms).slideY(begin: 0.2, end: 0, duration: 300.ms).fadeIn(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets (unchanged from original) ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.kPrimary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: AppTheme.kPrimary, fontFamily: 'Nunito',
        )),
      ],
    );
  }
}

class _DayPicker extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onSelect;
  const _DayPicker({required this.selectedDay, required this.onSelect});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_days.length, (i) {
        final isSelected = selectedDay == i;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.kPrimary : AppTheme.kDivider,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _days[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.kTextSecondary,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final int hour, minute;
  final VoidCallback onTap;
  const _TimeTile({required this.label, required this.hour, required this.minute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.kPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.kPrimary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
            const SizedBox(height: 4),
            Text(
              AppFormatters.timeOfDayToString(hour, minute),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.kPrimary, fontFamily: 'Nunito'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadiusSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _RadiusSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Check-in Radius', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${value.toStringAsFixed(0)}m',
                  style: const TextStyle(color: AppTheme.kPrimary, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
            ),
          ],
        ),
        Slider(
          value: value.clamp(10, 200),
          min: 10,
          max: 200,
          divisions: 38,
          activeColor: AppTheme.kPrimary,
          onChanged: onChanged,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10m (tight)',  style: TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
            Text('200m (loose)', style: TextStyle(fontSize: 11, color: AppTheme.kTextSecondary, fontFamily: 'Nunito')),
          ],
        ),
      ],
    );
  }
}

class _LocationPicker extends StatefulWidget {
  final ClassController ctrl;
  const _LocationPicker({required this.ctrl});

  @override
  State<_LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<_LocationPicker> {
  final _mapCtrl = MapController();
  final _center  = const LatLng(5.6037, -0.1870); // Default: Accra, Ghana

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasPick = widget.ctrl.locationPicked.value;
      final pickedPoint = hasPick
          ? LatLng(widget.ctrl.pickedLat.value, widget.ctrl.pickedLng.value)
          : null;

      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          child: FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: pickedPoint ?? _center,
              initialZoom: 16,
              onTap: (_, latlng) {
                widget.ctrl.setPickedLocation(latlng.latitude, latlng.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.attendease.app',
              ),
              if (pickedPoint != null)
                CircleLayer(circles: [
                  CircleMarker(
                    point: pickedPoint,
                    radius: widget.ctrl.radiusCtrl.text.isNotEmpty
                        ? double.tryParse(widget.ctrl.radiusCtrl.text) ?? 50
                        : 50,
                    useRadiusInMeter: true,
                    color: AppTheme.kPrimary.withOpacity(0.15),
                    borderStrokeWidth: 2,
                    borderColor: AppTheme.kPrimary,
                  ),
                ]),
              if (pickedPoint != null)
                MarkerLayer(markers: [
                  Marker(
                    point: pickedPoint,
                    width: 40,
                    height: 40,
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
              if (!hasPick)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Tap to pin classroom',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Nunito')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
