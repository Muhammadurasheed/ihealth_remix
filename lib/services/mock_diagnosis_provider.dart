// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';

// final mockDiagnosisProvider = FutureProvider.family<Diagnosis, File>((ref, imageFile) async {
//   // Simulate API call delay
//   await Future.delayed(const Duration(seconds: 3));
  
//   // Return mock data
//   return Diagnosis(
//     conditions: [
//       Condition(name: 'Eczema', probability: 0.85),
//       Condition(name: 'Contact Dermatitis', probability: 0.65),
//       Condition(name: 'Fungal Infection', probability: 0.45),
//     ],
//     urgency: 'moderate',
//     advice: 'This appears to be a form of dermatitis. Keep the area clean and dry. Avoid scratching as it may worsen the condition. Apply the recommended creams.',
//     medications: [
//       'Hydrocortisone cream for inflammation',
//       'Moisturizing lotion for dry skin',
//       'Antihistamine for itching relief if needed',
//     ],
//     insights: {
//       'Causes': [
//         'Genetic factors that affect skin barrier function',
//         'Immune system dysfunction',
//         'Environmental irritants and allergens',
//         'Excessive exposure to water or washing',
//       ],
//       'Triggers': [
//         'Certain soaps, detergents, or skincare products',
//         'Exposure to allergens like dust mites or pollen',
//         'Stress and anxiety',
//         'Weather changes, especially cold and dry conditions',
//       ],
//       'Prevention': [
//         'Moisturize daily, especially after bathing',
//         'Use mild, fragrance-free soaps and detergents',
//         'Wear protective clothing when handling potential irritants',
//         'Manage stress through relaxation techniques',
//         'Avoid known triggers specific to your condition',
//       ],
//     },
//   );
// });
