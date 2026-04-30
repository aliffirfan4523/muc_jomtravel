import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/screen/booking/select_voucher.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

import '../../model/voucher.dart';
import 'booking_summary.dart';

class BookingForm extends StatefulWidget {
  final Package package;

  const BookingForm({super.key, required this.package});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  int adults = 1;
  int children = 0;
  bool addTourGuide = false;
  bool addMeal = false;
  bool addTransport = false;
  DateTime visitDate = DateTime.now().add(const Duration(days: 1));

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController voucherController = TextEditingController();
  Voucher? selectedVoucher;
  late String bookingSessionId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Generate a unique session ID for this booking attempt
    bookingSessionId =
        'BK-${DateTime.now().millisecondsSinceEpoch}-${FirebaseAuth.instance.currentUser?.uid?.substring(0, 5)}';
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
    }
  }

  double get _subTotal {
    double total =
        (adults * widget.package.priceAdult) +
        (children * widget.package.priceChild);
    if (addMeal) total += (adults + children) * 30;
    if (addTourGuide) total += 50;
    if (addTransport) total += 100;
    return total;
  }

  double get _currentTotal {
    double total = _subTotal;
    if (selectedVoucher != null) total -= selectedVoucher!.discountAmount;
    return total < 0 ? 0 : total;
  }

  void _validateVoucher() {
    if (selectedVoucher != null && _subTotal < selectedVoucher!.minimumSpend) {
      selectedVoucher = null;
      voucherController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher removed: Minimum spend not met.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _openVoucherSelection() async {
    final voucher = await Navigator.push<Voucher>(
      context,
      MaterialPageRoute(builder: (_) => SelectVoucherPage(currentTotal: _subTotal)),
    );

    if (voucher != null) {
      setState(() {
        selectedVoucher = voucher;
        voucherController.text = voucher.title;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Book Your Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPackageHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle('Guest Details'),
              _buildGuestCounter(),
              const SizedBox(height: 24),
              _buildSectionTitle('Visit Date'),
              _buildDatePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('Enhance Your Trip'),
              _buildAddOns(),
              const SizedBox(height: 24),
              _buildSectionTitle('Contact Information'),
              _buildContactFields(),
              const SizedBox(height: 24),
              _buildSectionTitle('Promo Code'),
              _buildVoucherSelector(),
              const SizedBox(height: 120), // Space for bottom bar
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomSummary(),
    );
  }

  Widget _buildPackageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
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
          Text(
            widget.package.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.package.location,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Starting from',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                'RM${widget.package.priceAdult}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildGuestCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _counterItem(
            'Adults',
            adults,
            (v) => setState(() { adults = v; _validateVoucher(); }),
            min: 1,
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          _counterItem(
            'Children',
            children,
            (v) => setState(() { children = v; _validateVoucher(); }),
          ),
        ],
      ),
    );
  }

  Widget _counterItem(
    String label,
    int value,
    Function(int) onChanged, {
    int min = 0,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.primary,
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: visitDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => visitDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(visitDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.edit_calendar_outlined,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOns() {
    return Column(
      children: [
        _addOnTile(
          'Tour Guide',
          'Personal expert for your group',
          50,
          addTourGuide,
          (v) => setState(() { addTourGuide = v; _validateVoucher(); }),
        ),
        const SizedBox(height: 12),
        _addOnTile(
          'Meal Package',
          'Full day local delicacies',
          30,
          addMeal,
          (v) => setState(() { addMeal = v; _validateVoucher(); }),
          perPerson: true,
        ),
        const SizedBox(height: 12),
        _addOnTile(
          'Transport',
          'Round trip hotel transfer',
          100,
          addTransport,
          (v) => setState(() { addTransport = v; _validateVoucher(); }),
        ),
      ],
    );
  }

  Widget _addOnTile(
    String title,
    String sub,
    double price,
    bool selected,
    Function(bool) onChanged, {
    bool perPerson = false,
  }) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (v) => onChanged(v!),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
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
                  Text(
                    sub,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'RM$price${perPerson ? '/pax' : ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
              border: InputBorder.none,
              labelStyle: TextStyle(color: AppColors.textLight),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            validator: (v) => v!.isEmpty ? 'Name required' : null,
          ),
          const Divider(color: AppColors.divider),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
              border: InputBorder.none,
              labelStyle: TextStyle(color: AppColors.textLight),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? 'Phone required' : null,
          ),
          const Divider(color: AppColors.divider),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
              border: InputBorder.none,
              labelStyle: TextStyle(color: AppColors.textLight),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty ? 'Email required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSelector() {
    return InkWell(
      onTap: _openVoucherSelection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.warning,
            ),
            const SizedBox(width: 12),
            Text(
              selectedVoucher?.title ?? 'Select Voucher',
              style: TextStyle(
                fontSize: 16,
                color: selectedVoucher != null
                    ? AppColors.textPrimary
                    : AppColors.textLight,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
              Text(
                'RM ${_currentTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PriceSummaryScreen(
                        package: widget.package,
                        visitDate: visitDate,
                        adults: adults,
                        children: children,
                        addTourGuide: addTourGuide,
                        addMeal: addMeal,
                        addTransport: addTransport,
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        voucher: selectedVoucher,
                        bookingSessionId: bookingSessionId,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Review Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
