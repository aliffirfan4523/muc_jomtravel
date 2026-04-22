import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String userId;
  final String fullName;
  final String email;
  final bool isAdmin;
  final String provider;
  final Timestamp createdAt;
  final int total_points;
  final int lifetime_points;

  AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.isAdmin,
    required this.provider,
    required this.createdAt,
    required this.total_points,
    required this.lifetime_points,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['user_id'],
      fullName: map['name'],
      email: map['email'],
      isAdmin: map['is_admin'] ?? false, // default safety
      provider: map['provider'] ?? 'unknown',
      createdAt: map['createdAt'] ?? FieldValue.serverTimestamp(),
      total_points: map['total_points'] ?? 0,
      lifetime_points: map['lifetime_points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'name': fullName,
    'email': email,
    'is_admin': isAdmin,
    'provider': provider,
    'createdAt': createdAt,
    'total_points': total_points,
    'lifetime_points': lifetime_points,
  };
}
