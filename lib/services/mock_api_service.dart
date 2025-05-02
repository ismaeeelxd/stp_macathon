import 'dart:io';
import 'dart:async';
import 'package:my_prescription_app/models/medicine_appointment.dart';

class MockApiService {
  // Simulate API delay
  final int _mockDelay = 2000; // milliseconds

  // Mock prescription data
  final List<List<String>> _mockPrescriptions = [
    ['Amoxicillin', '500mg, 3 times daily for 7 days'],
    ['Lisinopril', '10mg, once daily in the morning'],
    ['Metformin', '500mg, twice daily with meals'],
    ['Atorvastatin', '20mg, once daily at bedtime'],
    ['Albuterol Inhaler', '2 puffs as needed for shortness of breath'],
    ['Levothyroxine', '50mcg, once daily on empty stomach'],
  ];

  // Mock API call to simulate image upload and prescription detection
  Future<List<MedicineAppointment>> uploadImage(File imageFile) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _mockDelay));

    // Randomly select 2-4 prescriptions from the mock data
    _mockPrescriptions.shuffle();
    final int count =
        2 + (DateTime.now().millisecond % 3); // Random number between 2-4
    final selectedPrescriptions = _mockPrescriptions.take(count).toList();

    // Convert to MedicineAppointment objects
    return selectedPrescriptions.map((item) {
      return MedicineAppointment(
        medicine: item[0],
        appointment: item[1],
        imageId: 'image_id_${DateTime.now().millisecondsSinceEpoch}',
      );
    }).toList();
  }
}
