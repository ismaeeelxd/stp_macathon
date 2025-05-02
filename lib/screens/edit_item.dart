import 'package:flutter/material.dart';
import 'package:my_prescription_app/models/medicine_appointment.dart';

class EditItemScreen extends StatefulWidget {
  final MedicineAppointment item;

  const EditItemScreen({super.key, required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _medicineController;
  late TextEditingController _appointmentController;

  @override
  void initState() {
    super.initState();
    _medicineController = TextEditingController(text: widget.item.medicine);
    _appointmentController = TextEditingController(
      text: widget.item.appointment,
    );
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _appointmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _medicineController,
              decoration: const InputDecoration(
                labelText: 'Medicine',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _appointmentController,
              decoration: const InputDecoration(
                labelText: 'Appointment/Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final updatedItem = MedicineAppointment(
                  medicine: _medicineController.text,
                  appointment: _appointmentController.text,
                  imageId: widget.item.imageId,
                );
                Navigator.pop(context, updatedItem);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
