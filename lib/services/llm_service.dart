import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineInfoResponse {
  final String generalInfo;
  final String reasonForPrescription;
  final String usageTips;
  final String sideEffects; // New field
  final String
  contraindications; // New field for when not to take and who can't take it

  MedicineInfoResponse({
    required this.generalInfo,
    required this.reasonForPrescription,
    required this.usageTips,
    required this.sideEffects,
    required this.contraindications,
  });

  factory MedicineInfoResponse.fromJson(Map<String, dynamic> json) {
    return MedicineInfoResponse(
      generalInfo: json['generalInfo'] ?? 'Information not available',
      reasonForPrescription:
          json['reasonForPrescription'] ?? 'Information not available',
      usageTips: json['usageTips'] ?? 'Information not available',
      sideEffects: json['sideEffects'] ?? 'Information not available',
      contraindications:
          json['contraindications'] ?? 'Information not available',
    );
  }
}

class GeminiService {
  static final String apiKey = 'AIzaSyD0Bom3RLUTGszWulUaPaf8T6HqGG8W_w0';
  static const String apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<MedicineInfoResponse> getMedicineInfo(
    String medicine,
    String dosage,
  ) async {
    final prompt = '''
      You are a helpful medical assistant providing information about medications.
      Please provide detailed information about: $medicine (Dosage: $dosage).
      Format your response as JSON with these exact fields:
      {
        "generalInfo": "...",
        "reasonForPrescription": "...",
        "usageTips": "...",
        "sideEffects": "...",
        "contraindications": "..."
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
          "generationConfig": {
            "temperature": 0.5,
            "topP": 0.8,
            "topK": 40,
            "maxOutputTokens": 2000,
            "responseMimeType": "application/json",
          },
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        // Get the text response from Gemini
        final textResponse =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];

        // The text might include markdown or other formatting - we need to extract just the JSON part
        String jsonStr = textResponse;

        // Find JSON content if it's within markdown blocks or has extra text
        final jsonMatch = RegExp(r'{[\s\S]*}').firstMatch(textResponse);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(0)!;
        }

        // Now parse the JSON string into a Map
        final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
        return MedicineInfoResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Gemini API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}
