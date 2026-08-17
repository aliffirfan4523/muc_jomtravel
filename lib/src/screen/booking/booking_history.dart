import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';
import 'package:muc_jomtravel/src/shared/widgets/ticket_pass_card.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Upcoming, 2: Completed, 3: Cancelled

  Stream<QuerySnapshot> bookingStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('visit_date', descending: true)
        .snapshots();
  }



  Future<void> _submitFeedback({
    required BuildContext context,
    required Booking booking,
    required String bookingDocId,
  }) async {
    int selectedRating = 5;
    final feedbackController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Trip Experience',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.packageTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'HOW WAS YOUR TRIP?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textLight,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.warning,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share what you loved about this tour...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final feedbackText = feedbackController.text.trim();
                    if (feedbackText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please write your review feedback'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    try {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final userName = booking.userName.trim().isNotEmpty
                          ? booking.userName.trim()
                          : currentUser?.displayName ?? 'Traveler';
                      final userEmail = booking.userEmail.trim().isNotEmpty
                          ? booking.userEmail.trim()
                          : currentUser?.email ?? '';

                      final batch = FirebaseFirestore.instance.batch();
                      final feedbackRef = FirebaseFirestore.instance
                          .collection('feedbacks')
                          .doc(bookingDocId);

                      batch.set(feedbackRef, {
                        'feedback_id': bookingDocId,
                        'booking_id': booking.bookingId,
                        'user_id': currentUser?.uid ?? '',
                        'user_name': userName,
                        'user_email': userEmail,
                        'package_id': booking.packageId,
                        'package_title': booking.packageTitle,
                        'rating': selectedRating,
                        'feedback': feedbackText,
                        'status': 'approved',
                        'is_visible': true,
                        'created_at': FieldValue.serverTimestamp(),
                      });

                      final bookingRef = FirebaseFirestore.instance
                          .collection('bookings')
                          .doc(bookingDocId);

                      batch.update(bookingRef, {
                        'has_feedback': true,
                        'feedback_rating': selectedRating,
                        'feedback_text': feedbackText,
                        'feedback_status': 'approved',
                        'feedback_submitted_at': FieldValue.serverTimestamp(),
                      });

                      await batch.commit();

                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review submitted successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to submit review: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Post Review'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'DIGITAL WALLET',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'My Travel Passes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Status Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'All'),
                    _buildFilterTab(1, 'Upcoming'),
                    _buildFilterTab(2, 'Completed'),
                    _buildFilterTab(3, 'Cancelled'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Main Passes Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: bookingStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading bookings: ${snapshot.error}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final allBookings = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'booking': Booking.fromMap(data, doc.id),
                      'docId': doc.id,
                      'data': data,
                    };
                  }).toList();

                  final filteredItems = allBookings.where((item) {
                    final b = item['booking'] as Booking;
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);

                    if (_selectedTabIndex == 1) {
                      return b.status.toLowerCase() != 'cancelled' &&
                          !b.visitDate.isBefore(today);
                    } else if (_selectedTabIndex == 2) {
                      return b.status.toLowerCase() != 'cancelled' &&
                          b.visitDate.isBefore(today);
                    } else if (_selectedTabIndex == 3) {
                      return b.status.toLowerCase() == 'cancelled';
                    }
                    return true;
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.airplane_ticket_outlined,
                              size: 64,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No Travel Passes Found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Your confirmed bookings will appear here as digital boarding passes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 110, top: 4),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final booking = item['booking'] as Booking;
                      final docId = item['docId'] as String;
                      final data = item['data'] as Map<String, dynamic>;
                      final hasFeedback = data['has_feedback'] == true;

                      return TicketPassCard(
                        booking: booking,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/bookingInfo',
                            arguments: docId,
                          );
                        },
                        actionButton: hasFeedback
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.warning.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 14, color: AppColors.warning),
                                    SizedBox(width: 4),
                                    Text(
                                      'Reviewed',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : (booking.status.toLowerCase() == 'confirmed'
                                ? GestureDetector(
                                    onTap: () => _submitFeedback(
                                      context: context,
                                      booking: booking,
                                      bookingDocId: docId,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.rate_review_rounded,
                                              size: 14,
                                              color: AppColors.primary),
                                          SizedBox(width: 4),
                                          Text(
                                            'Review',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : null),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color:
                  isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
