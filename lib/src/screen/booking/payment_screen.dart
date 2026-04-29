import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';
import 'package:muc_jomtravel/src/service/booking_service.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;

  const PaymentScreen({super.key, required this.bookingId, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'TNG eWallet';
  bool _isProcessing = false;
  final BookingService _bookingService = BookingService();

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'TNG eWallet', 'icon': Icons.account_balance_wallet_outlined, 'color': Colors.blue},
    {'name': 'Credit/Debit Card', 'icon': Icons.credit_card, 'color': Colors.orange},
    {'name': 'Online Banking', 'icon': Icons.account_balance, 'color': Colors.teal},
  ];

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      await _bookingService.markAsPaid(widget.bookingId);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 90),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your booking #${widget.bookingId.substring(0, 8).toUpperCase()} is now confirmed.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                // Primary Action: View Details
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pushReplacementNamed(
                        context, 
                        '/bookingInfo', 
                        arguments: widget.bookingId
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('View Booking Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Secondary Action: Go Home
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Secure Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isProcessing 
        ? const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 20),
              Text('Processing Payment...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ))
        : Column(
            children: [
              _buildAmountHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    bool isSelected = selectedMethod == method['name'];
                    
                    return _buildMethodTile(method, isSelected);
                  },
                ),
              ),
              _buildBottomAction(),
            ],
          ),
    );
  }

  Widget _buildAmountHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text('Total Amount to Pay', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            'RM ${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => setState(() => selectedMethod = method['name']),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(method['icon'], color: method['color'], size: 30),
              const SizedBox(width: 16),
              Text(
                method['name'],
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text('Pay RM ${widget.amount.toStringAsFixed(2)} Now', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
