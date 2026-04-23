import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muc_jomtravel/src/model/models.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int calculatePointsEarned(double totalPrice) {
    // Simple logic: 1 point for every RM10 spent
    return (totalPrice / 10).floor();
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

  Future<void> redeemPoints(String userId, int cost, String voucherName) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final historyRef = userRef.collection('point_history').doc();

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (!snapshot.exists) throw Exception("User does not exist!");

      int currentPoints = snapshot.get('total_points') ?? 0;

      if (currentPoints < cost) {
        throw Exception("Insufficient points!");
      }

      // 1. Update the user's main balance
      transaction.update(userRef, {'total_points': currentPoints - cost});

      // 2. Add the activity to the history sub-collection
      transaction.set(historyRef, {
        'title': 'Redeemed $voucherName',
        'amount': -cost,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'spend',
      });
    });
  }

  Future<void> addVoucherToUser(String userId, String voucherId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vouchers')
          .doc(voucherId)
          .set({'redeemedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print("Error adding voucher to user: $e");
    }
  }
}
