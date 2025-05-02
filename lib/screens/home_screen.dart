import 'package:flutter/material.dart';
import 'package:my_prescription_app/screens/upload_screen.dart';
import 'package:my_prescription_app/screens/pharmacy_screen.dart';
import 'package:my_prescription_app/screens/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title at the top
              const Padding(
                padding: EdgeInsets.only(top: 200),
                child: Text(
                  'Welcome to Dawy',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Buttons in the middle
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCoolButton(
                    context: context,
                    icon: Icons.upload_file,
                    label: 'Upload an Image',
                    color: Colors.blueAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UploadScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCoolButton(
                    context: context,
                    icon: Icons.local_pharmacy,
                    label: 'Find Nearby Pharmacies',
                    color: Colors.green,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PharmacyScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCoolButton(
                    context: context,
                    icon: Icons.history,
                    label: 'View Medical History',
                    color: Colors.deepPurple,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoolButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
