import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_prescription_app/services/service_provider.dart';
import 'package:my_prescription_app/models/medicine_appointment.dart';
import 'package:my_prescription_app/screens/results_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _uploadStatus = '';
  final _apiService = ServiceProvider.getApiService();
  final _prescriptionNameController = TextEditingController();

  @override
  void dispose() {
    _prescriptionNameController.dispose();
    super.dispose();
  }

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // For web and Linux, just use the image directly
      setState(() {
        _image = File(image.path);
        _uploadStatus = '';
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        _uploadStatus = '';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      setState(() {
        _uploadStatus = 'Please select an image first';
      });
      return;
    }

    if (_prescriptionNameController.text.isEmpty) {
      setState(() {
        _uploadStatus = 'Please enter a prescription name';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading...';
    });

    try {
      final List<MedicineAppointment> results = await _apiService.uploadImage(
        _image!,
        _prescriptionNameController.text,
      );

      setState(() {
        _uploadStatus = 'Upload successful!';
        _isUploading = false;
      });

      if (results.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultsScreen(medicineAppointments: results),
            ),
          );
        });
      } else {
        setState(() {
          _uploadStatus = 'No prescriptions found in the image';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error uploading image: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_image!, fit: BoxFit.contain),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 48, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('No image selected'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _prescriptionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prescription Name',
                    hintText: 'Enter a name for this prescription',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _getImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _getImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadImage,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _uploadStatus,
                style: TextStyle(
                  color:
                      _uploadStatus.contains('successful')
                          ? Colors.green
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              // Add a debug button to test without image
              const SizedBox(height: 30),
              ServiceProvider.useMockServices
                  ? OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isUploading = true;
                        _uploadStatus = 'Using mock data...';
                      });

                      // Create a dummy file to pass to the mock service
                      final dummyFile = File('dummy_path');

                      // Use the mock API directly
                      Future.delayed(
                        const Duration(milliseconds: 500),
                        () async {
                          try {
                            final results = await _apiService.uploadImage(
                              dummyFile,
                            );

                            setState(() {
                              _uploadStatus = 'Mock data loaded successfully!';
                              _isUploading = false;
                            });

                            if (results.isNotEmpty) {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ResultsScreen(
                                            medicineAppointments: results,
                                          ),
                                    ),
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            setState(() {
                              _uploadStatus = 'Error loading mock data: $e';
                              _isUploading = false;
                            });
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Test with Mock Data'),
                  )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
