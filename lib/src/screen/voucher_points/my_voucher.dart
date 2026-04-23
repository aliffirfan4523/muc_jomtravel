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
  List<Voucher> activeVouchers = [];
  List<Voucher> usedExpiredVouchers = [];

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    _voucherService
        .getUserVouchers(FirebaseAuth.instance.currentUser!.uid)
        .then((vouchers) {
          setState(() {
            this.activeVouchers = vouchers
                .where((v) => !v.redeemed && !v.expired)
                .toList();
            this.usedExpiredVouchers = vouchers
                .where((v) => v.redeemed || v.expired)
                .toList();
          });
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Voucher'),
        bottom: TabBar(
          isScrollable: true,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.blue,
          tabAlignment: TabAlignment.center,
          labelPadding: EdgeInsets.symmetric(horizontal: 60.0),
          indicatorColor: Colors.blue,
          tabs: <Tab>[
            Tab(text: "Active"),
            Tab(text: "Used/Expired"),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          activeVouchers.isEmpty
              ? Center(child: Text("No active vouchers"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeVouchers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final voucher = activeVouchers[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: VoucherCard(
                        selected: false,
                        color: Colors.blue,
                        voucher: voucher,
                      ),
                    );
                  },
                ),
          usedExpiredVouchers.isEmpty
              ? Center(child: Text("No used or expired vouchers"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: usedExpiredVouchers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final voucher = usedExpiredVouchers[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: VoucherCard(
                        selected: false,
                        color: Colors.blue,
                        voucher: voucher,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
