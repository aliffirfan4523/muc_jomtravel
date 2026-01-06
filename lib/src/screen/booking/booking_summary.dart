import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/app_package.dart';
import 'package:muc_jomtravel/src/service/booking_service.dart';

class PriceSummaryScreen extends StatelessWidget {
  final Package package;
  final DateTime visitDate;
  final int adults;
  final int children;
  final bool addTourGuide;
  final bool addMeal;
  final bool addTransport;
  final String name;
  final String phone;
  final String email;

  const PriceSummaryScreen({
    super.key,
    required this.package,
    required this.visitDate,
    required this.adults,
    required this.children,
    required this.addTourGuide,
    required this.addMeal,
    required this.addTransport,
    required this.name,
    required this.phone,
    required this.email,
  });

  void _confirmBooking(BuildContext context) async {
    final bookingService = BookingService();
    // Calculate total again to be safe
    double adultTotal = adults * package.priceAdult;
    double childrenTotal = children * package.priceChild;
    double mealTotal = addMeal ? (adults + children) * 30 : 0;
    double tourGuideTotal = addTourGuide ? 50 : 0;
    double transportTotal = addTransport ? 100 : 0;
    double grandTotal =
        adultTotal +
        childrenTotal +
        mealTotal +
        tourGuideTotal +
        transportTotal;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please login to book')));
      }
      return;
    }

    try {
      await bookingService.createBooking(
        package: package,
        userName: name,
        userPhone: phone,
        userEmail: email,
        visitDate: visitDate,
        adults: adults,
        children: children,
        addTourGuide: addTourGuide,
        addMeal: addMeal,
        addTransport: addTransport,
        totalPrice: grandTotal,
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/bookingSuccesful');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error booking: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double adultTotal = adults * package.priceAdult;
    double childrenTotal = children * package.priceChild;
    double mealTotal = addMeal ? (adults + children) * 30 : 0;
    double tourGuideTotal = addTourGuide ? 50 : 0;
    double transportTotal = addTransport ? 100 : 0;
    double grandTotal =
        adultTotal +
        childrenTotal +
        mealTotal +
        tourGuideTotal +
        transportTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Price Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Package Card
            _infoCard(
              title: package.title,
              children: [
                _row(
                  'Date',
                  '${visitDate.day}/${visitDate.month}/${visitDate.year}',
                ),
                _row('Adults ($adults)', 'RM ${adultTotal.toStringAsFixed(2)}'),
                _row(
                  'Children ($children)',
                  'RM ${childrenTotal.toStringAsFixed(2)}',
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Contact Info Card
            _infoCard(
              title: 'Contact Details',
              children: [
                _row('Name', name),
                _row('Phone', phone),
                _row('Email', email),
              ],
            ),

            const SizedBox(height: 12),

            /// Add-ons Card
            _infoCard(
              title: 'Add-ons',
              children: [
                _row('Tour Guide', addTourGuide ? 'RM 50.00' : 'RM 0.00'),
                _row(
                  'Meal',
                  addMeal ? 'RM ${mealTotal.toStringAsFixed(2)}' : 'RM 0.00',
                ),
                _row('Transport', addTransport ? 'RM 100.00' : 'RM 0.00'),
              ],
            ),

            const Spacer(),

            /// Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'RM ${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left),
          Text(right, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
