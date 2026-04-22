import 'package:flutter/material.dart';

class MyVoucher extends StatefulWidget {
  MyVoucher({super.key});

  @override
  State<MyVoucher> createState() => _MyVoucherState();
}

class _MyVoucherState extends State<MyVoucher>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

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
            Tab(text: "User/Expired"),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Center(child: Text("Active Vouchers")),
          Center(child: Text("User/Expired Vouchers")),
        ],
      ),
    );
  }
}
