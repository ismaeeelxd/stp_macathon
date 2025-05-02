import 'package:flutter/material.dart';
import 'package:my_prescription_app/models/medicine_appointment.dart';
import 'package:my_prescription_app/services/service_provider.dart';
import 'package:my_prescription_app/screens/results_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _apiService = ServiceProvider.getApiService();
  List<MedicineAppointment> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final history = await _apiService.getMedicalHistory();

      if (!mounted) return;

      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Group prescriptions by name and date
  List<Map<String, dynamic>> _groupPrescriptions() {
    final Map<String, List<MedicineAppointment>> grouped = {};

    for (final item in _history) {
      // Create a unique key combining name and date
      final key =
          '${item.prescriptionName}_${item.date?.toIso8601String() ?? ''}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }

    // Convert to list of maps with name and date
    return grouped.entries.map((entry) {
        final prescriptions = entry.value;
        return {
          'name': prescriptions.first.prescriptionName,
          'date': prescriptions.first.date,
          'prescriptions': prescriptions,
        };
      }).toList()
      ..sort((a, b) {
        // Sort by date descending (newest first)
        final dateA = a['date'] as DateTime?;
        final dateB = b['date'] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
  }

  void _navigateToResults(List<MedicineAppointment> prescriptions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResultsScreen(medicineAppointments: prescriptions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadHistory,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _history.isEmpty
              ? const Center(child: Text('No history found'))
              : ListView.builder(
                itemCount: _groupPrescriptions().length,
                itemBuilder: (context, index) {
                  final group = _groupPrescriptions()[index];
                  final name = group['name'] as String;
                  final date = group['date'] as DateTime?;
                  final prescriptions =
                      group['prescriptions'] as List<MedicineAppointment>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isEmpty
                                          ? 'Unnamed Prescription'
                                          : name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (date != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed:
                                    () => _navigateToResults(prescriptions),
                                icon: const Icon(Icons.visibility),
                                label: const Text('View Details'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
