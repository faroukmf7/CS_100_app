import 'dart:ffi';

class Classes{
  final Int id;
  final String className;
  final String description;
  final int dayOfWeek;
  final Duration startTime;
  final Duration endTime;
  final String teacher;

  //<editor-fold desc="Data Methods">
  const Classes({
    required this.id,
    required this.className,
    required this.description,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.teacher,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Classes &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          className == other.className &&
          description == other.description &&
          dayOfWeek == other.dayOfWeek &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          teacher == other.teacher);

  @override
  int get hashCode =>
      id.hashCode ^
      className.hashCode ^
      description.hashCode ^
      dayOfWeek.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      teacher.hashCode;

  @override
  String toString() {
    return 'Classes{' +
        ' id: $id,' +
        ' className: $className,' +
        ' description: $description,' +
        ' dayOfWeek: $dayOfWeek,' +
        ' startTime: $startTime,' +
        ' endTime: $endTime,' +
        ' teacher: $teacher,' +
        '}';
  }

  Classes copyWith({
    Int? id,
    String? className,
    String? description,
    int? dayOfWeek,
    Duration? startTime,
    Duration? endTime,
    String? teacher,
  }) {
    return Classes(
      id: id ?? this.id,
      className: className ?? this.className,
      description: description ?? this.description,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      teacher: teacher ?? this.teacher,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'className': this.className,
      'description': this.description,
      'dayOfWeek': this.dayOfWeek,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'teacher': this.teacher,
    };
  }

  factory Classes.fromMap(Map<String, dynamic> map) {
    return Classes(
      id: map['id'] as Int,
      className: map['className'] as String,
      description: map['description'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as Duration,
      endTime: map['endTime'] as Duration,
      teacher: map['teacher'] as String,
    );
  }

  //</editor-fold>
}