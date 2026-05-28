import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muc_jomtravel/src/model/models.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  int calculatePointsEarned(double totalPrice) {
    return (totalPrice / 10).floor();
  }

  Future<void> updateUserPoints(
    int points, {
    String? title,
    String? description,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final historyRef = userRef.collection('point_history').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data();
      final currentPoints = ((data?['total_points'] ?? 0) as num).toInt();
      final currentLifetimePoints =
          ((data?['lifetime_points'] ?? 0) as num).toInt();

      final newTotalPoints = currentPoints + points;
      final newLifetimePoints =
          points > 0 ? currentLifetimePoints + points : currentLifetimePoints;

      transaction.update(userRef, {
        'total_points': newTotalPoints,
        'lifetime_points': newLifetimePoints,
      });

      transaction.set(historyRef, {
        'title': title ?? (points > 0 ? 'Points Earned' : 'Points Deducted'),
        'amount': points,
        'timestamp': FieldValue.serverTimestamp(),
        'type': points > 0 ? 'earn' : 'spend',
        'description': description ??
            (points > 0 ? 'Earned from booking' : 'Deducted from account'),
      });
    });
  }

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
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      final data = snapshot.data();
      final currentPoints = ((data?['total_points'] ?? 0) as num).toInt();

      if (currentPoints < voucher.pointsRequired) {
        throw Exception(
          "Insufficient points! You need ${voucher.pointsRequired} pts.",
        );
      }

      transaction.update(userRef, {
        'total_points': currentPoints - voucher.pointsRequired,
      });

      transaction.set(historyRef, {
        'title': 'Redeemed ${voucher.title}',
        'amount': -voucher.pointsRequired,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'spend',
        'description': 'Redeemed for ${voucher.description}',
      });

      transaction.set(voucherRef, voucher.toMap());
    });
  }

  // =========================
  // Admin Points Methods
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersForPointsStream() {
    return _firestore.collection('users').snapshots();
  }

  Future<void> adminAdjustUserPoints({
    required String userId,
    required int points,
    required String reason,
  }) async {
    final admin = auth.currentUser;
    final userRef = _firestore.collection('users').doc(userId);
    final historyRef = userRef.collection('point_history').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        throw Exception('User not found.');
      }

      final data = snapshot.data();

      final currentPoints = ((data?['total_points'] ?? 0) as num).toInt();
      final currentLifetimePoints =
          ((data?['lifetime_points'] ?? 0) as num).toInt();

      final newTotalPoints = currentPoints + points;

      if (newTotalPoints < 0) {
        throw Exception(
          'User only has $currentPoints points. Cannot deduct ${points.abs()} points.',
        );
      }

      final newLifetimePoints =
          points > 0 ? currentLifetimePoints + points : currentLifetimePoints;

      transaction.update(userRef, {
        'total_points': newTotalPoints,
        'lifetime_points': newLifetimePoints,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(historyRef, {
        'title': points > 0 ? 'Admin Points Added' : 'Admin Points Deducted',
        'amount': points,
        'timestamp': FieldValue.serverTimestamp(),
        'type': points > 0 ? 'earn' : 'spend',
        'description': reason,
        'created_by': admin?.uid ?? 'unknown_admin',
        'created_by_email': admin?.email ?? '',
      });
    });
  }

  // =========================
  // Admin Voucher Methods
  // =========================

  Stream<List<Voucher>> getAvailableVouchersStream() {
    return _firestore
        .collection('available_vouchers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Voucher.fromMap(doc.data())).toList();
    });
  }

  Future<List<Voucher>> getAvailableVouchers() async {
    final snapshot = await _firestore.collection('available_vouchers').get();

    return snapshot.docs.map((doc) => Voucher.fromMap(doc.data())).toList();
  }

  Future<void> createAvailableVoucher(Voucher voucher) async {
    await _firestore
        .collection('available_vouchers')
        .doc(voucher.voucherId)
        .set(voucher.toMap());
  }

  Future<void> updateAvailableVoucher(Voucher voucher) async {
    await _firestore
        .collection('available_vouchers')
        .doc(voucher.voucherId)
        .update(voucher.toMap());
  }

  Future<void> deleteAvailableVoucher(String voucherId) async {
    await _firestore.collection('available_vouchers').doc(voucherId).delete();
  }
}
