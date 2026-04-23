import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/services.dart';

import '../../model/voucher.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class SelectVoucherPage extends StatefulWidget {
  const SelectVoucherPage({super.key});

  @override
  State<SelectVoucherPage> createState() => _SelectVoucherPageState();
}

class _SelectVoucherPageState extends State<SelectVoucherPage> {
  final TextEditingController _voucherCodeController = TextEditingController();
  int? _selectedIndex;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final VoucherService _voucherService = VoucherService();
  List<Voucher> vouchers = [];

  @override
  void initState() {
    super.initState();
    //Pull vouchers from backend for the user
    _voucherService.getUserVouchers(uid).then((vouchers) {
      setState(() {
        this.vouchers = vouchers;
      });
    });
  }

  @override
  void dispose() {
    _voucherCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color shopeeOrange = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: shopeeOrange,
        foregroundColor: Colors.white,
        title: const Text('Select Voucher'),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: shopeeOrange,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_num_outlined,
                    color: shopeeOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _voucherCodeController,
                      decoration: const InputDecoration(
                        hintText: 'Enter voucher code',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: shopeeOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vouchers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                final selected = _selectedIndex == index;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedIndex = index),
                  child: VoucherCard(
                    selected: selected,
                    color: shopeeOrange,
                    voucher: voucher,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex == null
                      ? null
                      : () => Navigator.pop(context, vouchers[_selectedIndex!]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: shopeeOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm Voucher',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
