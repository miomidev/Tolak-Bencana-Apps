class ShelterModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final int capacity;
  final int currentOccupancy;
  final String status;
  final String? contact;

  ShelterModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.capacity,
    required this.currentOccupancy,
    required this.status,
    this.contact,
  });

  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    return ShelterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      address: json['address'] ?? '',
      capacity: json['capacity'] as int? ?? 0,
      currentOccupancy: json['current_occupancy'] as int? ?? 0,
      status: json['status'] ?? 'active',
      contact: json['contact'] as String?,
    );
  }
}
