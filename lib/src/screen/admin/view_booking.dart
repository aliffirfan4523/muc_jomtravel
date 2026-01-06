import 'package:flutter/material.dart';

class AdminViewBooking extends StatefulWidget {
  const AdminViewBooking({super.key});

  @override
  State<AdminViewBooking> createState() => _AdminViewBookingState();
}

class _AdminViewBookingState extends State<AdminViewBooking> {
  /// Dummy booking data
  final List<Map<String, String>> _bookings = [
    {
      "bookingId": "B001",
      "userId": "U101",
      "package": "Umrah Basic",
      "date": "12 Jan 2026",
      "status": "Pending",
    },
    {
      "bookingId": "B002",
      "userId": "U102",
      "package": "Umrah Premium",
      "date": "18 Feb 2026",
      "status": "Confirmed",
    },
  ];

  /// Track expanded booking card
  int? _expandedIndex;

  void _toggleView(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  void _deleteBooking(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Booking"),
        content: const Text("Are you sure you want to delete this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _bookings.removeAt(index);
                if (_expandedIndex == index) {
                  _expandedIndex = null;
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Bookings")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final isExpanded = _expandedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Default view
                Text(
                  "Booking ID: ${booking["bookingId"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("User ID: ${booking["userId"]}"),
                Text("Status: ${booking["status"]}"),

                /// Expanded details
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  Text("Package: ${booking["package"]}"),
                  Text("Booking Date: ${booking["date"]}"),
                ],

                const SizedBox(height: 12),

                /// Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _linkButton(
                      isExpanded ? "Minimize" : "View",
                      () => _toggleView(index),
                    ),
                    const SizedBox(width: 16),
                    _linkButton(
                      "Delete",
                      () => _deleteBooking(index),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Underlined clickable text
  Widget _linkButton(
    String text,
    VoidCallback onTap, {
    Color color = Colors.blue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}