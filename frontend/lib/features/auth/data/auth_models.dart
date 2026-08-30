class UserModel {
  final int id;
  final String fullName;
  final String email;
  final int? age;
  final String? gender;
  final String? region;
  final String? occupation;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.age,
    this.gender,
    this.region,
    this.occupation,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      region: json['region'] as String?,
      occupation: json['occupation'] as String?,
      isActive: json['is_active'] as bool,
    );
  }
}
