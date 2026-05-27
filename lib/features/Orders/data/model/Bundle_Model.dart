class BundleModel {
  final String id;
  final String name;
  final String weight;
  final double price;
  final List<String> services;

  BundleModel({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    this.services = const [],
  });
}
