import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/screen/admin/admin_dashboard.dart';
import 'package:muc_jomtravel/src/screen/authentication/registerlogin_switch.dart';
import 'package:muc_jomtravel/src/screen/homepage/user_navigation_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muc_jomtravel/src/model/models.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>> _ensureUser(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('pending_name');
    var doc = await docRef.get(); // Using 'var' so we can overwrite it

    if (!doc.exists) {
      // 1. Handle New User: Create document with all fields
      await docRef.set({
        'user_id': user.uid,
        'email': user.email,
        'name': name ?? user.displayName ?? 'No Name',
        'is_admin': false,
        'provider': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'unknown',
        'createdAt': FieldValue.serverTimestamp(),
        'total_points': 0,
        'lifetime_points': 0,
      });

      // Add an initial activity log to "initialize" the sub-collection
      await _initializePointHistory(user.uid, "Welcome Reward", 1000);
      doc = await docRef.get();
    } else if (!doc.data()!.containsKey('total_points')) {
      // EXISTING USER LOGIC
      await docRef.update({'total_points': 0, 'lifetime_points': 0});
      await _initializePointHistory(user.uid, "Welcome Reward", 1000);
      doc = await docRef.get(); // Refresh
    }
    return doc.data()!;
  }

  // Helper to create the sub-collection by adding the first entry
  Future<void> _initializePointHistory(
    String uid,
    String title,
    int points,
  ) async {
    final newUserVoucher = Voucher(
      title: 'RM10 OFF',
      description: 'Min. spend RM0. Valid for 1 use only.',
      expiryDate: 'Valid until 31 Dec 2026',
      pointsRequired: 0,
      voucherId: "NEWUSER10",
      code: "NEWUSER10",
      discountAmount: 10,
      type: VoucherType.Voucher.name,
      minimumSpend: 0,
      redeemed: false,
      expired: false,
    );

    final batch = FirebaseFirestore.instance.batch(); // 1. Start a batch

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final historyRef = userRef.collection('point_history').doc(); // Auto-ID
    final voucherRef = userRef
        .collection('my_vouchers')
        .doc(newUserVoucher.voucherId);

    // 2. Queue the operations
    batch.set(historyRef, {
      'title': title,
      'amount': points,
      'description': 'Points earned for $title',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'earn',
    });

    batch.set(voucherRef, newUserVoucher.toMap());

    batch.update(userRef, {
      'total_points': FieldValue.increment(points),
      'lifetime_points': FieldValue.increment(points),
    });

    // 3. Commit everything at once
    await batch.commit();
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
        final user = authSnap.data;
        if (user == null) {
          return LoginOrRegister();
        }

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
