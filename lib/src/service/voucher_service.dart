import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muc_jomtravel/src/model/models.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int calculatePointsEarned(double totalPrice) {
    // Simple logic: 1 point for every RM10 spent
    return (totalPrice / 10).floor();
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

  Future<void> addVoucherToUser(String userId, String voucherId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_vouchers')
          .doc(voucherId)
          .set({'redeemedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print("Error adding voucher to user: $e");
    }
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
