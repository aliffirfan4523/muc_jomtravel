import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class RedeemVoucherView extends StatefulWidget {
  RedeemVoucherView({super.key, required this.userPoints});
  final int userPoints;

  @override
  State<RedeemVoucherView> createState() => _RedeemVoucherViewState();
}

class _RedeemVoucherViewState extends State<RedeemVoucherView> {
  String selectedOption = VoucherType.All.name;
  FirebaseAuth auth = FirebaseAuth.instance;
  final VoucherService _voucherService = VoucherService();
  bool _isRedeeming = false;

  Future<void> _handleRedeem(Voucher voucher, int currentPoints) async {
    if (currentPoints < voucher.pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Insufficient points! You need ${voucher.pointsRequired} pts.",
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Redemption"),
        content: Text(
          "Are you sure you want to redeem '${voucher.title}' for ${voucher.pointsRequired} points?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Redeem"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRedeeming = true);
    try {
      await _voucherService.redeemVoucher(auth.currentUser?.uid ?? '', voucher);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Voucher redeemed successfully!"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRedeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Redeem Voucher',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final points =
                        (snapshot.data?.data()
                            as Map<String, dynamic>?)?['total_points'] ??
                        0;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your Points balance",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$points pts",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 40,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "Select Category",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                voucherTypeChipChoice(),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<List<Voucher>>(
                    stream: _voucherService.getAvailableVouchersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      final allVouchers = snapshot.data ?? [];
                      final filteredVouchers =
                          selectedOption == VoucherType.All.name
                          ? allVouchers
                          : allVouchers
                                .where(
                                  (v) =>
                                      v.type.toLowerCase() ==
                                      selectedOption.toLowerCase(),
                                )
                                .toList();

                      if (filteredVouchers.isEmpty) {
                        return const Center(
                          child: Text(
                            'No vouchers available',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filteredVouchers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final voucher = filteredVouchers[index];
                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final currentPoints =
                                  (snapshot.data?.data()
                                      as Map<
                                        String,
                                        dynamic
                                      >?)?['total_points'] ??
                                  0;
                              return VoucherCard(
                                selected: false,
                                color: AppColors.primary,
                                voucher: voucher,
                                isActive: true,
                                actionLabel: "Redeem",
                                onAction: () =>
                                    _handleRedeem(voucher, currentPoints),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isRedeeming)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget voucherTypeChipChoice() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: VoucherType.values.map((type) {
          final isSelected = selectedOption == type.name;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(type.name),
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.cardBackground,
              elevation: isSelected ? 2 : 0,
              pressElevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() => selectedOption = type.name);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
