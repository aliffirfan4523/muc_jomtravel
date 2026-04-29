import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/voucher.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class MyVoucher extends StatefulWidget {
  MyVoucher({super.key});

  @override
  State<MyVoucher> createState() => _MyVoucherState();
}

class _MyVoucherState extends State<MyVoucher>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final VoucherService _voucherService = VoucherService();

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Voucher'),
        bottom: TabBar(
          isScrollable: true,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.blue,
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 60.0),
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Used/Expired"),
          ],
          controller: tabController,
        ),
      ),
      body: StreamBuilder<List<Voucher>>(
        stream: _voucherService.getUserVouchersStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vouchers = snapshot.data ?? [];
          final activeVouchers = vouchers
              .where((v) => !v.redeemed && !v.expired)
              .toList();
          final usedExpiredVouchers = vouchers
              .where((v) => v.redeemed || v.expired)
              .toList();

          return TabBarView(
            controller: tabController,
            children: [
              _buildVoucherList(activeVouchers, "No active vouchers"),
              _buildVoucherList(
                usedExpiredVouchers,
                "No used or expired vouchers",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVoucherList(List<Voucher> list, String emptyMessage) {
    if (list.isEmpty) return Center(child: Text(emptyMessage));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final voucher = list[index];
        return VoucherCard(
          selected: false,
          color: Colors.blue,
          voucher: voucher,
        );
      },
    );
  }
}
