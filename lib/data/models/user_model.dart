// lib/data/models/user_model.dart

class UserModel {
  final int id;
  final String firstname;
  final String surname;
  final String middleName;
  final String email;
  final String studentId;
  final String role; // 'student' | 'admin' | 'rep'

  const UserModel({
    required this.id,
    required this.firstname,
    required this.surname,
    required this.middleName,
    required this.email,
    required this.studentId,
    required this.role,
  });

  String get fullName => '$firstname ${middleName.isNotEmpty ? '$middleName ' : ''}$surname'.trim();
  String get initials => '${firstname.isNotEmpty ? firstname[0] : ''}${surname.isNotEmpty ? surname[0] : ''}'.toUpperCase();
  bool get isAdmin => role == 'admin' || role == 'rep';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:          json['id']         as int? ?? 0,
    firstname:   json['fname']      as String? ?? '',
    surname:     json['sname']      as String? ?? '',
    middleName:  json['mname']      as String? ?? '',
    email:       json['email']      as String? ?? '',
    studentId:   json['student_id'] as String? ?? '',
    role:        json['role']       as String? ?? 'student',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'fname': firstname, 'sname': surname,
    'mname': middleName, 'email': email,
    'student_id': studentId, 'role': role,
  };

  UserModel copyWith({
    int? id, String? firstname, String? surname, String? middleName,
    String? email, String? studentId, String? role,
  }) => UserModel(
    id: id ?? this.id, firstname: firstname ?? this.firstname,
    surname: surname ?? this.surname, middleName: middleName ?? this.middleName,
    email: email ?? this.email, studentId: studentId ?? this.studentId,
    role: role ?? this.role,
  );
}
