class Package {
  final String packageId;
  final String title;
  final String description;
  final String location;
  final String duration;
  final double pricePerPerson;
  final String contactNumber;
  final String imageUrl;

  Package({
    required this.packageId,
    required this.title,
    required this.description,
    required this.location,
    required this.duration,
    required this.pricePerPerson,
    required this.contactNumber,
    required this.imageUrl,
  });

  factory Package.fromMap(Map<String, dynamic> map) {
    return Package(
      packageId: map['package_id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      duration: map['duration'],
      pricePerPerson: map['price_per_person'].toDouble(),
      contactNumber: map['contact_number'],
      imageUrl: map['image_url'],
    );
  }
}
