class PaymentType {
  final int id;
  final String name;
  final String slug;
  final String icon;
  final String? description;

  PaymentType({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    this.description,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
    };
  }
}