import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:my_prescription_app/models/medicine_appointment.dart';

class ApiService {
  final String _baseUrl = 'http://10.0.2.2:5000/';
  String? _lastImageId;

  Future<List<MedicineAppointment>> uploadImage(
    File imageFile,
    String prescriptionName,
  ) async {
    try {
      // Create a multipart request
      var uri = Uri.parse('$_baseUrl/predict');
      var request = http.MultipartRequest('POST', uri);

      // Add the file
      var stream = http.ByteStream(imageFile.openRead().cast());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: basename(imageFile.path),
      );
      request.files.add(multipartFile);

      // Add prescription name as a field
      request.fields['name'] = prescriptionName;

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print('Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        // First, parse the raw JSON
        final dynamic rawJson = json.decode(response.body);
        print('Raw JSON: $rawJson');
        // Save the image_id if it exists in the response
        if (rawJson is Map<String, dynamic> &&
            rawJson.containsKey('image_id')) {
          _lastImageId = rawJson['image_id'];
          print('Image ID: $_lastImageId');
        }

        List<dynamic> resultsData;

        // Handle different response formats
        if (rawJson is Map<String, dynamic> && rawJson.containsKey('results')) {
          // Format: {"results": [...]}
          resultsData = rawJson['results'];
        } else if (rawJson is List) {
          // Format: [...]
          resultsData = rawJson;
        } else {
          throw Exception('Unexpected response format');
        }

        // Now process the results data which should be a list
        return resultsData.map<MedicineAppointment>((item) {
          if (item is Map<String, dynamic>) {
            // Format: {"medicine": "...", "appointment": "..."}
            return MedicineAppointment(
              medicine: item['medicine']?.toString() ?? '',
              appointment: item['appointment']?.toString() ?? '',
              imageId: _lastImageId ?? '',
              prescriptionName:
                  item['prescription_name']?.toString() ??
                  'Unnamed Prescription',
            );
          } else if (item is List && item.length >= 2) {
            // Format: ["medicine", "appointment"]
            return MedicineAppointment(
              medicine: item[0]?.toString() ?? '',
              appointment: item[1]?.toString() ?? '',
              imageId: _lastImageId ?? '',
              prescriptionName: 'Unnamed Prescription',
            );
          } else {
            // Handle unexpected item format
            return MedicineAppointment(
              medicine: '',
              appointment: '',
              imageId: " ",
              prescriptionName: 'Unnamed Prescription',
            );
          }
        }).toList();
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Add new method for edit endpoint
  Future<dynamic> editPrescription(
    List<MedicineAppointment> appointments,
  ) async {
    try {
      // Transform appointments into pairs
      final results =
          appointments
              .map((item) => [item.medicine, item.appointment])
              .toList();

      final payload = {
        'results': results,
        'image_id':
            appointments
                .first
                .imageId, // Assuming all items have the same image_id
      };

      print('Sending payload: $payload');

      final response = await http.post(
        Uri.parse('$_baseUrl/edit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to edit prescription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error editing prescription: $e');
      rethrow;
    }
  }

  // New function to get medical appointment history
  Future<List<MedicineAppointment>> getMedicalHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/history'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Medical History: $data');

        // Create a list to store all MedicineAppointment objects
        final List<MedicineAppointment> appointments = [];

        // Process each prescription group in the data
        for (final group in data) {
          if (group is Map<String, dynamic>) {
            final List<dynamic> results = group['results'] ?? [];
            final String? dateStr = group['date']?.toString();
            final DateTime? date =
                dateStr != null ? DateTime.parse(dateStr) : null;

            // Process each medicine-appointment pair in the results
            for (final item in results) {
              if (item is List && item.length >= 2) {
                appointments.add(
                  MedicineAppointment(
                    medicine: item[0]?.toString() ?? '',
                    appointment: item[1]?.toString() ?? '',
                    imageId: '', // Since we don't have image_id in the history
                    date: date, // Use the date from the group
                    prescriptionName:
                        group['name']?.toString() ?? 'Unnamed Prescription',
                  ),
                );
              }
            }
          }
        }

        return appointments;
      } else {
        throw Exception(
          'Failed to fetch medical history: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching medical history: $e');
      rethrow;
    }
  }
}
