import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_prescription_app/services/service_provider.dart';
import 'package:my_prescription_app/services/location_service_interface.dart';
import 'package:my_prescription_app/services/pharmacy_service.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  _PharmacyScreenState createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  bool _isLoading = false;
  Position? _currentPosition;
  List<Map<String, dynamic>> _pharmacies = [];
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  // Get services
  final LocationService _locationService = ServiceProvider.getLocationService();
  final PharmacyService _pharmacyService = PharmacyService();

  // Check if we're using mock services
  final bool _usingMockServices = ServiceProvider.useMockServices;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentPosition = position;
        });

        // Search for nearby pharmacies once we have location
        await _searchNearbyPharmacies();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unable to get location')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchNearbyPharmacies() async {
    if (_currentPosition == null) return;

    try {
      final pharmacies = await _pharmacyService.searchNearbyPharmacies(
        _currentPosition!,
      );

      setState(() {
        _pharmacies = pharmacies;
        _updateMarkers();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching pharmacies: $e')));
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Add marker for current location
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add markers for pharmacies
    for (int i = 0; i < _pharmacies.length; i++) {
      final pharmacy = _pharmacies[i];
      final location = pharmacy['geometry']['location'];

      _markers.add(
        Marker(
          markerId: MarkerId('pharmacy_$i'),
          position: LatLng(location['lat'], location['lng']),
          infoWindow: InfoWindow(
            title: pharmacy['name'],
            snippet: pharmacy['vicinity'],
          ),
        ),
      );
    }
  }

  // Method to handle calling a pharmacy
  Future<void> _callPharmacy(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch phone dialer')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Method to show location selection dialog if using mock services
  void _showLocationSelectionDialog() {
    if (!_usingMockServices) return;

    final mockService = ServiceProvider.getMockLocationService();
    if (mockService == null) return;

    final locations = mockService.getAvailableLocations();
    final currentLocation = mockService.getCurrentLocationName();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Mock Location'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final isSelected = location == currentLocation;

                  return ListTile(
                    title: Text(location),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      mockService.setMockLocation(location);
                      Navigator.pop(context);
                      _getCurrentLocation();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pharmacies'),
        actions: [
          // Show location selection button if using mock services
          if (_usingMockServices)
            IconButton(
              icon: const Icon(Icons.location_on),
              tooltip: 'Select mock location',
              onPressed: _showLocationSelectionDialog,
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentPosition == null
              ? const Center(child: Text('Unable to get your location'))
              : Column(
                children: [
                  // Mock location indicator
                  if (_usingMockServices)
                    Container(
                      color: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Using mock location for testing',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 14,
                      ),
                      markers: _markers,
                      myLocationEnabled: !_usingMockServices,
                      myLocationButtonEnabled: !_usingMockServices,
                    ),
                  ),
                  Expanded(
                    child:
                        _pharmacies.isEmpty
                            ? const Center(
                              child: Text('No pharmacies found nearby'),
                            )
                            : ListView.builder(
                              itemCount: _pharmacies.length,
                              itemBuilder: (context, index) {
                                final pharmacy = _pharmacies[index];
                                // Get phone number if available
                                final String? phoneNumber =
                                    pharmacy['formatted_phone_number'];

                                return ListTile(
                                  leading: const Icon(Icons.local_pharmacy),
                                  title: Text(pharmacy['name']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(pharmacy['vicinity'] ?? ''),
                                      if (phoneNumber != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.phone, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                phoneNumber,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (pharmacy['rating'] != null) ...[
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(pharmacy['rating'].toString()),
                                        const SizedBox(width: 12),
                                      ],
                                      if (phoneNumber != null)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.call,
                                            color: Colors.green,
                                          ),
                                          onPressed:
                                              () => _callPharmacy(phoneNumber),
                                          tooltip: 'Call pharmacy',
                                        ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Center map on this pharmacy when tapped
                                    final location =
                                        pharmacy['geometry']['location'];
                                    _mapController?.animateCamera(
                                      CameraUpdate.newLatLngZoom(
                                        LatLng(
                                          location['lat'],
                                          location['lng'],
                                        ),
                                        16,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
        ],
      ),
      floatingActionButton:
          _currentPosition != null
              ? FloatingActionButton(
                onPressed: _searchNearbyPharmacies,
                child: const Icon(Icons.refresh),
              )
              : null,
    );
  }
}
