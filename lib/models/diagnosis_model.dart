class DiagnosisModel {
  final List<ConditionResult> conditions;
  final String severity;
  final String medicalAdvice;
  final List<String> suggestedRemedies;
  final String note;
  final String ihealthNote;
  final DateTime createdAt;
  final bool isFromImage;
  final String? translatedText;     // ✅ NEW
  final String? spokenLanguage;     // ✅ NEW

  DiagnosisModel({
    required this.conditions,
    required this.severity,
    required this.medicalAdvice,
    required this.suggestedRemedies,
    required this.note,
    required this.ihealthNote,
    this.translatedText,            // ✅ NEW
    this.spokenLanguage,           // ✅ NEW
    DateTime? createdAt,
    this.isFromImage = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    List<ConditionResult> conditionsList = [];
    if (json['conditions'] != null) {
      conditionsList = (json['conditions'] as List)
          .map((item) => ConditionResult.fromJson(item))
          .toList();
    }

    List<String> remediesList = [];
    if (json['suggestedRemedies'] != null) {
      remediesList = List<String>.from(json['suggestedRemedies']);
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      try {
        if (json['createdAt'] is String) {
          created = DateTime.parse(json['createdAt']);
        } else if (json['createdAt'] is Map &&
            json['createdAt']['\$date'] != null) {
          created = DateTime.parse(json['createdAt']['\$date']);
        }
      } catch (e) {
        print('Error parsing createdAt: $e');
      }
    }

    return DiagnosisModel(
      conditions: conditionsList,
      severity: json['severity'] ?? 'moderate',
      medicalAdvice: json['medicalAdvice'] ?? 'Please consult a healthcare professional.',
      suggestedRemedies: remediesList,
      note: json['note'] ?? '',
      ihealthNote: json['ihealthNote'] ?? 'Want a real diagnosis? Visit the iHealth Clinic page to find certified clinics near you for professional healthcare services.',
      createdAt: created,
      isFromImage: json['isFromImage'] ?? false,
      translatedText: json['translatedText'],         // ✅ NEW
      spokenLanguage: json['language'],               // ✅ NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions.map((condition) => condition.toJson()).toList(),
      'severity': severity,
      'medicalAdvice': medicalAdvice,
      'suggestedRemedies': suggestedRemedies,
      'note': note,
      'ihealthNote': ihealthNote,
      'createdAt': createdAt.toIso8601String(),
      'isFromImage': isFromImage,
      'translatedText': translatedText,               // ✅ NEW
      'spokenLanguage': spokenLanguage,               // ✅ NEW
    };
  }
}



class ConditionResult {
  final String name;
  final int confidence;

  ConditionResult({required this.name, required this.confidence});

  factory ConditionResult.fromJson(Map<String, dynamic> json) {
    // Convert confidence to double - API might send it in different formats
    double confidenceValue = 0.0;
    final rawConfidence = json['confidence'];
    if (rawConfidence is int) {
      confidenceValue = rawConfidence.toDouble();
    } else if (rawConfidence is double) {
      confidenceValue = rawConfidence;
    } else if (rawConfidence is String) {
      confidenceValue = double.tryParse(rawConfidence) ?? 0.0;
    }

    return ConditionResult(
      name: json['name'] ?? 'Unknown Condition',
      confidence: confidenceValue.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'confidence': confidence};
  }
}
