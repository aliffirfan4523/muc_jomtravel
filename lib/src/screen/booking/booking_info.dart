import 'package:flutter/material.dart';

/// BookingInfoScreen
/// Displays complete details of a selected booking.
class BookingInfoScreen extends StatelessWidget {
  const BookingInfoScreen({super.key});

  /// build()
  /// Builds the detailed booking information UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Info'),
        leading: const BackButton(),
      ),

      /// ListView allows scrolling if content exceeds screen height
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Status: Upcoming',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),
            Text('Package: Batik Workshop'),
            Text('People: 2 Adult, 0 Children'),
            Text('Visit Date: 26/6/2026'),

            Divider(),

            /// Contact information section
            Text(
              'Contact Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: Ahmed Muslim'),
            Text('Phone: 0124235764'),
            Text('Email: ahmed@gmail.com'),

            Divider(),

            /// Final booking cost
            Text(
              'Total: RM 70.00',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
