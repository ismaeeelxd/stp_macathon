class MedicineAppointment {
  final String medicine;
  final String appointment;
  final double price; // Added price for cart functionality
  final String imageId;
  final DateTime? date; // Added date field for history
  final String prescriptionName;

  const MedicineAppointment({
    required this.medicine,
    required this.appointment,
    this.price = 50.0, // Default price if not specified
    required this.imageId,
    this.date,
    this.prescriptionName = '',
  });

  // Copy constructor with optional parameters
  MedicineAppointment copyWith({
    String? medicine,
    String? appointment,
    double? price,
    String? imageId,
    DateTime? date,
    String? prescriptionName,
  }) {
    return MedicineAppointment(
      medicine: medicine ?? this.medicine,
      appointment: appointment ?? this.appointment,
      price: price ?? this.price,
      imageId: imageId ?? this.imageId,
      date: date ?? this.date,
      prescriptionName: prescriptionName ?? this.prescriptionName,
    );
  }

  // For equality checks in cart operations
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineAppointment &&
        other.medicine == medicine &&
        other.appointment == appointment;
  }

  @override
  int get hashCode => medicine.hashCode ^ appointment.hashCode;

  // For JSON serialization (if needed)
  Map<String, dynamic> toJson() {
    return {
      'medicine': medicine,
      'appointment': appointment,
      'price': price,
      'image_id': imageId,
      'date': date?.toIso8601String(),
      'prescription_name': prescriptionName,
    };
  }

  // From JSON constructor (if needed)
  factory MedicineAppointment.fromJson(Map<String, dynamic> json) {
    return MedicineAppointment(
      medicine: json['medicine'] as String,
      appointment: json['appointment'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageId: json['image_id'] as String,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      prescriptionName: json['prescription_name'] as String,
    );
  }
}
