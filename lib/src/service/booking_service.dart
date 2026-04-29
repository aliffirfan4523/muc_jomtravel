import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muc_jomtravel/src/model/models.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Calculate total price
  double calculateTotal({
    required Package package,
    required int adults,
    required int children,
    required bool addTourGuide,
    required bool addMeal,
    required bool addTransport,
  }) {
    double adultTotal = adults * package.priceAdult;
    double childrenTotal = children * package.priceChild;

    // Add-on logic (User can customize these rates if needed)
    double mealTotal = addMeal ? (adults + children) * 30.0 : 0.0;
    double tourGuideTotal = addTourGuide ? 50.0 : 0.0;
    double transportTotal = addTransport ? 100.0 : 0.0;

    return adultTotal +
        childrenTotal +
        mealTotal +
        tourGuideTotal +
        transportTotal;
  }

  // Create a new booking
  Future<void> createBooking({
    required Package package,
    required String userName,
    required String userPhone,
    required String userEmail,
    required DateTime visitDate,
    required int adults,
    required int children,
    required bool addTourGuide,
    required bool addMeal,
    required bool addTransport,
    required double totalPrice,
    required double originalPrice,
    required double discountAmount,
    String? voucherId,
    String? voucherCode,
    required int pointsEarned,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final booking = Booking(
      userId: user.uid,
      packageId: package.packageId,
      packageTitle: package.title,
      userName: userName,
      userPhone: userPhone,
      userEmail: userEmail,
      visitDate: visitDate,
      adults: adults,
      children: children,
      addTourGuide: addTourGuide,
      addMeal: addMeal,
      addTransport: addTransport,
      totalPrice: totalPrice,
      status: 'Pending',
      createdAt: Timestamp.now(),
      originalPrice: originalPrice,
      discountAmount: discountAmount,
      voucherId: voucherId,
      voucherCode: voucherCode,
      pointsEarned: pointsEarned,
    );

    final batch = _firestore.batch();

    // 1. Create the booking document
    final bookingRef = _firestore.collection('bookings').doc();
    batch.set(bookingRef, booking.toMap());

    // 2. Award points to the user
    final userRef = _firestore.collection('users').doc(user.uid);
    batch.update(userRef, {
      'total_points': FieldValue.increment(pointsEarned),
      'lifetime_points': FieldValue.increment(pointsEarned),
    });

    // 3. Log point history
    final historyRef = userRef.collection('point_history').doc();
    batch.set(historyRef, {
      'title': 'Points Earned',
      'description': 'Booking for ${package.title}',
      'amount': pointsEarned,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'earn',
    });

    // 4. Mark voucher as redeemed if applicable
    if (voucherId != null && voucherId.isNotEmpty) {
      final userVoucherRef = userRef.collection('my_vouchers').doc(voucherId);
      batch.update(userVoucherRef, {'redeemed': true});
    }

    await batch.commit();
  }

  // Cancel data
  Future<void> cancelBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    return _firestore.runTransaction((transaction) async {
      final bookingSnap = await transaction.get(bookingRef);
      if (!bookingSnap.exists) throw Exception("Booking not found");

      final data = bookingSnap.data() as Map<String, dynamic>;
      final String status = data['status'] ?? '';
      final String userId = data['user_id'] ?? '';
      final int pointsEarned = (data['points_earned'] ?? 0).toInt();
      final String packageTitle = data['package_title'] ?? 'Package';

      if (status == 'Cancelled') return;

      // 1. Update booking status
      transaction.update(bookingRef, {'status': 'Cancelled'});

      // 2. Remove points if any were earned
      if (pointsEarned > 0 && userId.isNotEmpty) {
        final userRef = _firestore.collection('users').doc(userId);

        transaction.update(userRef, {
          'total_points': FieldValue.increment(-pointsEarned),
          'lifetime_points': FieldValue.increment(-pointsEarned),
        });

        // 3. Log point removal history
        final historyRef = userRef.collection('point_history').doc();
        transaction.set(historyRef, {
          'title': 'Points Removed (Cancellation)',
          'description': 'Cancelled booking for $packageTitle',
          'amount': -pointsEarned,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'spend',
        });
        // 4. Refund voucher if applicable
        if (data['voucher_id'] != null &&
            data['voucher_id'].toString().isNotEmpty &&
            userId.isNotEmpty) {
          final voucherRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('my_vouchers')
              .doc(data['voucher_id']);
          transaction.update(voucherRef, {'redeemed': false});
        }
      }
    });
  }
}
