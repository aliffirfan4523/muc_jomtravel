import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muc_jomtravel/src/model/app_booking.dart';
import 'package:muc_jomtravel/src/model/app_package.dart';

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
    );

    await _firestore.collection('bookings').add(booking.toMap());
  }

  // Cancel data
  Future<void> cancelBooking(String bookingId) async {
    print(bookingId);
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'Cancelled',
    });
  }
}
