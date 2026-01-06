import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muc_jomtravel/src/model/app_package.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addPackage(Package package) async {
    await _firestore.collection('packages').add(package.toMap());
  }

  Future<void> updatePackage(Package package) async {
    await _firestore
        .collection('packages')
        .doc(package.packageId)
        .update(package.toMap());
  }

  Future<void> deletePackage(Package package) async {
    await _firestore.collection('packages').doc(package.packageId).delete();
  }

  // User Management
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final packages = await _firestore.collection('packages').count().get();
      final users = await _firestore.collection('users').count().get();
      // Assuming 'bookings' collection exists, otherwise returning 0
      final bookings = await _firestore.collection('bookings').count().get();

      return {
        'packages': packages.count ?? 0,
        'users': users.count ?? 0,
        'bookings': bookings.count ?? 0,
      };
    } catch (e) {
      print('Error fetching stats: $e');
      return {'packages': 0, 'users': 0, 'bookings': 0};
    }
  }
}
