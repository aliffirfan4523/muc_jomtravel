import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

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
  final String bookingSessionId;
  final Voucher? voucher;

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
  int _userPoints = 0;
  final BookingService _bookingService = BookingService();
  final VoucherService _voucherService = VoucherService();

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final pts = await _voucherService.getUserPoints(user.uid);
      if (mounted) setState(() => _userPoints = pts);
    }
  }

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
            content: Text('Please login to complete booking'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isConfirming = false);
      return;
    }

    try {
      final pointsEarned = _voucherService.calculatePointsEarned(
        originalPrice - discountAmount,
        userPoints: _userPoints,
      );

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
        pointsEarned: pointsEarned,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/bookingSuccesful');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing booking: $e'),
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
    final double adultTotal = widget.adults * widget.package.priceAdult;
    final double childrenTotal = widget.children * widget.package.priceChild;
    final double packageBase = adultTotal + childrenTotal;

    final bool isTourGuideFree =
        _voucherService.isTourGuideFreeForTier(_userPoints);
    final bool isTransportFree =
        _voucherService.isTransportFreeForTier(_userPoints);
    final double tierDiscountRate =
        _voucherService.getTierDiscountRate(_userPoints);
    final double tierDiscountAmount = packageBase * tierDiscountRate;

    final double mealTotal =
        widget.addMeal ? (widget.adults + widget.children) * 30 : 0;
    final double tourGuideTotal =
        (widget.addTourGuide && !isTourGuideFree) ? 50 : 0;
    final double transportTotal =
        (widget.addTransport && !isTransportFree) ? 100 : 0;

    final double grandTotal =
        packageBase + mealTotal + tourGuideTotal + transportTotal;
    final double voucherDiscount = widget.voucher?.discountAmount ?? 0;
    final double totalDiscount = tierDiscountAmount + voucherDiscount;
    final double finalPayable = grandTotal - totalDiscount;

    final int pointsEarned = _voucherService.calculatePointsEarned(
      finalPayable < 0 ? 0 : finalPayable,
      userPoints: _userPoints,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reservation Summary',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
        child: Column(
          children: [
            // Package Summary Card
            _infoCard(
              title: widget.package.title,
              subtitle: widget.package.location,
              children: [
                _row(
                  'Visit Date',
                  DateFormat('EEE, d MMMM yyyy').format(widget.visitDate),
                ),
                _row(
                  'Adults (${widget.adults})',
                  'RM ${adultTotal.toStringAsFixed(2)}',
                ),
                if (widget.children > 0)
                  _row(
                    'Children (${widget.children})',
                    'RM ${childrenTotal.toStringAsFixed(2)}',
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Lead Traveler Card
            _infoCard(
              title: 'Lead Traveler',
              children: [
                _row('Full Name', widget.name),
                _row('Phone', widget.phone),
                _row('Email', widget.email),
              ],
            ),

            const SizedBox(height: 14),

            // Enhancements Card
            if (widget.addTourGuide || widget.addMeal || widget.addTransport) ...[
              _infoCard(
                title: 'Selected Add-ons',
                children: [
                  if (widget.addTourGuide)
                    _row(
                      'Licensed Tour Guide',
                      isTourGuideFree ? 'RM 0.00 (Tier Perk)' : 'RM 50.00',
                    ),
                  if (widget.addMeal)
                    _row(
                      'Gourmet Meal Set (${widget.adults + widget.children} pax)',
                      'RM ${mealTotal.toStringAsFixed(2)}',
                    ),
                  if (widget.addTransport)
                    _row(
                      'Hotel Transfer & Shuttle',
                      isTransportFree ? 'RM 0.00 (Platinum Perk)' : 'RM 100.00',
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Itemized Receipt / Total Breakdown Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderLight, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _priceSummaryRow('Original Subtotal', grandTotal,
                      isMain: false),
                  if (tierDiscountAmount > 0) ...[
                    const SizedBox(height: 8),
                    _priceSummaryRow(
                      '${_voucherService.getTierName(_userPoints)} Discount (${(tierDiscountRate * 100).toInt()}%)',
                      -tierDiscountAmount,
                      isMain: false,
                      isDiscount: true,
                    ),
                  ],
                  if (widget.voucher != null) ...[
                    const SizedBox(height: 8),
                    _priceSummaryRow(
                      'Promo Voucher (${widget.voucher!.code})',
                      -(widget.voucher!.discountAmount),
                      isMain: false,
                      isDiscount: true,
                    ),
                  ],
                  const Divider(height: 28, color: AppColors.divider),
                  _priceSummaryRow(
                    'Total Payable',
                    finalPayable < 0 ? 0 : finalPayable,
                    isMain: true,
                  ),
                  const SizedBox(height: 16),

                  // Points Reward Banner with Tier Multiplier Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reward Points Earned',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (_voucherService.getTierMultiplier(_userPoints) > 1.0)
                                  Text(
                                    '${_voucherService.getTierMultiplier(_userPoints)}x Tier Multiplier Active',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '+$pointsEarned pts',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomConfirmDock(grandTotal, totalDiscount),
    );
  }

  Widget _infoCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceSummaryRow(String label, double amount,
      {bool isMain = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMain ? 15 : 13,
            fontWeight: isMain ? FontWeight.w800 : FontWeight.w600,
            color: isMain ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          'RM ${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isMain ? 18 : 13,
            fontWeight: isMain ? FontWeight.w900 : FontWeight.w700,
            color: isDiscount
                ? AppColors.success
                : isMain
                    ? AppColors.primary
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomConfirmDock(double grandTotal, double totalDiscount) {
    final payable = grandTotal - totalDiscount;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FINAL AMOUNT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'RM ${(payable < 0 ? 0.0 : payable).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: _isConfirming
                  ? null
                  : () => _confirmBooking(grandTotal, totalDiscount),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isConfirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm Reservation',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
