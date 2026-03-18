// lib/presentation/controllers/class_controller.dart
// ─────────────────────────────────────────
// Manages class list, creation, editing, deletion.
// Admin/Rep only for create/edit/delete.
// Both roles can view class list.
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/class_model.dart';
import '../../data/repositories/class_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';

class ClassController extends GetxController {
  final ClassRepository _classRepo;
  ClassController(this._classRepo);

  // ── Observables ───────────────────────────────────────────────────────────
  final RxList<ClassModel>  classList    = <ClassModel>[].obs;
  final RxBool              isLoading    = false.obs;
  final RxBool              isSaving     = false.obs;
  final Rx<ClassModel?>     selectedClass = Rx<ClassModel?>(null);

  // Create/Edit form
  final nameCtrl        = TextEditingController();
  final descCtrl        = TextEditingController();
  final courseCodeCtrl  = TextEditingController();
  final instructorCtrl  = TextEditingController();
  final radiusCtrl      = TextEditingController(text: '50');
  final semesterCtrl    = TextEditingController();
  final formKey         = GlobalKey<FormState>();

  final RxDouble pickedLat    = 0.0.obs;
  final RxDouble pickedLng    = 0.0.obs;
  final RxInt    selectedDay  = 0.obs;
  final RxInt    startHour    = 8.obs;
  final RxInt    startMinute  = 0.obs;
  final RxInt    endHour      = 9.obs;
  final RxInt    endMinute    = 0.obs;
  final RxBool   locationPicked = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  @override
  void onClose() {
    nameCtrl.dispose(); descCtrl.dispose(); courseCodeCtrl.dispose();
    instructorCtrl.dispose(); radiusCtrl.dispose(); semesterCtrl.dispose();
    super.onClose();
  }

  // ── Fetch All ─────────────────────────────────────────────────────────────
  Future<void> fetchClasses() async {
    isLoading.value = true;
    final result = await _classRepo.getClasses();
    isLoading.value = false;
    if (result['success'] == true) {
      classList.value = result['classes'] as List<ClassModel>;
    } else {
      _showError(result['message'] as String? ?? AppStrings.unknownError);
    }
  }

  // ── Create Class ──────────────────────────────────────────────────────────
  Future<void> createClass(int adminId) async {
    if (!formKey.currentState!.validate()) return;
    if (!locationPicked.value) {
      _showError('Please pick the classroom location on the map.');
      return;
    }
    isSaving.value = true;
    final model = ClassModel(
      id: 0,
      name:          nameCtrl.text.trim(),
      description:   descCtrl.text.trim(),
      courseCode:    courseCodeCtrl.text.trim(),
      instructor:    instructorCtrl.text.trim(),
      classLat:      pickedLat.value,
      classLng:      pickedLng.value,
      radiusMetres:  double.tryParse(radiusCtrl.text) ?? 50.0,
      dayOfWeek:     selectedDay.value,
      startHour:     startHour.value,
      startMinute:   startMinute.value,
      endHour:       endHour.value,
      endMinute:     endMinute.value,
      semester:      semesterCtrl.text.trim(),
      createdById:   adminId,
    );
    final result = await _classRepo.createClass(model);
    isSaving.value = false;
    if (result['success'] == true) {
      classList.add(result['class'] as ClassModel);
      Get.back();
      _showSuccess(result['message'] as String);
      _clearForm();
    } else {
      _showError(result['message'] as String);
    }
  }

  // ── Update Class ──────────────────────────────────────────────────────────
  Future<void> updateClass(int classId) async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    final model = ClassModel(
      id: classId,
      name:        nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      courseCode:  courseCodeCtrl.text.trim(),
      instructor:  instructorCtrl.text.trim(),
      classLat:    pickedLat.value,
      classLng:    pickedLng.value,
      radiusMetres: double.tryParse(radiusCtrl.text) ?? 50.0,
      dayOfWeek:   selectedDay.value,
      startHour:   startHour.value,
      startMinute: startMinute.value,
      endHour:     endHour.value,
      endMinute:   endMinute.value,
      semester:    semesterCtrl.text.trim(),
      createdById: 0,
    );
    final result = await _classRepo.updateClass(model);
    isSaving.value = false;
    if (result['success'] == true) {
      final idx = classList.indexWhere((c) => c.id == classId);
      if (idx >= 0) classList[idx] = model;
      Get.back();
      _showSuccess(result['message'] as String);
    } else {
      _showError(result['message'] as String);
    }
  }

  // ── Delete Class ──────────────────────────────────────────────────────────
  Future<void> deleteClass(int id) async {
    final result = await _classRepo.deleteClass(id);
    if (result['success'] == true) {
      classList.removeWhere((c) => c.id == id);
      _showSuccess('Class removed.');
    } else {
      _showError(result['message'] as String);
    }
  }

  // ── Pre-fill edit form ────────────────────────────────────────────────────
  void prepareEditForm(ClassModel c) {
    nameCtrl.text       = c.name;
    descCtrl.text       = c.description;
    courseCodeCtrl.text = c.courseCode;
    instructorCtrl.text = c.instructor;
    radiusCtrl.text     = c.radiusMetres.toString();
    semesterCtrl.text   = c.semester;
    pickedLat.value     = c.classLat;
    pickedLng.value     = c.classLng;
    selectedDay.value   = c.dayOfWeek;
    startHour.value     = c.startHour;
    startMinute.value   = c.startMinute;
    endHour.value       = c.endHour;
    endMinute.value     = c.endMinute;
    locationPicked.value = true;
  }

  void setPickedLocation(double lat, double lng) {
    pickedLat.value = lat;
    pickedLng.value = lng;
    locationPicked.value = true;
  }

  void _clearForm() {
    nameCtrl.clear(); descCtrl.clear(); courseCodeCtrl.clear();
    instructorCtrl.clear(); radiusCtrl.text = '50'; semesterCtrl.clear();
    pickedLat.value = 0; pickedLng.value = 0;
    locationPicked.value = false;
    selectedDay.value = 0;
  }

  void _showSuccess(String msg) => Get.snackbar('✓ Done', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF10B981),
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );

  void _showError(String msg) => Get.snackbar('Error', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFFEF4444),
    colorText: Colors.white,
    duration: const Duration(seconds: 4),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );
}
