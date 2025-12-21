class Addon {
  final String addonId;
  final String packageId;
  final String name;
  final double price;

  Addon({
    required this.addonId,
    required this.packageId,
    required this.name,
    required this.price,
  });

  factory Addon.fromMap(Map<String, dynamic> map) {
    return Addon(
      addonId: map['addon_id'],
      packageId: map['package_id'],
      name: map['name'],
      price: map['price'].toDouble(),
    );
  }
}
