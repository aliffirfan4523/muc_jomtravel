import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muc_jomtravel/src/model/models.dart';

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

  Stream<QuerySnapshot> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedbacksStream() {
    return _firestore.collection('feedbacks').snapshots();
  }

  Future<void> updateFeedbackStatus(String feedbackId, String status) async {
    final feedbackRef = _firestore.collection('feedbacks').doc(feedbackId);

    await _firestore.runTransaction((transaction) async {
      final feedbackSnapshot = await transaction.get(feedbackRef);

      if (!feedbackSnapshot.exists) {
        throw Exception('Feedback not found.');
      }

      final data = feedbackSnapshot.data() as Map<String, dynamic>;

      final bookingId = data['booking_id']?.toString() ?? feedbackId;
      final bookingRef = _firestore.collection('bookings').doc(bookingId);

      final bool isVisible = status == 'approved';

      transaction.update(feedbackRef, {
        'status': status,
        'is_visible': isVisible,
        'updated_at': FieldValue.serverTimestamp(),
      });

      transaction.update(bookingRef, {
        'feedback_status': status,
        'feedback_visible': isVisible,
      });
    });
  }

  Future<void> deleteFeedback(String feedbackId) async {
    await _firestore.collection('feedbacks').doc(feedbackId).delete();
  }

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final packages = await _firestore.collection('packages').count().get();
      final users = await _firestore.collection('users').count().get();
      final bookings = await _firestore.collection('bookings').count().get();
      final vouchers =
          await _firestore.collection('available_vouchers').count().get();
      final feedbacks = await _firestore.collection('feedbacks').count().get();

      return {
        'packages': packages.count ?? 0,
        'users': users.count ?? 0,
        'bookings': bookings.count ?? 0,
        'vouchers': vouchers.count ?? 0,
        'feedbacks': feedbacks.count ?? 0,
      };
    } catch (e) {
      print('Error fetching stats: $e');

      return {
        'packages': 0,
        'users': 0,
        'bookings': 0,
        'vouchers': 0,
        'feedbacks': 0,
      };
    }
  }
}
