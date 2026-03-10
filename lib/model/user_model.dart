class UserModel {
  final int id;
  final String firstname;
  final String surname;
  final String middleName;
  final String email;
  final String studentid;
  final String role;

  UserModel({
    required this.middleName,
    required this.firstname,
    required this.surname,
    required this.email,
    required this.studentid,
    required this.role,
    required this.id,
  });

  factory UserModel.fromjson(Map<String, dynamic> json) {
    return UserModel(
      firstname: json['fname'],
      surname: json['sname'],
      email: json['email'],
      studentid: json['student_id'],
      role: json['role'],
      id: json['id'],
      middleName: json['mname'],
    );
  }
}
