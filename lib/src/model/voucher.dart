class Voucher {
  final String voucherId;
  final String code;
  final double discountAmount;
  final String type;
  final double minimumSpend;
  final String title;
  final String description;
  final String expiryDate;
  final int pointsRequired;
  final bool redeemed;
  final bool expired;

  Voucher({
    required this.title,
    required this.description,
    required this.expiryDate,
    required this.pointsRequired,
    required this.voucherId,
    required this.code,
    required this.discountAmount,
    required this.type,
    required this.minimumSpend,
    required this.redeemed,
    this.expired = false,
  });

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      voucherId: map['voucher_id'],
      code: map['code'],
      discountAmount: map['discount_amount'].toDouble(),
      type: map['type'],
      minimumSpend: map['minimum_spend'].toDouble(),
      title: map['title'],
      description: map['description'],
      expiryDate: map['expiry_date'],
      pointsRequired: map['points_required'],
      redeemed: map['redeemed'] ?? false,
      expired: map['expired'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'voucher_id': voucherId,
    'code': code,
    'discount_amount': discountAmount,
    'type': type,
    'minimum_spend': minimumSpend,
    'title': title,
    'description': description,
    'expiry_date': expiryDate,
    'points_required': pointsRequired,
    'redeemed': redeemed,
    'expired': expired,
  };
}

enum VoucherType { All, Package, Voucher }

final List<Voucher> vouchers = [
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
    voucherId: "VOUCHER15",
    code: "VOUCHER152",
    discountAmount: 15,
    type: VoucherType.Voucher.name,
    minimumSpend: 20,
    redeemed: false,
    expired: false,
  ),
  Voucher(
    title: '15% OFF',
    description: 'Up to RM20 • Travel Essentials',
    expiryDate: 'Valid until 30 Nov 2026',
    pointsRequired: 150,
    voucherId: "VOUCHER15",
    code: "VOUCHER153",
    discountAmount: 15,
    type: VoucherType.Voucher.name,
    minimumSpend: 20,
    redeemed: false,
    expired: false,
  ),
  Voucher(
    title: '15% OFF',
    description: 'Up to RM20 • Travel Essentials',
    expiryDate: 'Valid until 30 Nov 2026',
    pointsRequired: 150,
    voucherId: "VOUCHER154",
    code: "VOUCHER15",
    discountAmount: 15,
    type: VoucherType.Voucher.name,
    minimumSpend: 20,
    redeemed: false,
    expired: false,
  ),
];
