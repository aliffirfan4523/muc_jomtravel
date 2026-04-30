import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

import '../../model/voucher.dart';

class PriceSummaryScreen extends StatefulWidget {
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
  final Voucher? voucher;
  final String bookingSessionId;

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
    required this.bookingSessionId,
    this.voucher,
  });

  @override
  State<PriceSummaryScreen> createState() => _PriceSummaryScreenState();
}

class _PriceSummaryScreenState extends State<PriceSummaryScreen> {
  bool _isConfirming = false;
  final BookingService _bookingService = BookingService();

  Future<void> _confirmBooking(
    double originalPrice,
    double discountAmount,
  ) async {
    if (_isConfirming) return;

    setState(() => _isConfirming = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to book'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isConfirming = false);
      return;
    }

    try {
      // Create or Update the booking using the Session ID
      await _bookingService.createBooking(
        bookingId: widget.bookingSessionId,
        package: widget.package,
        userName: widget.name,
        userPhone: widget.phone,
        userEmail: widget.email,
        visitDate: widget.visitDate,
        adults: widget.adults,
        children: widget.children,
        addTourGuide: widget.addTourGuide,
        addMeal: widget.addMeal,
        addTransport: widget.addTransport,
        totalPrice: originalPrice - discountAmount,
        originalPrice: originalPrice,
        discountAmount: discountAmount,
        voucherId: widget.voucher?.voucherId ?? '',
        voucherCode: widget.voucher?.code ?? '',
        pointsEarned: VoucherService().calculatePointsEarned(
          originalPrice - discountAmount,
        ),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/bookingSuccesful');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double adultTotal = widget.adults * widget.package.priceAdult;
    double childrenTotal = widget.children * widget.package.priceChild;
    double mealTotal = widget.addMeal ? (widget.adults + widget.children) * 30 : 0;
    double tourGuideTotal = widget.addTourGuide ? 50 : 0;
    double transportTotal = widget.addTransport ? 100 : 0;
    double grandTotal =
        adultTotal +
        childrenTotal +
        mealTotal +
        tourGuideTotal +
        transportTotal;
    double discountedPrice = grandTotal - (widget.voucher?.discountAmount ?? 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Price Summary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
        child: Column(
          children: [
            /// Package Card
            _infoCard(
              title: widget.package.title,
              children: [
                _row(
                  'Date',
                  '${widget.visitDate.day}/${widget.visitDate.month}/${widget.visitDate.year}',
                ),
                _row('Adults (${widget.adults})', 'RM ${adultTotal.toStringAsFixed(2)}'),
                _row(
                  'Children (${widget.children})',
                  'RM ${childrenTotal.toStringAsFixed(2)}',
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Contact Info Card
            _infoCard(
              title: 'Contact Details',
              children: [
                _row('Name', widget.name),
                _row('Phone', widget.phone),
                _row('Email', widget.email),
              ],
            ),

            const SizedBox(height: 8),

            /// Add-ons Card
            _infoCard(
              title: 'Add-ons',
              children: [
                _row('Tour Guide', widget.addTourGuide ? 'RM 50.00' : 'RM 0.00'),
                _row(
                  'Meal',
                  widget.addMeal ? 'RM ${mealTotal.toStringAsFixed(2)}' : 'RM 0.00',
                ),
                _row('Transport', widget.addTransport ? 'RM 100.00' : 'RM 0.00'),
              ],
            ),

            const SizedBox(height: 8),

            /// Total Breakdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _priceSummaryRow('Original Price', grandTotal, isMain: false),
                  const SizedBox(height: 8),
                  _priceSummaryRow(
                    'Discount Amount',
                    -(widget.voucher?.discountAmount ?? 0),
                    isMain: false,
                    isDiscount: true,
                  ),
                  const Divider(height: 32, color: AppColors.divider),
                  _priceSummaryRow(
                    'Total Price',
                    discountedPrice,
                    isMain: true,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Points to be earned',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '+${VoucherService().calculatePointsEarned(discountedPrice)} pts',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
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
                onPressed: _isConfirming 
                  ? null 
                  : () => _confirmBooking(
                    grandTotal,
                    widget.voucher?.discountAmount ?? 0,
                  ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isConfirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Confirm Booking',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
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
          Text(left, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceSummaryRow(
    String label,
    double amount, {
    required bool isMain,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMain ? 18 : 14,
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
            color: isMain ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          '${amount < 0 ? '-' : ''}RM ${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isMain ? 22 : 14,
            fontWeight: FontWeight.bold,
            color: isDiscount
                ? AppColors.success
                : (isMain ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
