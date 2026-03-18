// lib/data/models/class_model.dart
// ─────────────────────────────────────────
// Represents a class/course session with location data.
// The classLat/classLng are set by admin at classroom and
// compared against student's live location during check-in.
// ─────────────────────────────────────────

import 'package:intl/intl.dart';

class ClassModel {
  final int id;
  final String name;
  final String description;
  final String courseCode;
  final String instructor;
  final double classLat;       // Stored classroom latitude (set by admin)
  final double classLng;       // Stored classroom longitude (set by admin)
  final double radiusMetres;   // Configurable check-in radius (default 50m)
  final int dayOfWeek;         // 0=Mon … 6=Sun
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String semester;
  final int createdById;
  final DateTime? createdAt;
  final bool isActive;

  const ClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.courseCode,
    required this.instructor,
    required this.classLat,
    required this.classLng,
    required this.radiusMetres,
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.semester,
    required this.createdById,
    this.createdAt,
    this.isActive = true,
  });

  String get dayName {
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return dayOfWeek >= 0 && dayOfWeek < 7 ? days[dayOfWeek] : 'Unknown';
  }

  String get startTimeStr {
    final dt = DateTime(2000, 1, 1, startHour, startMinute);
    return DateFormat('h:mm a').format(dt);
  }

  String get endTimeStr {
    final dt = DateTime(2000, 1, 1, endHour, endMinute);
    return DateFormat('h:mm a').format(dt);
  }

  String get timeRange => '$startTimeStr – $endTimeStr';

  /// Returns true if this class is currently in session (same day + within time window).
  bool get isCurrentlyActive {
    final now = DateTime.now();
    final todayDow = now.weekday - 1; // DateTime.weekday is 1=Mon
    if (todayDow != dayOfWeek) return false;
    final startMins = startHour * 60 + startMinute;
    final endMins   = endHour   * 60 + endMinute;
    final nowMins   = now.hour  * 60 + now.minute;
    return nowMins >= startMins && nowMins <= endMins;
  }

  Duration get classDuration => Duration(
    minutes: (endHour * 60 + endMinute) - (startHour * 60 + startMinute),
  );

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    id:            json['id']           as int? ?? 0,
    name:          json['name']         as String? ?? '',
    description:   json['description']  as String? ?? '',
    courseCode:    json['course_code']  as String? ?? '',
    instructor:    json['instructor']   as String? ?? '',
    classLat:      double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
    classLng:      double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
    radiusMetres:  double.tryParse(json['radius_m']?.toString() ?? '50') ?? 50.0,
    dayOfWeek:     json['day_of_week']  as int? ?? 0,
    startHour:     json['start_hour']   as int? ?? 8,
    startMinute:   json['start_minute'] as int? ?? 0,
    endHour:       json['end_hour']     as int? ?? 9,
    endMinute:     json['end_minute']   as int? ?? 0,
    semester:      json['semester']     as String? ?? '',
    createdById:   json['created_by']   as int? ?? 0,
    isActive:      (json['is_active']   as int? ?? 1) == 1,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'course_code': courseCode, 'instructor': instructor,
    'lat': classLat, 'lng': classLng, 'radius_m': radiusMetres,
    'day_of_week': dayOfWeek,
    'start_hour': startHour, 'start_minute': startMinute,
    'end_hour': endHour, 'end_minute': endMinute,
    'semester': semester, 'created_by': createdById,
    'is_active': isActive ? 1 : 0,
  };

  ClassModel copyWith({
    int? id, String? name, String? description, String? courseCode,
    String? instructor, double? classLat, double? classLng,
    double? radiusMetres, int? dayOfWeek,
    int? startHour, int? startMinute, int? endHour, int? endMinute,
    String? semester, int? createdById, bool? isActive,
  }) => ClassModel(
    id: id ?? this.id, name: name ?? this.name,
    description: description ?? this.description,
    courseCode: courseCode ?? this.courseCode,
    instructor: instructor ?? this.instructor,
    classLat: classLat ?? this.classLat, classLng: classLng ?? this.classLng,
    radiusMetres: radiusMetres ?? this.radiusMetres,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    startHour: startHour ?? this.startHour, startMinute: startMinute ?? this.startMinute,
    endHour: endHour ?? this.endHour, endMinute: endMinute ?? this.endMinute,
    semester: semester ?? this.semester, createdById: createdById ?? this.createdById,
    isActive: isActive ?? this.isActive,
  );
}
