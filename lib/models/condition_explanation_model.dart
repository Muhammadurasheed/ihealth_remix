class ConditionExplanationModel {
  final String condition;
  final List<String> causes;
  final List<String> triggers;
  final List<String> preventions;
  final List<String> suggestedRemedies;
  final String medicalAdvice;

  ConditionExplanationModel({
    required this.condition,
    required this.causes,
    required this.triggers,
    required this.preventions,
    required this.suggestedRemedies,
    required this.medicalAdvice,
  });

  factory ConditionExplanationModel.fromJson(Map<String, dynamic> json) {
    return ConditionExplanationModel(
      condition: json['condition'] ?? '',
      causes: List<String>.from(json['causes'] ?? []),
      triggers: List<String>.from(json['triggers'] ?? []),
      preventions: List<String>.from(json['preventions'] ?? []),
      suggestedRemedies: List<String>.from(json['suggestedRemedies'] ?? []),
      medicalAdvice: json['medicalAdvice'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'causes': causes,
      'triggers': triggers,
      'preventions': preventions,
      'suggestedRemedies': suggestedRemedies,
      'medicalAdvice': medicalAdvice,
    };
  }
}