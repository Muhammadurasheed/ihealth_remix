
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/community_validation_model.dart';
import '../models/diagnosis_model.dart';

class CommunityValidationState {
  final List<CommunityValidationModel> validations;
  final bool isLoading;
  final String? errorMessage;
  final double userTrustScore;
  final int totalContributions;
  final List<String> achievements;

  CommunityValidationState({
    this.validations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.userTrustScore = 0.0,
    this.totalContributions = 0,
    this.achievements = const [],
  });

  CommunityValidationState copyWith({
    List<CommunityValidationModel>? validations,
    bool? isLoading,
    String? errorMessage,
    double? userTrustScore,
    int? totalContributions,
    List<String>? achievements,
  }) {
    return CommunityValidationState(
      validations: validations ?? this.validations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userTrustScore: userTrustScore ?? this.userTrustScore,
      totalContributions: totalContributions ?? this.totalContributions,
      achievements: achievements ?? this.achievements,
    );
  }
}

class CommunityValidationNotifier extends StateNotifier<CommunityValidationState> {
  CommunityValidationNotifier() : super(CommunityValidationState());

  // Submit a diagnosis for community validation
  Future<void> submitForValidation(DiagnosisModel diagnosis) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Create anonymized version for community review
      final anonymizedHash = _createAnonymizedHash(diagnosis);
      
      final validation = CommunityValidationModel(
        validationId: DateTime.now().millisecondsSinceEpoch.toString(),
        diagnosisId: diagnosis.createdAt.millisecondsSinceEpoch.toString(),
        communityVotes: [],
        status: ValidationStatus.pending,
        accuracyScore: 0.0,
        anonymizedSymptomsHash: anonymizedHash,
      );
      
      // In real implementation, this would call your backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedValidations = [...state.validations, validation];
      
      state = state.copyWith(
        validations: updatedValidations,
        isLoading: false,
      );
      
      debugPrint('✅ Diagnosis submitted for community validation');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit for validation: $e',
      );
    }
  }

  // Vote on a community validation
  Future<void> voteOnValidation(
    String validationId, 
    bool isAccurate, 
    String? feedback,
  ) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final vote = CommunityVote(
        voterId: 'current_user_id', // Would come from auth
        voterType: 'community_member',
        isAccurate: isAccurate,
        additionalFeedback: feedback,
        timestamp: DateTime.now(),
        trustScore: state.userTrustScore.round(),
      );
      
      final updatedValidations = state.validations.map((validation) {
        if (validation.validationId == validationId) {
          final updatedVotes = [...validation.communityVotes, vote];
          final newAccuracyScore = _calculateAccuracyScore(updatedVotes);
          
          return CommunityValidationModel(
            validationId: validation.validationId,
            diagnosisId: validation.diagnosisId,
            communityVotes: updatedVotes,
            doctorValidation: validation.doctorValidation,
            status: _determineValidationStatus(updatedVotes, validation.doctorValidation),
            accuracyScore: newAccuracyScore,
            createdAt: validation.createdAt,
            anonymizedSymptomsHash: validation.anonymizedSymptomsHash,
          );
        }
        return validation;
      }).toList();
      
      state = state.copyWith(
        validations: updatedValidations,
        isLoading: false,
        totalContributions: state.totalContributions + 1,
        userTrustScore: _updateUserTrustScore(state.userTrustScore, isAccurate),
        achievements: _checkForNewAchievements(state.totalContributions + 1),
      );
      
      debugPrint('✅ Vote submitted successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit vote: $e',
      );
    }
  }

  String _createAnonymizedHash(DiagnosisModel diagnosis) {
    // Create a hash that preserves medical relevance but removes personal info
    return diagnosis.conditions.map((c) => c.name).join('|').hashCode.toString();
  }

  double _calculateAccuracyScore(List<CommunityVote> votes) {
    if (votes.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    for (var vote in votes) {
      double weight = vote.trustScore / 100.0; // Normalize trust score
      totalScore += (vote.isAccurate ? 1.0 : 0.0) * weight;
      totalWeight += weight;
    }
    
    return totalWeight > 0 ? (totalScore / totalWeight) * 100 : 0.0;
  }

  ValidationStatus _determineValidationStatus(
    List<CommunityVote> votes, 
    DoctorValidation? doctorValidation,
  ) {
    if (doctorValidation != null) {
      return ValidationStatus.doctorValidated;
    }
    
    if (votes.length >= 5) {
      double accuracyScore = _calculateAccuracyScore(votes);
      if (accuracyScore >= 80) {
        return ValidationStatus.communityValidated;
      } else if (accuracyScore <= 30) {
        return ValidationStatus.disputed;
      }
    }
    
    return ValidationStatus.pending;
  }

  double _updateUserTrustScore(double currentScore, bool accurateVote) {
    // Simplified trust score algorithm
    if (accurateVote) {
      return (currentScore + 1.0).clamp(0.0, 100.0);
    } else {
      return (currentScore - 0.5).clamp(0.0, 100.0);
    }
  }

  List<String> _checkForNewAchievements(int totalContributions) {
    List<String> achievements = [];
    
    if (totalContributions == 1) achievements.add('First Contributor');
    if (totalContributions == 10) achievements.add('Community Helper');
    if (totalContributions == 50) achievements.add('Health Guardian');
    if (totalContributions == 100) achievements.add('Wellness Champion');
    
    return achievements;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final communityValidationProvider = 
    StateNotifierProvider<CommunityValidationNotifier, CommunityValidationState>(
  (ref) => CommunityValidationNotifier(),
);
