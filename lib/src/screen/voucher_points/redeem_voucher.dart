import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/voucher.dart';
import 'package:muc_jomtravel/src/shared/widgets/voucher_card.dart';

class RedeemVoucherView extends StatefulWidget {
  RedeemVoucherView({super.key, required this.userPoints});
  int userPoints;
  @override
  State<RedeemVoucherView> createState() => _RedeemVoucherViewState();
}

class _RedeemVoucherViewState extends State<RedeemVoucherView> {
  String selectedOption = VoucherType.All.name;

  List<Voucher> get filteredVouchers {
    if (selectedOption == VoucherType.All.name) {
      return sampleVouchers;
    }

    return sampleVouchers
        .where(
          (voucher) =>
              voucher.type.toLowerCase() == selectedOption.toLowerCase(),
        )
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
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredVouchers.length,
                      itemBuilder: (context, index) {
                        return VoucherCard(
                          title: filteredVouchers[index].title,
                          description: filteredVouchers[index].description,
                          cost: filteredVouchers[index].pointsRequired,
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
      spacing: 8.0, // Space between chips
      children: [
        ChoiceChip(
          showCheckmark: false,
          labelStyle: TextStyle(
            fontSize: 14,
            color: selectedOption == VoucherType.All.name
                ? Colors.white
                : Colors.black87,
          ),
          label: Text(VoucherType.All.name),
          selected: selectedOption == VoucherType.All.name,
          onSelected: (bool selected) {
            setState(() {
              selectedOption = selected ? VoucherType.All.name : "";
            });
          },
          selectedColor: Colors.blue,
          backgroundColor: Colors.black12,
        ),
        ChoiceChip(
          showCheckmark: false,
          labelStyle: TextStyle(
            fontSize: 14,
            color: selectedOption == VoucherType.Package.name
                ? Colors.white
                : Colors.black87,
          ),
          label: Text(VoucherType.Package.name),
          selected: selectedOption == VoucherType.Package.name,
          onSelected: (bool selected) {
            setState(() {
              selectedOption = selected ? VoucherType.Package.name : "";
            });
          },
          selectedColor: Colors.blue,
          backgroundColor: Colors.black12,
        ),
        ChoiceChip(
          showCheckmark: false,
          label: Text(
            VoucherType.Voucher.name,
            style: TextStyle(
              fontSize: 14,
              color: selectedOption == VoucherType.Voucher.name
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          selected: selectedOption == VoucherType.Voucher.name,
          onSelected: (bool selected) {
            setState(() {
              selectedOption = selected ? VoucherType.Voucher.name : "";
            });
          },
          selectedColor: Colors.blue,
          backgroundColor: Colors.black12,
        ),
      ],
    );
  }
}

List<Voucher> sampleVouchers = [
  Voucher(
    voucherId: "1",
    code: "10OFF",
    discountAmount: 10.0,
    type: "Voucher",
    minimumSpend: 50.0,
    title: "10% Off on Next Booking",
    description:
        "Get 10% off on your next booking with a minimum spend of \$50. Valid until 31 Dec 2024.",
    expiryDate: "2024-12-31",
    pointsRequired: 1000,
  ),
  Voucher(
    voucherId: "2",
    code: "20OFF",
    discountAmount: 20.0,
    type: "Voucher",
    minimumSpend: 100.0,
    title: "20% Off on Next Booking",
    description:
        "Get 20% off on your next booking with a minimum spend of \$100. Valid until 31 Dec 2024.",
    expiryDate: "2024-12-31",
    pointsRequired: 2000,
  ),
];
