import 'package:flutter/material.dart';

/// BookingHistoryScreen
/// Displays a list of previous and upcoming bookings.
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  /// build()
  /// Builds the booking history UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking History')),

      /// Card widget used to display a booking record
      body: Card(
        margin: const EdgeInsets.all(16),
        child: ListTile(
          title: const Text('Batik Workshop'),
          subtitle: const Text('Kota Bharu, Kelantan\n26/6/2026\nUpcoming'),

          /// Button navigates to detailed booking info
          trailing: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/info');
            },
            child: const Text('View Booking'),
          ),
        ),
      ),
    );
  }
}
