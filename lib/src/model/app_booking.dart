class Booking {
  final String bookingId;
  final String userId;
  final String packageId;
  final DateTime visitDate;
  final int adults;
  final int children;
  final String status;
  final double subtotal;
  final double addonsTotal;
  final double totalPrice;

  Booking({
    required this.bookingId,
    required this.userId,
    required this.packageId,
    required this.visitDate,
    required this.adults,
    required this.children,
    required this.status,
    required this.subtotal,
    required this.addonsTotal,
    required this.totalPrice,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      bookingId: map['booking_id'],
      userId: map['user_id'],
      packageId: map['package_id'],
      visitDate: DateTime.parse(map['visit_date']),
      adults: map['adults'],
      children: map['children'],
      status: map['status'],
      subtotal: map['subtotal'].toDouble(),
      addonsTotal: map['addons_total'].toDouble(),
      totalPrice: map['total_price'].toDouble(),
    );
  }
}
