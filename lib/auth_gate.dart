import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/screen/admin/admin_dashboard.dart';
import 'package:muc_jomtravel/src/screen/authentication/registerlogin_switch.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_navigation_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>> _ensureUser(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('pending_name');
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'user_id': user.uid,
        'email': user.email,
        'name': name ?? user.displayName ?? 'No Name',
        'is_admin': false,
        'provider': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'unknown',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 🔑 fetch again AFTER creation
      final newDoc = await docRef.get();
      return newDoc.data()!;
    }

    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnap.hasData) {
          return LoginOrRegister();
        }

        final user = authSnap.data!;

        return FutureBuilder<Map<String, dynamic>>(
          future: _ensureUser(user), // 🔑 ONE FUTURE
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = userSnap.data!;
            final isAdmin = data['is_admin'] ?? false;

            return isAdmin ? AdminDashboard() : UserNavigationView();
          },
        );
      },
    );
  }
}
