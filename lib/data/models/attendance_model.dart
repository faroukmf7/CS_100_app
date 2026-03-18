// lib/data/models/attendance_model.dart

enum CheckInMethod { gps, qrCode, manual }
enum AttendanceStatus { present, late, absent }

class AttendanceModel {
  final int id;
  final int studentId;
  final int classId;
  final String studentName;
  final String className;
  final double studentLat;
  final double studentLng;
  final double distanceMetres;
  final bool withinRadius;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final CheckInMethod method;
  final AttendanceStatus status;
  final bool syncedToServer;

  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.studentName,
    required this.className,
    required this.studentLat,
    required this.studentLng,
    required this.distanceMetres,
    required this.withinRadius,
    required this.checkedInAt,
    this.checkedOutAt,
    required this.method,
    required this.status,
    this.syncedToServer = false,
  });

  bool get isCheckedOut => checkedOutAt != null;

  Duration? get sessionDuration => checkedOutAt != null
      ? checkedOutAt!.difference(checkedInAt)
      : null;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
    id:              json['id']              as int? ?? 0,
    studentId:       json['student_id']      as int? ?? 0,
    classId:         json['class_id']        as int? ?? 0,
    studentName:     json['student_name']    as String? ?? '',
    className:       json['class_name']      as String? ?? '',
    studentLat:      double.tryParse(json['student_lat']?.toString() ?? '0') ?? 0.0,
    studentLng:      double.tryParse(json['student_lng']?.toString() ?? '0') ?? 0.0,
    distanceMetres:  double.tryParse(json['distance_m']?.toString() ?? '0') ?? 0.0,
    withinRadius:    (json['within_radius']  as int? ?? 0) == 1,
    checkedInAt:     DateTime.tryParse(json['checked_in_at']?.toString() ?? '') ?? DateTime.now(),
    checkedOutAt:    json['checked_out_at'] != null
        ? DateTime.tryParse(json['checked_out_at'].toString())
        : null,
    method:          CheckInMethod.values.firstWhere(
      (e) => e.name == (json['method'] ?? 'gps'),
      orElse: () => CheckInMethod.gps,
    ),
    status:          AttendanceStatus.values.firstWhere(
      (e) => e.name == (json['status'] ?? 'present'),
      orElse: () => AttendanceStatus.present,
    ),
    syncedToServer:  (json['synced'] as int? ?? 1) == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'student_id': studentId, 'class_id': classId,
    'student_name': studentName, 'class_name': className,
    'student_lat': studentLat, 'student_lng': studentLng,
    'distance_m': distanceMetres, 'within_radius': withinRadius ? 1 : 0,
    'checked_in_at': checkedInAt.toIso8601String(),
    'checked_out_at': checkedOutAt?.toIso8601String(),
    'method': method.name, 'status': status.name,
    'synced': syncedToServer ? 1 : 0,
  };
}

/// Used when checking if today's attendance is already marked.
class CheckInResult {
  final bool success;
  final String message;
  final double distanceMetres;
  final bool withinRadius;
  final AttendanceModel? attendance;

  const CheckInResult({
    required this.success,
    required this.message,
    required this.distanceMetres,
    required this.withinRadius,
    this.attendance,
  });
}
