import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

import '../../model/voucher.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class SelectVoucherPage extends StatefulWidget {
  final double currentTotal;

  const SelectVoucherPage({super.key, required this.currentTotal});

  @override
  State<SelectVoucherPage> createState() => _SelectVoucherPageState();
}

class _SelectVoucherPageState extends State<SelectVoucherPage> {
  final TextEditingController _voucherCodeController = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final VoucherService _voucherService = VoucherService();
  Voucher? _tempSelectedVoucher;

  @override
  void dispose() {
    _voucherCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Select Promo Voucher',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Voucher>>(
        stream: _voucherService.getUserVouchersStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final vouchers =
              snapshot.data?.where((v) => !v.redeemed && !v.expired).toList() ??
                  [];

          return Column(
            children: [
              // Code Entry Container
              Container(
                color: AppColors.cardBackground,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.discount_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _voucherCodeController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter voucher code (e.g. JOM10)',
                            hintStyle: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final code = _voucherCodeController.text.trim();
                          if (code.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Promo code "$code" applied!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Vouchers List
              Expanded(
                child: vouchers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_activity_outlined,
                              size: 54,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No vouchers in your wallet yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Redeem exciting vouchers in Rewards Club!',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(18),
                        itemCount: vouchers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final voucher = vouchers[index];
                          final isSelected = _tempSelectedVoucher?.voucherId ==
                              voucher.voucherId;
                          final meetsMinSpend =
                              widget.currentTotal >= voucher.minimumSpend;

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() => _tempSelectedVoucher = voucher);
                            },
                            child: Stack(
                              children: [
                                VoucherCard(
                                  selected: isSelected,
                                  color: AppColors.primary,
                                  voucher: voucher,
                                ),
                                if (!meetsMinSpend)
                                  Positioned(
                                    bottom: 8,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.error
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Min. spend RM${voucher.minimumSpend.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Confirmation Dock
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: const Border(
                    top: BorderSide(color: AppColors.borderLight, width: 1.2),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _tempSelectedVoucher == null
                        ? null
                        : () {
                            if (_tempSelectedVoucher!.minimumSpend >
                                widget.currentTotal) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Minimum spend of RM${_tempSelectedVoucher!.minimumSpend.toStringAsFixed(0)} required for this voucher.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context, _tempSelectedVoucher);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.borderLight,
                      disabledForegroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm Voucher Selection',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
