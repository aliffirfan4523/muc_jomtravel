import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/app_booking.dart';

class AdminViewBooking extends StatefulWidget {
  const AdminViewBooking({super.key});

  @override
  State<AdminViewBooking> createState() => _AdminViewBookingState();
}

class _AdminViewBookingState extends State<AdminViewBooking> {
  /// Track expanded booking card
  int? _expandedIndex;

  void _toggleView(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });
  }

  void _deleteBooking(String bookingId) {
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
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(bookingId)
                  .delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking deleted successfully')),
                );
              }
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              // Safely parse
              Booking booking;
              try {
                booking = Booking.fromMap(data, doc.id);
              } catch (e) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Error parsing booking: ${doc.id}"),
                  ),
                );
              }

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Booking ID: ...${doc.id.substring(doc.id.length - 6)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          booking.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("User: ${booking.userName} (${booking.userEmail})"),
                    Text("Package: ${booking.packageTitle}"),

                    /// Expanded details
                    if (isExpanded) ...[
                      const Divider(height: 20),
                      Text(
                        "Date: ${DateFormat('dd/MM/yyyy').format(booking.visitDate)}",
                      ),
                      Text(
                        "People: ${booking.adults} Adults, ${booking.children} Children",
                      ),
                      Text(
                        "Total: RM ${booking.totalPrice.toStringAsFixed(2)}",
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add-ons:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (booking.addTourGuide) const Text("- Tour Guide"),
                      if (booking.addMeal) const Text("- Meal"),
                      if (booking.addTransport) const Text("- Transport"),
                      if (!booking.addTourGuide &&
                          !booking.addMeal &&
                          !booking.addTransport)
                        const Text("- None"),
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
                          () => _deleteBooking(doc.id),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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
        style: TextStyle(color: color, decoration: TextDecoration.underline),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
