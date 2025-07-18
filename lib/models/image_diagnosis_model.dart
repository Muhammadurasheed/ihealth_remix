import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';

class ImageDiagnosisModel {
  final List<ImageDiagnosisCondition> analysis;
  final String urgency;
  final String advice;
  final List<String> suggestedRemedies;
  final String note;
  final String ihealthNote;
  final DateTime createdAt;

  ImageDiagnosisModel({
    required this.analysis,
    required this.urgency,
    required this.advice,
    required this.suggestedRemedies,
    required this.note,
    required this.ihealthNote,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ImageDiagnosisModel.fromJson(Map<String, dynamic> json) {
    return ImageDiagnosisModel(
      analysis: (json['analysis'] as List<dynamic>? ?? [])
          .map((e) => ImageDiagnosisCondition.fromJson(e))
          .toList(),
      urgency: json['urgency'] ?? 'moderate',
      advice: json['advice'] ?? '',
      suggestedRemedies: List<String>.from(json['suggestedRemedies'] ?? []),
      note: json['note'] ?? '',
      ihealthNote: json['ihealthNote'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis': analysis.map((e) => e.toJson()).toList(),
      'urgency': urgency,
      'advice': advice,
      'suggestedRemedies': suggestedRemedies,
      'note': note,
      'ihealthNote': ihealthNote,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ImageDiagnosisCondition {
  final String condition;
  final double confidence;
  final String reasoning;

  ImageDiagnosisCondition({
    required this.condition,
    required this.confidence,
    required this.reasoning,
  });

  factory ImageDiagnosisCondition.fromJson(Map<String, dynamic> json) {
    return ImageDiagnosisCondition(
      condition: json['condition'] ?? 'Unknown',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : double.tryParse(json['confidence'].toString()) ?? 0.0,
      reasoning: json['reasoning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'confidence': confidence,
      'reasoning': reasoning,
    };
  }
}



extension ImageDiagnosisConverter on ImageDiagnosisModel {
  DiagnosisModel toDiagnosisModel() {
    return DiagnosisModel(
      severity: urgency,
      medicalAdvice: advice,
      suggestedRemedies: suggestedRemedies,
      note: note,
      ihealthNote: ihealthNote,
      conditions: analysis.map((a) => ConditionResult(
        name: a.condition,
        confidence: (a.confidence * 100).toInt(),
      )).toList(),
      isFromImage: true,
    );
  }
}
