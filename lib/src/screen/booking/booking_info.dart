import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';
import 'payment_screen.dart';

class BookingInfoScreen extends StatefulWidget {
  const BookingInfoScreen({super.key});

  @override
  State<BookingInfoScreen> createState() => _BookingInfoScreenState();
}

class _BookingInfoScreenState extends State<BookingInfoScreen> {
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    final bookingId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Booking not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final booking = Booking.fromMap(data, bookingId);

          // Lazy cancellation check
          _bookingService.checkExpiredPayment(booking);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              children: [
                _buildTicket(booking),
                const SizedBox(height: 24),
                if (booking.paymentStatus == 'unpaid' && booking.status == 'pending')
                  _buildPaymentAction(context, booking),
                const SizedBox(height: 12),
                if (booking.status.toLowerCase() == 'confirmed' ||
                    booking.status.toLowerCase() == 'pending')
                  _buildCancelAction(context, booking),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentAction(BuildContext context, Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payment Deadline: ${DateFormat('MMM d, h:mm a').format(booking.paymentDeadline)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(bookingId: booking.bookingId!, amount: booking.totalPrice),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelAction(BuildContext context, Booking booking) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmCancel(context, booking),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancel My Booking'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTicket(Booking booking) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusHeader(booking),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('TRAVEL PACKAGE'),
                const SizedBox(height: 12),
                Text(
                  booking.packageTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      booking.packageLocation,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      'VISIT DATE',
                      DateFormat('MMM d, yyyy').format(booking.visitDate),
                    ),
                    _buildInfoColumn(
                      'BOOKING ID',
                      '#${booking.bookingId!.substring(0, 8).toUpperCase()}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      'GUESTS',
                      '${booking.adults} Adults, ${booking.children} Kids',
                    ),
                    _buildInfoColumn(
                      'PAYMENT',
                      booking.paymentStatus.toUpperCase(),
                      color: booking.paymentStatus == 'paid' ? AppColors.success : AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDashedDivider(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildPriceRow('Subtotal', booking.originalPrice),
                if (booking.discountAmount > 0)
                  _buildPriceRow(
                    'Discount',
                    -booking.discountAmount,
                    isDiscount: true,
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'RM ${booking.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (booking.paymentStatus == 'paid') _buildQRCodePlaceholder(),
                if (booking.paymentStatus == 'unpaid')
                  const Text(
                    'Complete payment to view ticket',
                    style: TextStyle(color: AppColors.textLight, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(Booking booking) {
    Color color;
    IconData icon;
    String text = booking.status.toUpperCase();

    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        color = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case 'pending':
        color = AppColors.warning;
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'cancelled':
        color = AppColors.error;
        icon = Icons.cancel_rounded;
        break;
      default:
        color = AppColors.textLight;
        icon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            '${amount < 0 ? '-' : ''}RM ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-10, 0),
          child: const CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.background,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => SizedBox(
                      width: 5,
                      height: 1,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: AppColors.border),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(10, 0),
          child: const CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodePlaceholder() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            size: 100,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Show this at the entrance',
          style: TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
      ],
    );
  }

  void _confirmCancel(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking?'),
        content: const Text(
          'This action will refund your points and invalidate the voucher used. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _bookingService.cancelBooking(booking.bookingId!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
