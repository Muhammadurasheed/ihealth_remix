import 'package:ihealth_naija_test_version/models/education_point.dart';

class ConditionContent {
  final String condition;
  final String overview;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> preventions;
  final List<String> treatments;
  final List<EducationPoint> educationPoints;

  ConditionContent({
    required this.condition,
    required this.overview,
    required this.symptoms,
    required this.causes,
    required this.preventions,
    required this.treatments,
    required this.educationPoints,
  });

  factory ConditionContent.fromJson(Map<String, dynamic> json) {
    return ConditionContent(
      condition: json['condition'] ?? '',
      overview: json['overview'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      causes: List<String>.from(json['causes'] ?? []),
      preventions: List<String>.from(json['preventions'] ?? []),
      treatments: List<String>.from(json['treatments'] ?? []),
      educationPoints: json['educationPoints'] != null
          ? List<EducationPoint>.from(
              json['educationPoints'].map((x) => EducationPoint.fromJson(x)))
          : [],
    );
  }
}

// class EducationPoint {
//   final String title;
//   final String description;
//   final String? imageUrl;

//   EducationPoint({
//     required this.title,
//     required this.description,
//     this.imageUrl, required String emoji, required String text,
//   });

//   factory EducationPoint.fromJson(Map<String, dynamic> json) {
//     return EducationPoint(
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       imageUrl: json['imageUrl'],
//     );
//   }
// }
