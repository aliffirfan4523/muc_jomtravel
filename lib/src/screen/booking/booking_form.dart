import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/models.dart';
import 'package:muc_jomtravel/src/screen/booking/select_voucher.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

import 'package:muc_jomtravel/src/service/services.dart';
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

  int _userPoints = 0;
  final VoucherService _voucherService = VoucherService();

  @override
  void initState() {
    super.initState();
    bookingSessionId =
        'BK-${DateTime.now().millisecondsSinceEpoch}-${FirebaseAuth.instance.currentUser?.uid.substring(0, 5) ?? "USR"}';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
      final pts = await _voucherService.getUserPoints(user.uid);
      if (mounted) setState(() => _userPoints = pts);
    }
  }

  bool get _isTourGuideFree => _voucherService.isTourGuideFreeForTier(_userPoints);
  bool get _isTransportFree => _voucherService.isTransportFreeForTier(_userPoints);
  double get _basePackagePrice =>
      (adults * widget.package.priceAdult) + (children * widget.package.priceChild);
  double get _tierDiscount =>
      _voucherService.calculateTierDiscount(_basePackagePrice, _userPoints);

  double get _subTotal {
    double total = _basePackagePrice - _tierDiscount;
    if (addMeal) total += (adults + children) * 30;
    if (addTourGuide && !_isTourGuideFree) total += 50;
    if (addTransport && !_isTransportFree) total += 100;
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
      MaterialPageRoute(
          builder: (_) => SelectVoucherPage(currentTotal: _subTotal)),
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
          'Customize Experience',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPackageHeader(),
              const SizedBox(height: 20),
              _buildSectionTitle('Number of Travelers', Icons.group_rounded),
              _buildGuestCounter(),
              const SizedBox(height: 20),
              _buildSectionTitle('Select Visit Date', Icons.calendar_month_rounded),
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildSectionTitle('Optional Enhancements', Icons.auto_awesome_rounded),
              _buildAddOns(),
              const SizedBox(height: 20),
              _buildSectionTitle('Lead Traveler Details', Icons.badge_rounded),
              _buildContactFields(),
              const SizedBox(height: 20),
              _buildSectionTitle('Discounts & Promo Code', Icons.local_offer_rounded),
              _buildVoucherSelector(),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'RESERVATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.package.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.package.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _counterItem(
            'Adults (12+ yrs)',
            'RM ${widget.package.priceAdult.toStringAsFixed(0)} / pax',
            adults,
            (v) => setState(() {
              adults = v;
              _validateVoucher();
            }),
            min: 1,
          ),
          Container(width: 1, height: 44, color: AppColors.divider),
          _counterItem(
            'Children (2-11 yrs)',
            'RM ${widget.package.priceChild.toStringAsFixed(0)} / pax',
            children,
            (v) => setState(() {
              children = v;
              _validateVoucher();
            }),
            min: 0,
          ),
        ],
      ),
    );
  }

  Widget _counterItem(
    String label,
    String sub,
    int value,
    Function(int) onChanged, {
    int min = 0,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            InkWell(
              onTap: value > min ? () => onChanged(value - 1) : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: value > min
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.remove_rounded,
                  color: value > min ? AppColors.primary : AppColors.textLight,
                  size: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            InkWell(
              onTap: () => onChanged(value + 1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
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
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => visitDate = picked);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Visit Date',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(visitDate),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.edit_calendar_rounded,
              color: AppColors.primary,
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
          'Licensed Tour Guide',
          _isTourGuideFree
              ? 'Free for ${_voucherService.getTierName(_userPoints)} members'
              : 'Dedicated expert guide for personal narrative',
          _isTourGuideFree ? 0 : 50,
          addTourGuide,
          (v) => setState(() {
            addTourGuide = v;
            _validateVoucher();
          }),
          isFreeTierPerk: _isTourGuideFree,
        ),
        const SizedBox(height: 10),
        _addOnTile(
          'Gourmet Meal Voucher',
          'Full-day breakfast & lunch local set per pax',
          30,
          addMeal,
          (v) => setState(() {
            addMeal = v;
            _validateVoucher();
          }),
          perPerson: true,
        ),
        const SizedBox(height: 10),
        _addOnTile(
          'Hotel Transfer & Shuttle',
          _isTransportFree
              ? 'Free for Platinum Voyager members'
              : 'Round-trip private air-conditioned vehicle',
          _isTransportFree ? 0 : 100,
          addTransport,
          (v) => setState(() {
            addTransport = v;
            _validateVoucher();
          }),
          isFreeTierPerk: _isTransportFree,
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
    bool isFreeTierPerk = false,
  }) {
    return InkWell(
      onTap: () => onChanged(!selected),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textLight,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isFreeTierPerk)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FREE PERK',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                    fontSize: 10,
                  ),
                ),
              )
            else
              Text(
                'RM ${price.toStringAsFixed(0)}${perPerson ? '/pax' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 13,
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Lead Traveler Name',
              prefixIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              border: InputBorder.none,
              labelStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            validator: (v) => v!.isEmpty ? 'Name required' : null,
          ),
          const Divider(height: 1, color: AppColors.divider),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Contact Phone Number',
              prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary),
              border: InputBorder.none,
              labelStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? 'Phone required' : null,
          ),
          const Divider(height: 1, color: AppColors.divider),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Confirmation Email',
              prefixIcon: Icon(Icons.email_rounded, color: AppColors.primary),
              border: InputBorder.none,
              labelStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedVoucher != null
              ? AppColors.warmAmber.withValues(alpha: 0.08)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selectedVoucher != null
                ? AppColors.warmAmber
                : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.confirmation_number_rounded,
              color: selectedVoucher != null
                  ? AppColors.warmAmber
                  : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedVoucher?.title ?? 'Apply Voucher / Promo Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selectedVoucher != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (selectedVoucher != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'RM ${selectedVoucher!.discountAmount.toStringAsFixed(0)} discount applied',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textLight, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL ESTIMATE',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'RM ${_currentTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
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
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Review Summary',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
