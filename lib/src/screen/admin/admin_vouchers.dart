import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/voucher_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVoucherScreen extends StatefulWidget {
  const AdminVoucherScreen({super.key});

  @override
  State<AdminVoucherScreen> createState() => _AdminVoucherScreenState();
}

class _AdminVoucherScreenState extends State<AdminVoucherScreen> {
  final VoucherService _voucherService = VoucherService();

  void _showVoucherDialog([Voucher? voucher]) {
    final isEditing = voucher != null;
    final titleController = TextEditingController(text: voucher?.title);
    final descController = TextEditingController(text: voucher?.description);
    final codeController = TextEditingController(text: voucher?.code);
    final pointsController = TextEditingController(
      text: voucher?.pointsRequired.toString(),
    );
    final discountController = TextEditingController(
      text: voucher?.discountAmount.toString(),
    );
    final minSpendController = TextEditingController(
      text: voucher?.minimumSpend.toString(),
    );
    final expiryController = TextEditingController(
      text: voucher?.expiryDate ?? 'Valid until 31 Dec 2026',
    );
    String selectedType = voucher?.type ?? VoucherType.Voucher.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Voucher' : 'Add New Voucher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. RM10 OFF)',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Voucher Code'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pointsController,
                      decoration: const InputDecoration(
                        labelText: 'Points Required',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount (RM)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: minSpendController,
                decoration: const InputDecoration(labelText: 'Min. Spend (RM)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: expiryController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date String',
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: [VoucherType.Voucher.name, VoucherType.Package.name]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => selectedType = v!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newVoucher = Voucher(
                voucherId: isEditing
                    ? voucher.voucherId
                    : DateTime.now().millisecondsSinceEpoch.toString(),
                code: codeController.text.trim(),
                title: titleController.text.trim(),
                description: descController.text.trim(),
                pointsRequired: int.tryParse(pointsController.text) ?? 0,
                discountAmount: double.tryParse(discountController.text) ?? 0,
                minimumSpend: double.tryParse(minSpendController.text) ?? 0,
                expiryDate: expiryController.text.trim(),
                type: selectedType,
                redeemed: false,
                expired: false,
              );

              if (isEditing) {
                await _voucherService.updateAvailableVoucher(newVoucher);
              } else {
                await _voucherService.createAvailableVoucher(newVoucher);
              }
              if (mounted) Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Vouchers'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Voucher>>(
        stream: _voucherService.getAvailableVouchersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vouchers = snapshot.data ?? [];

          if (vouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No vouchers found',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _seedInitialVouchers(),
                    child: const Text('Seed Sample Vouchers'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: const Icon(Icons.local_offer, color: Colors.teal),
                  ),
                  title: Text(
                    voucher.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(voucher.description),
                      const SizedBox(height: 4),
                      Text(
                        "Code: ${voucher.code} • Min Spend: RM${voucher.minimumSpend}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Points Required: ${voucher.pointsRequired} pts",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showVoucherDialog(voucher),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(voucher.voucherId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVoucherDialog(),
        backgroundColor: const Color(0xFF00695C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Voucher'),
        content: const Text(
          'Are you sure you want to delete this voucher? This will not affect users who have already redeemed it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _voucherService.deleteAvailableVoucher(id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _seedInitialVouchers() async {
    // Hardcoded initial vouchers from model
    final List<Voucher> initialVouchers = [
      Voucher(
        title: 'RM10 OFF',
        description: 'Min. spend RM50 • All Categories',
        expiryDate: 'Valid until 31 Dec 2026',
        pointsRequired: 100,
        voucherId: "VOUCHER101",
        code: "VOUCHER10",
        discountAmount: 10,
        type: VoucherType.Voucher.name,
        minimumSpend: 50,
        redeemed: false,
        expired: false,
      ),
      Voucher(
        title: '15% OFF',
        description: 'Up to RM20 • Travel Essentials',
        expiryDate: 'Valid until 30 Nov 2026',
        pointsRequired: 150,
        voucherId: "VOUCHER152",
        code: "VOUCHER15",
        discountAmount: 15,
        type: VoucherType.Voucher.name,
        minimumSpend: 20,
        redeemed: false,
        expired: false,
      ),
    ];

    for (var v in initialVouchers) {
      await _voucherService.createAvailableVoucher(v);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vouchers seeded successfully!')),
    );
  }
}
