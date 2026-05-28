import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/service/voucher_service.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

class AdminVoucherScreen extends StatefulWidget {
  const AdminVoucherScreen({super.key});

  @override
  State<AdminVoucherScreen> createState() => _AdminVoucherScreenState();
}

class _AdminVoucherScreenState extends State<AdminVoucherScreen> {
  final VoucherService _voucherService = VoucherService();

  void _showVoucherDialog([Voucher? voucher]) {
    final isEditing = voucher != null;

    final titleController = TextEditingController(text: voucher?.title ?? '');
    final descController =
        TextEditingController(text: voucher?.description ?? '');
    final codeController = TextEditingController(text: voucher?.code ?? '');
    final pointsController = TextEditingController(
      text: voucher?.pointsRequired.toString() ?? '',
    );
    final discountController = TextEditingController(
      text: voucher?.discountAmount.toString() ?? '',
    );
    final minSpendController = TextEditingController(
      text: voucher?.minimumSpend.toString() ?? '',
    );
    final expiryController = TextEditingController(
      text: voucher?.expiryDate ?? 'Valid until 31 Dec 2026',
    );

    String selectedType = voucher?.type ?? VoucherType.Voucher.name;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note_rounded : Icons.add_card_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'Edit Voucher' : 'Add New Voucher',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Example: RM10 OFF',
                          prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Example: Get RM10 off travel package',
                          prefixIcon: const Icon(Icons.description_rounded, color: AppColors.primary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: codeController,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Voucher Code',
                          hintText: 'Example: TRAVEL10',
                          prefixIcon: const Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: pointsController,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Points Required',
                                prefixIcon: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: discountController,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Discount RM',
                                prefixIcon: const Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: minSpendController,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Minimum Spend RM',
                          prefixIcon: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: expiryController,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Expiry Date Text',
                          prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                        items: [
                          VoucherType.Voucher.name,
                          VoucherType.Package.name,
                        ]
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setDialogState(() {
                            selectedType = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    final code = codeController.text.trim();

                    final points = int.tryParse(pointsController.text.trim());
                    final discount =
                        double.tryParse(discountController.text.trim());
                    final minSpend =
                        double.tryParse(minSpendController.text.trim());

                    if (title.isEmpty ||
                        desc.isEmpty ||
                        code.isEmpty ||
                        points == null ||
                        discount == null ||
                        minSpend == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all voucher fields.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final newVoucher = Voucher(
                      voucherId: isEditing
                          ? voucher.voucherId
                          : DateTime.now().millisecondsSinceEpoch.toString(),
                      code: code.toUpperCase(),
                      title: title,
                      description: desc,
                      pointsRequired: points,
                      discountAmount: discount,
                      minimumSpend: minSpend,
                      expiryDate: expiryController.text.trim(),
                      type: selectedType,
                      redeemed: false,
                      expired: false,
                    );

                    try {
                      if (isEditing) {
                        await _voucherService.updateAvailableVoucher(
                          newVoucher,
                        );
                      } else {
                        await _voucherService.createAvailableVoucher(
                          newVoucher,
                        );
                      }

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Voucher updated successfully.'
                                : 'Voucher created successfully.',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save voucher: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAdjustPointsDialog({
    required String userId,
    required String userName,
    required bool isDeduct,
  }) async {
    final pointsController = TextEditingController();
    final reasonController = TextEditingController(
      text: isDeduct
          ? 'Manual points deduction by admin'
          : 'Manual points added by admin',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isDeduct ? 'Deduct Points' : 'Add Points'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isDeduct ? 'Points to deduct' : 'Points to add',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDeduct ? AppColors.warning : AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final amount = int.tryParse(pointsController.text.trim());
                final reason = reasonController.text.trim();

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid point amount.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                try {
                  await _voucherService.adminAdjustUserPoints(
                    userId: userId,
                    points: isDeduct ? -amount : amount,
                    reason: reason.isEmpty
                        ? 'Manual points adjustment by admin'
                        : reason,
                  );

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isDeduct
                            ? '$amount points deducted successfully.'
                            : '$amount points added successfully.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update points: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text(isDeduct ? 'Deduct' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _seedInitialVouchers() async {
    final List<Voucher> initialVouchers = [
      Voucher(
        title: 'RM10 OFF',
        description: 'Min. spend RM50 • All Categories',
        expiryDate: 'Valid until 31 Dec 2026',
        pointsRequired: 100,
        voucherId: 'VOUCHER101',
        code: 'TRAVEL10',
        discountAmount: 10,
        type: VoucherType.Voucher.name,
        minimumSpend: 50,
        redeemed: false,
        expired: false,
      ),
      Voucher(
        title: 'RM15 OFF',
        description: 'Min. spend RM100 • Travel Packages',
        expiryDate: 'Valid until 31 Dec 2026',
        pointsRequired: 150,
        voucherId: 'VOUCHER152',
        code: 'TRAVEL15',
        discountAmount: 15,
        type: VoucherType.Package.name,
        minimumSpend: 100,
        redeemed: false,
        expired: false,
      ),
      Voucher(
        title: 'RM25 OFF',
        description: 'Min. spend RM200 • Premium Packages',
        expiryDate: 'Valid until 31 Dec 2026',
        pointsRequired: 250,
        voucherId: 'VOUCHER253',
        code: 'TRAVEL25',
        discountAmount: 25,
        type: VoucherType.Package.name,
        minimumSpend: 200,
        redeemed: false,
        expired: false,
      ),
    ];

    try {
      for (final voucher in initialVouchers) {
        await _voucherService.createAvailableVoucher(voucher);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Initial vouchers added successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to seed vouchers: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Voucher'),
          content: const Text(
            'Are you sure you want to delete this voucher? This will not affect users who have already redeemed it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await _voucherService.deleteAvailableVoucher(id);

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voucher deleted successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete voucher: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Manage Points & Voucher'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.stars_rounded),
                text: 'Points',
              ),
              Tab(
                icon: Icon(Icons.card_giftcard_outlined),
                text: 'Vouchers',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPointsTab(),
            _buildVoucherTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _voucherService.getUsersForPointsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading users: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
          snapshot.data?.docs ?? [],
        );

        docs.sort((a, b) {
          final aName = _getUserName(a.data()).toLowerCase();
          final bName = _getUserName(b.data()).toLowerCase();
          return aName.compareTo(bName);
        });

        if (docs.isEmpty) {
          return const Center(
            child: Text('No users found.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            final userId = data['user_id']?.toString() ?? doc.id;
            final name = _getUserName(data);
            final email = data['email']?.toString() ?? '';
            final totalPoints = _getInt(data['total_points']);
            final lifetimePoints = _getInt(data['lifetime_points']);
            final isAdmin = data['is_admin'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isAdmin
                            ? Colors.deepPurple.shade100
                            : AppColors.primaryLight,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color:
                              isAdmin ? Colors.deepPurple : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPointBox(
                          title: 'Current Points',
                          value: totalPoints.toString(),
                          icon: Icons.stars_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPointBox(
                          title: 'Lifetime Points',
                          value: lifetimePoints.toString(),
                          icon: Icons.history,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAdjustPointsDialog(
                            userId: userId,
                            userName: name,
                            isDeduct: false,
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Points'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAdjustPointsDialog(
                            userId: userId,
                            userName: name,
                            isDeduct: true,
                          ),
                          icon: const Icon(Icons.remove, size: 18),
                          label: const Text('Deduct'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPointBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.cardBackground,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showVoucherDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Voucher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              /*OutlinedButton.icon(
                onPressed: _seedInitialVouchers,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Seed Initial Vouchers'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),*/
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Voucher>>(
            stream: _voucherService.getAvailableVouchersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading vouchers: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              final vouchers = snapshot.data ?? [];

              if (vouchers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          size: 70,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No vouchers found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add a voucher or seed initial vouchers for testing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _seedInitialVouchers,
                          icon: const Icon(Icons.playlist_add_check),
                          label: const Text('Seed Initial Vouchers'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(
                          Icons.local_offer,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        voucher.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(voucher.description),
                            const SizedBox(height: 4),
                            Text(
                              'Code: ${voucher.code}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Min Spend: RM${voucher.minimumSpend.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Discount: RM${voucher.discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Points Required: ${voucher.pointsRequired} pts',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              voucher.expiryDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 2,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.info,
                            ),
                            onPressed: () => _showVoucherDialog(voucher),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                            ),
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
        ),
      ],
    );
  }

  String _getUserName(Map<String, dynamic> data) {
    final name = data['name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = data['email']?.toString().trim();

    if (email != null && email.isNotEmpty) {
      return email;
    }

    return 'Unknown User';
  }

  int _getInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }
}
