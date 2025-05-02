import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
import'package:my_prescription_app/services/location_service_interface.dart';

class RealLocationService implements LocationService {
  @override
  Future<Position?> getCurrentLocation() async {
    // First check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, we can't get the location
      return null;
    }

    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, return null
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, we cannot request permissions
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
}