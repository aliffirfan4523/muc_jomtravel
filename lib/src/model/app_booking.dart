import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? bookingId; // ID from Firestore document
  final String userId;
  final String packageId;
  final String packageTitle;
  final String userName;
  final String userPhone;
  final String userEmail;
  final DateTime visitDate;
  final int adults;
  final int children;
  final bool addTourGuide;
  final bool addMeal;
  final bool addTransport;
  final String status;
  final Timestamp createdAt;
  final double originalPrice;
  final double discountAmount;
  final double totalPrice;
  final String? voucherId;
  final String? voucherCode;
  final int pointsEarned;

  Booking({
    this.bookingId,
    required this.userId,
    required this.packageId,
    required this.packageTitle,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.visitDate,
    required this.adults,
    required this.children,
    required this.addTourGuide,
    required this.addMeal,
    required this.addTransport,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.originalPrice,
    required this.discountAmount,
    this.voucherId = '',
    this.voucherCode = '',
    required this.pointsEarned,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      bookingId: id,
      userId: map['user_id'] ?? '',
      packageId: map['package_id'] ?? '',
      packageTitle: map['package_title'] ?? '',
      userName: map['user_name'] ?? '',
      userPhone: map['user_phone'] ?? '',
      userEmail: map['user_email'] ?? '',
      visitDate: (map['visit_date'] as Timestamp).toDate(),
      adults: map['adults'] ?? 0,
      children: map['children'] ?? 0,
      addTourGuide: map['add_tour_guide'] ?? false,
      addMeal: map['add_meal'] ?? false,
      addTransport: map['add_transport'] ?? false,
      totalPrice: (map['total_price'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      createdAt: map['created_at'] ?? Timestamp.now(),
      originalPrice: (map['original_price'] ?? 0.0).toDouble(),
      discountAmount: (map['discount_amount'] ?? 0.0).toDouble(),
      voucherId: map['voucher_id'],
      voucherCode: map['voucher_code'],
      pointsEarned: map['points_earned'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'package_id': packageId,
      'package_title': packageTitle,
      'user_name': userName,
      'user_phone': userPhone,
      'user_email': userEmail,
      'visit_date': Timestamp.fromDate(visitDate),
      'adults': adults,
      'children': children,
      'add_tour_guide': addTourGuide,
      'add_meal': addMeal,
      'add_transport': addTransport,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt,
      'original_price': originalPrice,
      'discount_amount': discountAmount,
      'voucher_id': voucherId,
      'voucher_code': voucherCode,
      'points_earned': pointsEarned,
    };
  }
}
