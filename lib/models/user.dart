import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? dateOfBirth;
  final String? gender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.dateOfBirth,
    this.gender,
    this.createdAt,
    this.updatedAt,
  });

 factory User.fromJson(Map<String, dynamic> json) {
  try {
    final id = json['_id'] ?? json['id'] ?? '';
    final name = json['name'] ?? '';
    final email = json['email'] ?? '';
    
    debugPrint('Parsing user data: id=$id, name=$name, email=$email');
    
    return User(
      id: id,
      name: name,
      email: email,
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  } catch (e) {
    debugPrint('Error in User.fromJson: $e');
    debugPrint('Raw JSON: $json');
    rethrow;
  }
}
}