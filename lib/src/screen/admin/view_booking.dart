import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

class AdminViewBooking extends StatefulWidget {
  const AdminViewBooking({super.key});

  @override
  State<AdminViewBooking> createState() => _AdminViewBookingState();
}

class _AdminViewBookingState extends State<AdminViewBooking> {
  String? _expandedBookingId;
  String _selectedStatus = 'all';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusFilters = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleView(String bookingId) {
    setState(() {
      _expandedBookingId = (_expandedBookingId == bookingId) ? null : bookingId;
    });
  }

  Future<void> _updateBookingStatus({
    required String bookingId,
    required String newStatus,
    required String packageTitle,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Mark as ${_formatStatus(newStatus)}?'),
          content: Text(
            'Are you sure you want to update this booking for "$packageTitle" to ${_formatStatus(newStatus)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(newStatus),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (newStatus == 'confirmed') {
        updateData['payment_status'] = 'paid';
      }

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update(updateData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking marked as ${_formatStatus(newStatus)}.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Booking"),
          content: const Text(
            "Are you sure you want to delete this booking? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking deleted successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete booking: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Manage Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy('booking_date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading bookings:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final filteredDocs = docs.where((doc) {
                  final data = doc.data();

                  final status = _getStatus(data);
                  final query = _searchController.text.trim().toLowerCase();

                  final matchesStatus = _selectedStatus == 'all'
                      ? true
                      : status == _selectedStatus;

                  final searchableText = [
                    doc.id,
                    data['booking_id'],
                    data['user_name'],
                    data['user_email'],
                    data['user_phone'],
                    data['package_title'],
                    data['package_location'],
                    data['voucher_code'],
                    data['payment_status'],
                  ].join(' ').toLowerCase();

                  final matchesSearch =
                      query.isEmpty || searchableText.contains(query);

                  return matchesStatus && matchesSearch;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data();

                    Booking booking;

                    try {
                      booking = Booking.fromMap(data, doc.id);
                    } catch (e) {
                      return _buildErrorCard(doc.id, e.toString());
                    }

                    final isExpanded = _expandedBookingId == doc.id;

                    return _buildBookingCard(
                      bookingId: doc.id,
                      booking: booking,
                      isExpanded: isExpanded,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search booking, customer, package, phone...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((status) {
                final selected = _selectedStatus == status;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_formatStatus(status)),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard({
    required String bookingId,
    required Booking booking,
    required bool isExpanded,
  }) {
    final status = booking.status.toLowerCase();
    final shortId = bookingId.length > 6
        ? bookingId.substring(bookingId.length - 6).toUpperCase()
        : bookingId.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
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
          _buildBookingHeader(
            bookingId: bookingId,
            shortId: shortId,
            status: status,
          ),
          const SizedBox(height: 16),
          _basicInfoRow(
            icon: Icons.person,
            title: booking.userName.isEmpty
                ? 'Unknown Customer'
                : booking.userName,
            subtitle: booking.userEmail,
          ),
          const SizedBox(height: 10),
          _basicInfoRow(
            icon: Icons.phone,
            title: booking.userPhone.isEmpty
                ? 'No phone number'
                : booking.userPhone,
            subtitle: 'Customer contact',
          ),
          const SizedBox(height: 10),
          _basicInfoRow(
            icon: Icons.map,
            title: booking.packageTitle,
            subtitle: booking.packageLocation,
          ),
          if (isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppColors.divider),
            ),
            _buildExpandedDetails(booking),
          ],
          const SizedBox(height: 18),
          _buildActionButtons(
            bookingId: bookingId,
            booking: booking,
            isExpanded: isExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHeader({
    required String bookingId,
    required String shortId,
    required String status,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "BOOKING ID",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                "#$shortId",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _basicInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle.trim().isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedDetails(Booking booking) {
    final voucherText =
        booking.voucherCode == null || booking.voucherCode!.trim().isEmpty
            ? 'No voucher used'
            : booking.voucherCode!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _detailBox(
                "VISIT DATE",
                DateFormat('dd MMM yyyy').format(booking.visitDate),
                Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _detailBox(
                "GUESTS",
                "${booking.adults} Adults, ${booking.children} Children",
                Icons.groups_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _detailBox(
                "PAYMENT",
                booking.paymentStatus.toUpperCase(),
                Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _detailBox(
                "POINTS",
                "${booking.pointsEarned} pts",
                Icons.stars_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          "PRICE SUMMARY",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        _priceRow("Original Price", booking.originalPrice),
        _priceRow("Discount", booking.discountAmount, isDiscount: true),
        const Divider(color: AppColors.divider),
        _priceRow("Total Price", booking.totalPrice, isTotal: true),
        const SizedBox(height: 14),
        const Text(
          "ADD-ONS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (booking.addTourGuide) _addOnChip("Tour Guide"),
            if (booking.addMeal) _addOnChip("Meal"),
            if (booking.addTransport) _addOnChip("Transport"),
            if (!booking.addTourGuide &&
                !booking.addMeal &&
                !booking.addTransport)
              _addOnChip("None", color: AppColors.textLight),
          ],
        ),
        const SizedBox(height: 14),
        _basicInfoRow(
          icon: Icons.local_offer_outlined,
          title: voucherText,
          subtitle: 'Voucher used',
        ),
      ],
    );
  }

  Widget _detailBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isTotal ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDiscount
                  ? AppColors.success
                  : isTotal
                      ? AppColors.primary
                      : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({
    required String bookingId,
    required Booking booking,
    required bool isExpanded,
  }) {
    final status = booking.status.toLowerCase();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _toggleView(bookingId),
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                ),
                label: Text(isExpanded ? "Less Details" : "View Details"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => _deleteBooking(bookingId),
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (status != 'confirmed')
              _statusButton(
                label: 'Confirm',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                onPressed: () => _updateBookingStatus(
                  bookingId: bookingId,
                  newStatus: 'confirmed',
                  packageTitle: booking.packageTitle,
                ),
              ),
            if (status == 'confirmed')
              _statusButton(
                label: 'Complete',
                icon: Icons.done_all,
                color: AppColors.info,
                onPressed: () => _updateBookingStatus(
                  bookingId: bookingId,
                  newStatus: 'completed',
                  packageTitle: booking.packageTitle,
                ),
              ),
            if (status != 'cancelled')
              _statusButton(
                label: 'Cancel',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                onPressed: () => _updateBookingStatus(
                  bookingId: bookingId,
                  newStatus: 'cancelled',
                  packageTitle: booking.packageTitle,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _statusButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _addOnChip(String label, {Color color = AppColors.success}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_online_outlined,
              size: 80,
              color: AppColors.textLight.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            const Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing the filter or search keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String docId, String error) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          "Error parsing booking: $docId\n$error",
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  String _getStatus(Map<String, dynamic> data) {
    final status = data['status'];

    if (status == null || status.toString().trim().isEmpty) {
      return 'pending';
    }

    return status.toString().toLowerCase();
  }

  String _formatStatus(String status) {
    if (status == 'all') return 'All';

    if (status.isEmpty) return status;

    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }
}
