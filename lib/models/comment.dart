import 'package:cloud_firestore/cloud_firestore.dart';

class AppComment {
  final String name;
  final String message;
  final DateTime? createdAt;

  AppComment({required this.name, required this.message, this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppComment.fromMap(Map<String, dynamic> map) {
    final timestamp = map['createdAt'] as Timestamp?;
    return AppComment(
      name: map['name'] ?? 'Anonymous',
      message: map['message'] ?? '',
      createdAt: timestamp?.toDate(),
    );
  }
}