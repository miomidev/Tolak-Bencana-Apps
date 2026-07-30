class SavedLocationModel {
  final String id;
  final String userId;
  final String placeName;
  final double latitude;
  final double longitude;
  final String address;
  final bool isPrimary;
  final String iconType;

  SavedLocationModel({
    required this.id,
    required this.userId,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isPrimary,
    required this.iconType,
  });

  factory SavedLocationModel.fromJson(Map<String, dynamic> json) {
    return SavedLocationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      placeName: json['place_name'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      address: json['address'] ?? '',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
      iconType: json['icon_type'] ?? 'home',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'place_name': placeName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'is_primary': isPrimary,
      'icon_type': iconType,
    };
  }
}
