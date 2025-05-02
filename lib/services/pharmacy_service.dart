import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class PharmacyService {
  // Replace with your actual Google Places API key
  final String apiKey = 'AIzaSyC9Y-JT7Eol_Gl0RqjfitjMm7sbeP2AnPs';
  
  // Search for nearby pharmacies
  Future<List<Map<String, dynamic>>> searchNearbyPharmacies(Position position) async {
    try {
      final lat = position.latitude;
      final lng = position.longitude;
      final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=$lat,$lng'
          '&radius=5000'
          '&type=pharmacy'
          '&key=$apiKey';
          
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);
          
          // Get detailed information including phone numbers
          final detailedResults = await _getPharmacyDetails(results);
          return detailedResults;
        } else {
          print('API Error: ${data['status']}');
          return [];
        }
      } else {
        print('Network error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching pharmacies: $e');
      return [];
    }
  }
  
  // Get additional details for each pharmacy, including phone number
  Future<List<Map<String, dynamic>>> _getPharmacyDetails(List<Map<String, dynamic>> pharmacies) async {
    List<Map<String, dynamic>> detailedPharmacies = [];
    
    // Limit to first 5 pharmacies to reduce API calls (optional)
    final limitedPharmacies = pharmacies.length > 5 ? pharmacies.sublist(0, 5) : pharmacies;
    
    for (var pharmacy in limitedPharmacies) {
      try {
        final placeId = pharmacy['place_id'];
        final detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=$placeId'
            '&fields=name,vicinity,geometry,formatted_phone_number,rating,opening_hours'
            '&key=$apiKey';
            
        final response = await http.get(Uri.parse(detailsUrl));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            // Merge the details with the original pharmacy data
            final details = data['result'];
            
            // Add phone number to the pharmacy data if available
            if (details.containsKey('formatted_phone_number')) {
              pharmacy['formatted_phone_number'] = details['formatted_phone_number'];
            }
            
            // Add any other useful details
            if (details.containsKey('opening_hours')) {
              pharmacy['opening_hours'] = details['opening_hours'];
            }
            
            detailedPharmacies.add(pharmacy);
          }
        }
      } catch (e) {
        print('Error getting details for pharmacy: $e');
        // Still add the pharmacy even without details
        detailedPharmacies.add(pharmacy);
      }
    }
    
    return detailedPharmacies;
  }
}