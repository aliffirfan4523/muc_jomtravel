import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserIfNotExist(
    User user, {
    required String provider,
    String? name,
  }) async {
    final userRef = _db.collection('users').doc(user.uid);

    final doc = await userRef.get();

    if (doc.exists) return;

    await userRef.set({
      'user_id': user.uid,
      'email': user.email,
      'name': user.displayName ?? name ?? 'No Name',
      'phone': user.phoneNumber ?? '0000000000',
      'is_admin': false,
      'provider': provider,
    });
  }
}
