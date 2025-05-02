import 'dart:async';

class MedicineInfoResponse {
  final String generalInfo;
  final String reasonForPrescription;
  final String usageTips;

  MedicineInfoResponse({
    required this.generalInfo,
    required this.reasonForPrescription,
    required this.usageTips,
  });
}

class MockLlmService {
  // Simulate API delay
  final int _mockDelay = 1500; // milliseconds

  // Mock medication information database
  final Map<String, MedicineInfoResponse> _mockMedicineInfo = {
    'Amoxicillin': MedicineInfoResponse(
      generalInfo: 'Amoxicillin is an antibiotic in the penicillin group that fights bacteria in your body. It is used to treat many different types of infections caused by bacteria, such as ear infections, bladder infections, pneumonia, and E. coli or salmonella infection.',
      reasonForPrescription: 'This medication is commonly prescribed for bacterial infections. It works by stopping the growth of bacteria by preventing bacteria from forming cell walls, which eventually causes the bacteria to die.',
      usageTips: 'Take this medication with or without food as directed by your doctor, usually every 8 or 12 hours. Take with food if stomach upset occurs. Drink plenty of water while taking amoxicillin. Complete the full course as prescribed even if symptoms improve earlier.',
    ),
    'Lisinopril': MedicineInfoResponse(
      generalInfo: 'Lisinopril is an ACE inhibitor that is used to treat high blood pressure (hypertension) and heart failure. It can also improve survival after a heart attack.',
      reasonForPrescription: 'This medication works by relaxing blood vessels so blood can flow more easily. Controlling high blood pressure helps prevent strokes, heart attacks, and kidney problems.',
      usageTips: 'Take this medication at the same time each day, with or without food. If you feel dizzy, lie down and rest. Rise slowly from sitting or lying positions. Regular monitoring of blood pressure is important.',
    ),
    'Metformin': MedicineInfoResponse(
      generalInfo: 'Metformin is an oral diabetes medicine that helps control blood sugar levels. It is used together with diet and exercise to improve blood sugar control in adults with type 2 diabetes.',
      reasonForPrescription: 'Metformin decreases glucose production in the liver and increases insulin sensitivity to help your body use insulin better. It\'s often the first medication prescribed for type 2 diabetes.',
      usageTips: 'Take with meals to reduce stomach upset. Start with a low dose and gradually increase as directed. Avoid excessive alcohol. Regular blood sugar monitoring is important. Be aware of symptoms of lactic acidosis (unusual tiredness, dizziness, severe drowsiness).',
    ),
    'Atorvastatin': MedicineInfoResponse(
      generalInfo: 'Atorvastatin (Lipitor) belongs to a group of drugs called statins. It reduces levels of "bad" cholesterol (low-density lipoprotein, or LDL) and triglycerides in the blood, while increasing levels of "good" cholesterol (high-density lipoprotein, or HDL).',
      reasonForPrescription: 'This medication is prescribed to reduce the risk of heart disease, stroke, and other complications in patients with cardiovascular risk factors such as age, smoking, high blood pressure, low HDL levels, or family history of early heart disease.',
      usageTips: 'Can be taken any time of day, with or without food, though evening doses may be more effective. Avoid grapefruit products. Report unexplained muscle pain, tenderness, or weakness to your doctor immediately. Regular blood tests are needed to check liver function.',
    ),
    'Albuterol Inhaler': MedicineInfoResponse(
      generalInfo: 'Albuterol is a bronchodilator that relaxes muscles in the airways and increases air flow to the lungs. It is used to treat bronchospasm (wheezing, shortness of breath) associated with conditions like asthma and COPD.',
      reasonForPrescription: 'This quick-relief medication works rapidly to relieve sudden symptoms like wheezing, cough, shortness of breath, and chest tightness caused by asthma and other respiratory conditions.',
      usageTips: 'Shake well before each use. Use exactly as directed. Too frequent use may decrease effectiveness and increase side effects. If you need to use it more often than prescribed, contact your doctor. Keep track of how many doses remain in the canister.',
    ),
    'Levothyroxine': MedicineInfoResponse(
      generalInfo: 'Levothyroxine is a thyroid medicine that replaces a hormone normally produced by your thyroid gland to regulate the body\'s energy and metabolism. It is used to treat hypothyroidism (low thyroid hormone).',
      reasonForPrescription: 'This medication is prescribed when the thyroid gland is unable to produce enough thyroid hormone naturally, which can lead to fatigue, weight gain, increased sensitivity to cold, and other symptoms.',
      usageTips: 'Take on an empty stomach, at least 30-60 minutes before food. Take with a full glass of water. Take at the same time each day. Avoid taking with calcium supplements, iron, or antacids which can decrease absorption. Regular blood tests are needed to monitor thyroid levels.',
    ),
  };

  // Default response for medications not in our mock database
  final MedicineInfoResponse _defaultResponse = MedicineInfoResponse(
    generalInfo: 'This is a prescription medication used to treat various medical conditions. Always follow your doctor\'s instructions when taking this medication.',
    reasonForPrescription: 'Your healthcare provider has prescribed this medication based on your specific health needs. It is important to take it exactly as prescribed.',
    usageTips: 'Take as directed by your healthcare provider. Do not stop taking this medication without consulting your doctor. Report any unusual side effects promptly.',
  );

  // Mock API call to get medicine information
  Future<MedicineInfoResponse> getMedicineInfo(String medicine, String dosage) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _mockDelay));
    
    // Return mock data for the medication if it exists, otherwise return default
    return _mockMedicineInfo[medicine] ?? _defaultResponse;
  }
}