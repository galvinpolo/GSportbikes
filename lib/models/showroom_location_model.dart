class ShowroomLocation {
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String timeZoneIdentifier;
  final String address;
  final String description;
  final String openingHours;
  final String phoneNumber;
  final String email;
  final bool isActive;

  ShowroomLocation({
    required this.name,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timeZoneIdentifier,
    required this.address,
    required this.description,
    required this.openingHours,
    required this.phoneNumber,
    required this.email,
    this.isActive = true,
  });

  @override
  String toString() {
    return 'ShowroomLocation(name: $name, city: $city, lat: $latitude, lng: $longitude)';
  }
}
