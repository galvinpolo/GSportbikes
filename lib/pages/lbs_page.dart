import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/showroom_location_model.dart';
import '../services/location_service.dart';

class LBSPage extends StatefulWidget {
  const LBSPage({super.key});

  @override
  State<LBSPage> createState() => _LBSPageState();
}

class _LBSPageState extends State<LBSPage> {
  final MapController _mapController = MapController();
  List<ShowroomLocation> _showroomLocations = [];
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    }); // Load showroom locations
    _showroomLocations = LocationService.getShowroomLocations();

    // Try to get current location
    try {
      _currentPosition = await LocationService.getCurrentPosition();
    } catch (e) {
      print('Error getting current position: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = []; // Add showroom markers
    for (ShowroomLocation showroom in _showroomLocations) {
      markers.add(
        Marker(
          point: LocationService.showroomLocationToLatLng(showroom),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _onShowroomMarkerTapped(showroom),
            child: const Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }

    // Add current location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 30,
          height: 30,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );
    }

    return markers;
  }

  void _onShowroomMarkerTapped(ShowroomLocation showroom) {
    // Move map to selected showroom
    _mapController.move(
      LocationService.showroomLocationToLatLng(showroom),
      15.0,
    );

    // Show showroom details
    _showShowroomDetails(showroom);
  }

  void _showShowroomDetails(ShowroomLocation showroom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShowroomDetailsSheet(showroom),
    );
  }

  Widget _buildShowroomDetailsSheet(ShowroomLocation showroom) {
    String? distance;
    if (_currentPosition != null) {
      final distanceInMeters = LocationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        showroom.latitude,
        showroom.longitude,
      );
      distance = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Showroom name and distance
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            showroom.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              distance,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      showroom.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    _buildDetailRow(
                        Icons.location_on, 'Address', showroom.address),
                    const SizedBox(height: 8),

                    // Opening hours
                    _buildDetailRow(Icons.access_time, 'Opening Hours',
                        showroom.openingHours),
                    const SizedBox(height: 8),

                    // Phone
                    _buildDetailRow(Icons.phone, 'Phone', showroom.phoneNumber),
                    const SizedBox(height: 8),

                    // Email
                    _buildDetailRow(Icons.email, 'Email', showroom.email),
                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToShowroom(showroom),
                            icon: const Icon(Icons.directions),
                            label: const Text('Get Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _callShowroom(showroom),
                            icon: const Icon(Icons.call),
                            label: const Text('Call Showroom'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToShowroom(ShowroomLocation showroom) async {
    Navigator.pop(context);

    try {
      // Create URL for Google Maps with directions
      String googleMapsUrl;

      if (_currentPosition != null) {
        // If current location is available, create route from current location to showroom
        googleMapsUrl =
            'https://www.google.com/maps/dir/${_currentPosition!.latitude},${_currentPosition!.longitude}/${showroom.latitude},${showroom.longitude}';
      } else {
        // If current location is not available, just show the showroom location
        googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=${showroom.latitude},${showroom.longitude}';
      }

      // Try to launch the URL
      final Uri url = Uri.parse(googleMapsUrl);

      // For mobile platforms, we can use url_launcher package
      // But for now, we'll show a dialog with options
      _showNavigationOptions(showroom, googleMapsUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening navigation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNavigationOptions(ShowroomLocation showroom, String googleMapsUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.navigation, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Navigate to ${showroom.name}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.location_on, 'Address', showroom.address),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.gps_fixed, 'Coordinates',
                  '${showroom.latitude.toStringAsFixed(6)}, ${showroom.longitude.toStringAsFixed(6)}'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, 'Phone', showroom.phoneNumber),
              const SizedBox(height: 16),
              const Text(
                'Choose navigation method:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _copyCoordinates(showroom);
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy Coordinates'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openInternalMap(showroom);
              },
              icon: const Icon(Icons.map, size: 18),
              label: const Text('Show on Map'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openAlternativeMaps(showroom);
              },
              icon: const Icon(Icons.apps, size: 18),
              label: const Text('Other Maps'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openExternalMaps(googleMapsUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.launch, size: 18),
              label: const Text('Google Maps'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyCoordinates(ShowroomLocation showroom) async {
    final coordinates = '${showroom.latitude}, ${showroom.longitude}';
    try {
      await Clipboard.setData(ClipboardData(text: coordinates));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coordinates copied: $coordinates'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy coordinates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openInternalMap(ShowroomLocation showroom) {
    // Move the current map to the showroom location and zoom in
    _mapController.move(
      LocationService.showroomLocationToLatLng(showroom),
      16.0, // Higher zoom level for better detail
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing ${showroom.name} on map'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _openExternalMaps(String mapsUrl) async {
    try {
      final Uri url = Uri.parse(mapsUrl);

      // Check if the URL can be launched
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If can't launch, copy URL to clipboard as fallback
        await Clipboard.setData(ClipboardData(text: mapsUrl));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Could not open maps app. URL copied to clipboard.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Error handling - copy URL to clipboard as fallback
      try {
        await Clipboard.setData(ClipboardData(text: mapsUrl));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening maps: $e\nURL copied to clipboard.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (clipboardError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening maps: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _callShowroom(ShowroomLocation showroom) async {
    Navigator.pop(context);

    try {
      final Uri phoneUri = Uri.parse('tel:${showroom.phoneNumber}');

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // If can't launch phone app, copy number to clipboard
        await Clipboard.setData(ClipboardData(text: showroom.phoneNumber));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Could not open phone app. Number copied: ${showroom.phoneNumber}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Error handling - copy number to clipboard as fallback
      try {
        await Clipboard.setData(ClipboardData(text: showroom.phoneNumber));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error making call: $e\nNumber copied: ${showroom.phoneNumber}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (clipboardError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error making call: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location not available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showNearestShowrooms() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nearestShowrooms = LocationService.getNearestShowrooms(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      limit: 3,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildNearestShowroomsSheet(nearestShowrooms),
    );
  }

  Widget _buildNearestShowroomsSheet(List<ShowroomLocation> showrooms) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Nearest Showrooms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable content
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: showrooms.length,
                itemBuilder: (context, index) {
                  final showroom = showrooms[index];
                  final distance = LocationService.calculateDistance(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                    showroom.latitude,
                    showroom.longitude,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading:
                          const Icon(Icons.location_pin, color: Colors.red),
                      title: Text(showroom.name),
                      subtitle: Text(showroom.address),
                      trailing: Text(
                        '${(distance / 1000).toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onShowroomMarkerTapped(showroom);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Showroom Locations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _showNearestShowrooms,
            icon: const Icon(Icons.near_me),
            tooltip: 'Nearest Showrooms',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : LocationService.getDefaultCenter(),
              initialZoom: 10.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.semogalancartpm',
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),

          // Floating action buttons
          Positioned(
            bottom: 80,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _goToCurrentLocation,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  onPressed: _initializeData,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAlternativeMaps(ShowroomLocation showroom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Map App'),
          content: const Text('Select which map application to use:'),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openWaze(showroom);
              },
              icon: const Icon(Icons.directions_car, color: Colors.blue),
              label: const Text('Waze'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openAppleMaps(showroom);
              },
              icon: const Icon(Icons.map, color: Colors.grey),
              label: const Text('Apple Maps'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openGenericMaps(showroom);
              },
              icon: const Icon(Icons.open_in_new, color: Colors.green),
              label: const Text('Default Maps'),
            ),
          ],
        );
      },
    );
  }

  void _openWaze(ShowroomLocation showroom) async {
    String wazeUrl =
        'https://waze.com/ul?ll=${showroom.latitude},${showroom.longitude}&navigate=yes';

    try {
      final Uri url = Uri.parse(wazeUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: wazeUrl));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waze not available. URL copied to clipboard.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Waze: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openAppleMaps(ShowroomLocation showroom) async {
    String appleMapsUrl =
        'https://maps.apple.com/?ll=${showroom.latitude},${showroom.longitude}&dirflg=d';

    try {
      final Uri url = Uri.parse(appleMapsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: appleMapsUrl));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Apple Maps not available. URL copied to clipboard.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Apple Maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openGenericMaps(ShowroomLocation showroom) async {
    String genericUrl =
        'geo:${showroom.latitude},${showroom.longitude}?q=${showroom.latitude},${showroom.longitude}(${Uri.encodeComponent(showroom.name)})';

    try {
      final Uri url = Uri.parse(genericUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to Google Maps if geo: scheme doesn't work
        String googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=${showroom.latitude},${showroom.longitude}';
        final Uri fallbackUrl = Uri.parse(googleMapsUrl);
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          await Clipboard.setData(ClipboardData(text: googleMapsUrl));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maps not available. URL copied to clipboard.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
