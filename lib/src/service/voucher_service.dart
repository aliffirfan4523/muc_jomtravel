import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muc_jomtravel/src/model/models.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  int calculatePointsEarned(double totalPrice) {
    // Simple logic: 1 point for every RM10 spent
    return (totalPrice / 10).floor();
  }

  /// Update user's total points and add to history
  Future<void> updateUserPoints(int points, {String? title, String? description}) async {
    final user = auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final historyRef = userRef.collection('point_history').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      int currentPoints = (snapshot.get('total_points') ?? 0).toInt();
      transaction.update(userRef, {'total_points': currentPoints + points});

      transaction.set(historyRef, {
        'title': title ?? (points > 0 ? 'Points Earned' : 'Points Deducted'),
        'amount': points,
        'timestamp': FieldValue.serverTimestamp(),
        'type': points > 0 ? 'earn' : 'spend',
        'description': description ?? (points > 0 ? 'Earned from booking' : 'Deducted from account'),
      });
    });
  }

  /// Mark a specific user voucher as redeemed
  Future<void> markVoucherAsRedeemed(String voucherId) async {
    final user = auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_vouchers')
        .doc(voucherId)
        .update({'redeemed': true});
  }

  /// Reactivate a redeemed voucher (e.g., if booking is cancelled)
  Future<void> reactivateVoucher(String voucherId) async {
    final user = auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_vouchers')
        .doc(voucherId)
        .update({'redeemed': false});
  }

  /// Get real-time stream of user's owned vouchers
  Stream<List<Voucher>> getUserVouchersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('my_vouchers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Voucher.fromMap(doc.data())).toList();
    });
  }

  Future<List<Voucher>> getUserVouchers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_vouchers')
          .get();

      return snapshot.docs.map((doc) => Voucher.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching user vouchers: $e");
      return [];
    }
  }

  Future<void> redeemVoucher(String userId, Voucher voucher) async {
    final userRef = _firestore.collection('users').doc(userId);
    final historyRef = userRef.collection('point_history').doc();
    final voucherRef = userRef.collection('my_vouchers').doc(voucher.voucherId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (!snapshot.exists) throw Exception("User does not exist!");

      int currentPoints = (snapshot.get('total_points') ?? 0).toInt();

      if (currentPoints < voucher.pointsRequired) {
        throw Exception("Insufficient points! You need ${voucher.pointsRequired} pts.");
      }

      // 1. Update the user's main balance
      transaction.update(userRef, {'total_points': currentPoints - voucher.pointsRequired});

      // 2. Add the activity to the history sub-collection
      transaction.set(historyRef, {
        'title': 'Redeemed ${voucher.title}',
        'amount': -voucher.pointsRequired,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'spend',
        'description': 'Redeemed for ${voucher.description}',
      });

      // 3. Add the voucher to user's collection
      transaction.set(voucherRef, voucher.toMap());
    });
  }

  // --- Admin Methods ---

  /// Get real-time stream of all available vouchers
  Stream<List<Voucher>> getAvailableVouchersStream() {
    return _firestore.collection('available_vouchers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Voucher.fromMap(doc.data())).toList();
    });
  }

  /// Get all available vouchers once
  Future<List<Voucher>> getAvailableVouchers() async {
    final snapshot = await _firestore.collection('available_vouchers').get();
    return snapshot.docs.map((doc) => Voucher.fromMap(doc.data())).toList();
  }

  /// Create a new available voucher
  Future<void> createAvailableVoucher(Voucher voucher) async {
    await _firestore
        .collection('available_vouchers')
        .doc(voucher.voucherId)
        .set(voucher.toMap());
  }

  /// Update an existing available voucher
  Future<void> updateAvailableVoucher(Voucher voucher) async {
    await _firestore
        .collection('available_vouchers')
        .doc(voucher.voucherId)
        .update(voucher.toMap());
  }

  /// Delete an available voucher
  Future<void> deleteAvailableVoucher(String voucherId) async {
    await _firestore.collection('available_vouchers').doc(voucherId).delete();
  }
}
