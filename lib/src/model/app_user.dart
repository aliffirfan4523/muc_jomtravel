class AppUser {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final bool isAdmin;

  AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isAdmin,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['user_id'],
      fullName: map['name'],
      email: map['email'],
      phone: map['phone'],
      isAdmin: map['is_admin'] ?? false, // default safety
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'is_admin': isAdmin,
  };
}
