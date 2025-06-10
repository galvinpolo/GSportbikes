import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/showroom_location_model.dart';

class LocationService {
  // Daftar lokasi showroom (data dummy dengan koordinat random)
  static List<ShowroomLocation> getShowroomLocations() {
    return [
      ShowroomLocation(
        name: "GSportbikes Showroom Jakarta",
        city: "Jakarta",
        country: "Indonesia",
        latitude: -6.2088,
        longitude: 106.8456,
        timeZoneIdentifier: "WIB",
        address: "Jl. Sudirman No. 123, Jakarta Pusat",
        description: "Showroom utama dengan koleksi motor terlengkap",
        openingHours: "09:00 - 21:00",
        phoneNumber: "+62-21-1234567",
        email: "jakarta@GSportbikes.com",
      ),
      ShowroomLocation(
        name: "GSportbikes Showroom Surabaya",
        city: "Surabaya",
        country: "Indonesia",
        latitude: -7.2575,
        longitude: 112.7521,
        timeZoneIdentifier: "WIB",
        address: "Jl. Pemuda No. 456, Surabaya",
        description: "Cabang Surabaya dengan service center",
        openingHours: "08:30 - 20:30",
        phoneNumber: "+62-31-7654321",
        email: "surabaya@GSportbikes.com",
      ),
      ShowroomLocation(
        name: "GSportbikes Showroom Bandung",
        city: "Bandung",
        country: "Indonesia",
        latitude: -6.9175,
        longitude: 107.6191,
        timeZoneIdentifier: "WIB",
        address: "Jl. Asia Afrika No. 789, Bandung",
        description: "Showroom dengan spesialisasi motor sport",
        openingHours: "09:00 - 20:00",
        phoneNumber: "+62-22-9876543",
        email: "bandung@GSportbikes.com",
      ),
      ShowroomLocation(
        name: "GSportbikes Showroom Medan",
        city: "Medan",
        country: "Indonesia",
        latitude: 3.5952,
        longitude: 98.6722,
        timeZoneIdentifier: "WIB",
        address: "Jl. Gatot Subroto No. 321, Medan",
        description: "Cabang Medan dengan bengkel resmi",
        openingHours: "08:00 - 20:00",
        phoneNumber: "+62-61-5432187",
        email: "medan@GSportbikes.com",
      ),
      ShowroomLocation(
        name: "GSportbikes Showroom Yogyakarta",
        city: "Yogyakarta",
        country: "Indonesia",
        latitude: -7.7956,
        longitude: 110.3695,
        timeZoneIdentifier: "WIB",
        address: "Jl. Malioboro No. 654, Yogyakarta",
        description: "Showroom heritage dengan motor klasik",
        openingHours: "09:30 - 21:30",
        phoneNumber: "+62-274-8765432",
        email: "yogya@GSportbikes.com",
      ),
      ShowroomLocation(
        name: "GSportbikes Showroom Makassar",
        city: "Makassar",
        country: "Indonesia",
        latitude: -5.1477,
        longitude: 119.4327,
        timeZoneIdentifier: "WITA",
        address: "Jl. Sam Ratulangi No. 987, Makassar",
        description: "Cabang Makassar dengan fasilitas test ride",
        openingHours: "08:00 - 19:00",
        phoneNumber: "+62-411-2468135",
        email: "makassar@GSportbikes.com",
      ),
    ];
  }

  // Mendapatkan lokasi user saat ini
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // Menghitung jarak antara dua koordinat
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Mencari showroom terdekat
  static List<ShowroomLocation> getNearestShowrooms(
    double userLatitude,
    double userLongitude, {
    int limit = 3,
  }) {
    final showrooms = getShowroomLocations();
    // Calculate distance for each showroom
    final showroomsWithDistance = showrooms.map((showroom) {
      final distance = calculateDistance(
        userLatitude,
        userLongitude,
        showroom.latitude,
        showroom.longitude,
      );
      return {
        'showroom': showroom,
        'distance': distance,
      };
    }).toList();

    // Sort by distance
    showroomsWithDistance.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // Return top nearest showrooms
    return showroomsWithDistance
        .take(limit)
        .map((item) => item['showroom'] as ShowroomLocation)
        .toList();
  }

  // Convert to LatLng for flutter_map
  static LatLng showroomLocationToLatLng(ShowroomLocation showroom) {
    return LatLng(showroom.latitude, showroom.longitude);
  }

  // Mendapatkan showroom berdasarkan kota
  static List<ShowroomLocation> getShowroomsByCity(String city) {
    return getShowroomLocations()
        .where((showroom) => showroom.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  // Default center location (Jakarta)
  static LatLng getDefaultCenter() {
    return LatLng(-6.2088, 106.8456);
  }
}
