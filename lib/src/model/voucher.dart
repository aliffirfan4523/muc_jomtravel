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
