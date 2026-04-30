import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/voucher_service.dart';

class BookingService {
  final CollectionReference _bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');
  final VoucherService _voucherService = VoucherService();

  /// Create a new booking
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
    required String voucherId,
    required String voucherCode,
    required int pointsEarned,
    String? bookingId,
  }) async {
    final docRef = bookingId != null ? _bookingsCollection.doc(bookingId) : _bookingsCollection.doc();
    final now = DateTime.now();
    
    // Set payment deadline to 24 hours from now
    final deadline = now.add(const Duration(hours: 24));

    await docRef.set({
      'booking_id': docRef.id,
      'user_id': _voucherService.auth.currentUser!.uid,
      'package_id': package.packageId,
      'package_title': package.title,
      'package_location': package.location,
      'user_name': userName,
      'user_phone': userPhone,
      'user_email': userEmail,
      'visit_date': Timestamp.fromDate(visitDate),
      'booking_date': Timestamp.fromDate(now),
      'adults': adults,
      'children': children,
      'add_tour_guide': addTourGuide,
      'add_meal': addMeal,
      'add_transport': addTransport,
      'total_price': totalPrice,
      'original_price': originalPrice,
      'discount_amount': discountAmount,
      'voucher_id': voucherId,
      'voucher_code': voucherCode,
      'points_earned': pointsEarned,
      'status': 'confirmed', // Confirmed immediately
      'payment_status': 'paid',
      'payment_deadline': Timestamp.fromDate(deadline),
    });

    // Give points immediately since payment is bypassed
    if (pointsEarned > 0) {
      await _voucherService.updateUserPoints(pointsEarned);
    }

    // If a voucher was used, mark it as redeemed
    if (voucherId.isNotEmpty) {
      await _voucherService.markVoucherAsRedeemed(voucherId);
    }
  }

  /// Mark booking as paid
  Future<void> markAsPaid(String bookingId) async {
    final bookingDoc = await _bookingsCollection.doc(bookingId).get();
    if (!bookingDoc.exists) return;

    final data = bookingDoc.data() as Map<String, dynamic>;
    final points = (data['points_earned'] ?? 0).toInt();

    await _bookingsCollection.doc(bookingId).update({
      'status': 'confirmed',
      'payment_status': 'paid',
    });

    // Add points to user account only after payment
    await _voucherService.updateUserPoints(points);
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    final bookingDoc = await _bookingsCollection.doc(bookingId).get();
    if (!bookingDoc.exists) return;

    final data = bookingDoc.data() as Map<String, dynamic>;
    final points = (data['points_earned'] ?? 0).toInt();
    final voucherId = data['voucher_id'] ?? '';
    final paymentStatus = data['payment_status'] ?? 'unpaid';
    final packageTitle = data['package_title'] ?? 'Travel Package';

    await _bookingsCollection.doc(bookingId).update({
      'status': 'cancelled',
      'points_earned': 0, // Points are cancelled on the booking record
    });

    // If already paid, reverse the points in the user's account
    if (paymentStatus == 'paid' && points > 0) {
      await _voucherService.updateUserPoints(
        -points,
        title: 'Points Reversed',
        description: 'Reversed due to cancellation of $packageTitle',
      );
    }

    // Reactivate voucher if it was used
    if (voucherId.isNotEmpty) {
      await _voucherService.reactivateVoucher(voucherId);
    }
  }

  /// Check and auto-cancel if payment expired (Lazy Cancellation)
  Future<void> checkExpiredPayment(Booking booking) async {
    if (booking.status == 'pending' && 
        booking.paymentStatus == 'unpaid' && 
        DateTime.now().isAfter(booking.paymentDeadline)) {
      await cancelBooking(booking.bookingId!);
    }
  }
}
