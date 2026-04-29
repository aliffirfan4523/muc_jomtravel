import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

/// Screen to show booking history
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  /// Function that returns a real-time stream of bookings
  Stream<QuerySnapshot> bookingStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('visit_date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking History', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),

      /// StreamBuilder listens to Firestore updates
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingStream(),
        builder: (context, snapshot) {
          /// Show loading if data is not ready
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found', style: TextStyle(color: AppColors.textSecondary)));
          }

          /// Convert Firestore documents into a list view
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              // Convert to Booking model
              final booking = Booking.fromMap(data, doc.id);

              Color statusColor;
              switch (booking.status.toLowerCase()) {
                case 'confirmed':
                  statusColor = AppColors.success;
                  break;
                case 'pending':
                  statusColor = AppColors.warning;
                  break;
                case 'cancelled':
                  statusColor = AppColors.error;
                  break;
                default:
                  statusColor = AppColors.textLight;
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/bookingInfo',
                      arguments: doc.id,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                booking.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat(
                                'dd MMM yyyy',
                              ).format(booking.visitDate),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          booking.packageTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${booking.adults + booking.children} Guests',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'RM ${booking.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
