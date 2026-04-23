import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/shared/widgets/widgets.dart';

class RedeemVoucherView extends StatefulWidget {
  RedeemVoucherView({super.key, required this.userPoints});
  int userPoints;
  @override
  State<RedeemVoucherView> createState() => _RedeemVoucherViewState();
}

class _RedeemVoucherViewState extends State<RedeemVoucherView> {
  String selectedOption = VoucherType.All.name;

  List<Voucher> get filteredVouchers {
    if (selectedOption == VoucherType.All.name) return vouchers;

    return vouchers
        .where((v) => v.type.toLowerCase() == selectedOption.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Voucher'),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  "${widget.userPoints} pts",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            voucherTypeChipChoice(),
            Expanded(
              child: filteredVouchers.isEmpty
                  ? const Center(
                      child: Text(
                        'No vouchers available',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredVouchers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final selected =
                            false; // For demo, first item is selected
                        return VoucherCard(
                          selected: false,
                          color: Colors.blue,
                          voucher: filteredVouchers[index],
                          isActive: false,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Wrap voucherTypeChipChoice() {
    return Wrap(
      spacing: 8.0,
      children: VoucherType.values.map((type) {
        final isSelected = selectedOption == type.name;

        return ChoiceChip(
          showCheckmark: false,
          label: Text(type.name),
          labelStyle: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          selected: isSelected,
          selectedColor: Colors.blue,
          backgroundColor: Colors.black12,
          onSelected: (bool selected) {
            if (selected) {
              // Only update if a new chip is selected
              setState(() => selectedOption = type.name);
            }
          },
        );
      }).toList(),
    );
  }
}
