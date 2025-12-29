import 'package:flutter/material.dart';

/// BookingSuccessfulScreen
/// Shown after a booking is successfully completed.
class BookingSuccessfulScreen extends StatelessWidget {
  const BookingSuccessfulScreen({super.key});

  /// build()
  /// Builds confirmation UI with success message
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Successful')),

      /// Column centers confirmation content vertically
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Success icon
          const Icon(Icons.check_circle, size: 100, color: Colors.green),

          const SizedBox(height: 20),

          /// Success message
          const Text(
            'Booking Confirmed Successfully',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          /// Booking reference ID
          const Text('Booking ID: 1523523123'),

          const SizedBox(height: 30),

          /// Navigate to booking info screen
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/info');
            },
            child: const Text('View Booking Details'),
          ),

          /// Navigate back to booking history/home
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            child: const Text('Back To Homepage'),
          ),
        ],
      ),
    );
  }
}
