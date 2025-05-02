import 'package:geolocator/geolocator.dart';
import 'package:my_prescription_app/services/location_service_interface.dart';

class MockLocationService implements LocationService {
  // Default mock location (San Francisco)
  final double _defaultLatitude = 37.7749;
  final double _defaultLongitude = -122.4194;
  
  // Map of predefined locations for testing
  final Map<String, Map<String, double>> _mockLocations = {
    'San Francisco': {'lat': 37.7749, 'lng': -122.4194},
    'New York': {'lat': 40.7128, 'lng': -74.0060},
    'London': {'lat': 51.5074, 'lng': -0.1278},
    'Tokyo': {'lat': 35.6762, 'lng': 139.6503},
    'Sydney': {'lat': -33.8688, 'lng': 151.2093},
    'nady-alahly':{'lat':30.070455,'lng': 31.356235},
  };
  
  // Currently selected location name
  String _currentLocationName = 'nady-alahly';
  
  @override
  Future<Position> getCurrentLocation() async {
    // Simulate network delay for realism
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get coordinates for current mock location
    final locationData = _mockLocations[_currentLocationName] ?? 
                         {'lat': _defaultLatitude, 'lng': _defaultLongitude};
    
    // Create a mock Position object
    return Position(
      latitude: locationData['lat']!,
      longitude: locationData['lng']!,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
  
  // Method to change mock location
  void setMockLocation(String locationName) {
    if (_mockLocations.containsKey(locationName)) {
      _currentLocationName = locationName;
    }
  }
  
  // Get available mock locations
  List<String> getAvailableLocations() {
    return _mockLocations.keys.toList();
  }
  
  // Get current location name
  String getCurrentLocationName() {
    return _currentLocationName;
  }
}