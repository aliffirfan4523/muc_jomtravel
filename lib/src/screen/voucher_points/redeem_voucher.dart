import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class RedeemVoucherView extends StatefulWidget {
  RedeemVoucherView({super.key, required this.userPoints});
  final int userPoints; // Still keep it as initial, but we will use Stream for real-time

  @override
  State<RedeemVoucherView> createState() => _RedeemVoucherViewState();
}

class _RedeemVoucherViewState extends State<RedeemVoucherView> {
  String selectedOption = VoucherType.All.name;
  final VoucherService _voucherService = VoucherService();
  bool _isRedeeming = false;



  Future<void> _handleRedeem(Voucher voucher, int currentPoints) async {
    if (currentPoints < voucher.pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Insufficient points! You need ${voucher.pointsRequired} pts.")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Redemption"),
        content: Text("Are you sure you want to redeem '${voucher.title}' for ${voucher.pointsRequired} points?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Redeem")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRedeeming = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await _voucherService.redeemVoucher(user.uid, voucher);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully redeemed ${voucher.title}!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Redeem Voucher', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (user != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                final points = (snapshot.data?.data() as Map<String, dynamic>?)?['total_points'] ?? widget.userPoints;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        "$points pts",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose a Voucher",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                voucherTypeChipChoice(),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<List<Voucher>>(
                    stream: _voucherService.getAvailableVouchersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final allVouchers = snapshot.data ?? [];
                      final filteredVouchers = selectedOption == VoucherType.All.name
                          ? allVouchers
                          : allVouchers.where((v) => v.type.toLowerCase() == selectedOption.toLowerCase()).toList();

                      if (filteredVouchers.isEmpty) {
                        return const Center(child: Text('No vouchers available'));
                      }

                      return ListView.separated(
                        itemCount: filteredVouchers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final voucher = filteredVouchers[index];
                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                            builder: (context, snapshot) {
                              final currentPoints = (snapshot.data?.data() as Map<String, dynamic>?)?['total_points'] ?? 0;
                              return VoucherCard(
                                selected: false,
                                color: Colors.blue,
                                voucher: voucher,
                                isActive: true,
                                actionLabel: "Redeem",
                                onAction: () => _handleRedeem(voucher, currentPoints),
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
              child: const Center(child: CircularProgressIndicator()),
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
                color: isSelected ? Colors.white : Colors.black87,
              ),
              selected: isSelected,
              selectedColor: Colors.blue,
              backgroundColor: Colors.white,
              elevation: isSelected ? 2 : 0,
              pressElevation: 4,
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
