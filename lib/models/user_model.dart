import 'dart:convert';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  /// Convert UserModel to JSON (for Firestore & SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert JSON to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// Convert JSON String to UserModel (for SharedPreferences)
  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  /// Convert UserModel to JSON String (for SharedPreferences)
  String toJson() => json.encode(toMap());
}
