class Bike {
  final int id;
  final String brand;
  final String type;
  final String? bikeImage; // base64 string
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bike({
    required this.id,
    required this.brand,
    required this.type,
    this.bikeImage,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      type: json['tipe'] ?? json['type'] ?? '', // API menggunakan 'tipe'
      bikeImage: json['bikeImage'], // Bisa null jika belum ada gambar
      description: json['deskripsi'] ??
          json['description'], // API menggunakan 'deskripsi'
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'type': type,
      'bikeImage': bikeImage,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
