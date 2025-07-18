
class CommunityValidationModel {
  final String validationId;
  final String diagnosisId;
  final List<CommunityVote> communityVotes;
  final DoctorValidation? doctorValidation;
  final ValidationStatus status;
  final double accuracyScore;
  final DateTime createdAt;
  final String anonymizedSymptomsHash;

  CommunityValidationModel({
    required this.validationId,
    required this.diagnosisId,
    required this.communityVotes,
    this.doctorValidation,
    required this.status,
    required this.accuracyScore,
    DateTime? createdAt,
    required this.anonymizedSymptomsHash,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CommunityValidationModel.fromJson(Map<String, dynamic> json) {
    return CommunityValidationModel(
      validationId: json['validationId'] ?? '',
      diagnosisId: json['diagnosisId'] ?? '',
      communityVotes: (json['communityVotes'] as List<dynamic>? ?? [])
          .map((vote) => CommunityVote.fromJson(vote))
          .toList(),
      doctorValidation: json['doctorValidation'] != null 
          ? DoctorValidation.fromJson(json['doctorValidation'])
          : null,
      status: ValidationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ValidationStatus.pending,
      ),
      accuracyScore: (json['accuracyScore'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      anonymizedSymptomsHash: json['anonymizedSymptomsHash'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'validationId': validationId,
      'diagnosisId': diagnosisId,
      'communityVotes': communityVotes.map((vote) => vote.toJson()).toList(),
      'doctorValidation': doctorValidation?.toJson(),
      'status': status.toString().split('.').last,
      'accuracyScore': accuracyScore,
      'createdAt': createdAt.toIso8601String(),
      'anonymizedSymptomsHash': anonymizedSymptomsHash,
    };
  }
}

class CommunityVote {
  final String voterId;
  final String voterType; // 'community_member', 'health_worker', 'survivor'
  final bool isAccurate;
  final String? additionalFeedback;
  final DateTime timestamp;
  final int trustScore;

  CommunityVote({
    required this.voterId,
    required this.voterType,
    required this.isAccurate,
    this.additionalFeedback,
    required this.timestamp,
    required this.trustScore,
  });

  factory CommunityVote.fromJson(Map<String, dynamic> json) {
    return CommunityVote(
      voterId: json['voterId'] ?? '',
      voterType: json['voterType'] ?? 'community_member',
      isAccurate: json['isAccurate'] ?? false,
      additionalFeedback: json['additionalFeedback'],
      timestamp: DateTime.parse(json['timestamp']),
      trustScore: json['trustScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voterId': voterId,
      'voterType': voterType,
      'isAccurate': isAccurate,
      'additionalFeedback': additionalFeedback,
      'timestamp': timestamp.toIso8601String(),
      'trustScore': trustScore,
    };
  }
}

class DoctorValidation {
  final String doctorId;
  final String doctorName;
  final String specialization;
  final bool isAccurate;
  final String professionalFeedback;
  final DateTime validatedAt;
  final String medicalLicense;

  DoctorValidation({
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.isAccurate,
    required this.professionalFeedback,
    required this.validatedAt,
    required this.medicalLicense,
  });

  factory DoctorValidation.fromJson(Map<String, dynamic> json) {
    return DoctorValidation(
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialization: json['specialization'] ?? '',
      isAccurate: json['isAccurate'] ?? false,
      professionalFeedback: json['professionalFeedback'] ?? '',
      validatedAt: DateTime.parse(json['validatedAt']),
      medicalLicense: json['medicalLicense'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialization': specialization,
      'isAccurate': isAccurate,
      'professionalFeedback': professionalFeedback,
      'validatedAt': validatedAt.toIso8601String(),
      'medicalLicense': medicalLicense,
    };
  }
}

enum ValidationStatus {
  pending,
  communityValidated,
  doctorValidated,
  disputed,
  flagged
}
