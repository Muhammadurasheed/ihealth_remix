import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/diagnosis_controller.dart';
import '../models/diagnosis_model.dart';
import '../models/condition_explanation_model.dart';
import '../models/condition_education_model.dart';
import '../services/dio_client.dart';

enum DiagnosisStatus {
  initial,
  loading,
  loadingExplanation,
  loadingEducation,
  allDataLoaded,
  error,
  success,
}

enum VoiceProcessingState {
  idle,
  recording,
  transcribing,
  detectingLanguage,
  translating,
  completed,
  error,
}

class DiagnosisState {
  final DiagnosisStatus status;
  final DiagnosisModel? diagnosis;
  final String? errorMessage;
  final ConditionExplanationModel? explanation;
  final bool isLoadingExplanation;
  final String? explanationError;
  final ConditionEducationModel? educationalContent;
  final bool isLoadingEducation;
  final String? educationError;
  final int processingProgress;
  final VoiceProcessingState voiceProcessingState;
  final String? detectedLanguage;
  final String? transcribedText;
  final String? translatedText;
  final String? recordedAudioPath;

  DiagnosisState({
    this.status = DiagnosisStatus.initial,
    this.diagnosis,
    this.errorMessage,
    this.explanation,
    this.isLoadingExplanation = false,
    this.explanationError,
    this.educationalContent,
    this.isLoadingEducation = false,
    this.educationError,
    this.processingProgress = 0,
    this.voiceProcessingState = VoiceProcessingState.idle,
    this.detectedLanguage,
    this.transcribedText,
    this.translatedText,
    this.recordedAudioPath,
  });

  DiagnosisState copyWith({
    DiagnosisStatus? status,
    DiagnosisModel? diagnosis,
    String? errorMessage,
    ConditionExplanationModel? explanation,
    bool? isLoadingExplanation,
    String? explanationError,
    ConditionEducationModel? educationalContent,
    bool? isLoadingEducation,
    String? educationError,
    int? processingProgress,
    VoiceProcessingState? voiceProcessingState,
    String? detectedLanguage,
    String? transcribedText,
    String? translatedText,
    String? recordedAudioPath,
  }) {
    return DiagnosisState(
      status: status ?? this.status,
      diagnosis: diagnosis ?? this.diagnosis,
      errorMessage: errorMessage ?? this.errorMessage,
      explanation: explanation ?? this.explanation,
      isLoadingExplanation: isLoadingExplanation ?? this.isLoadingExplanation,
      explanationError: explanationError ?? this.explanationError,
      educationalContent: educationalContent ?? this.educationalContent,
      isLoadingEducation: isLoadingEducation ?? this.isLoadingEducation,
      educationError: educationError ?? this.educationError,
      processingProgress: processingProgress ?? this.processingProgress,
      voiceProcessingState: voiceProcessingState ?? this.voiceProcessingState,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      transcribedText: transcribedText ?? this.transcribedText,
      translatedText: translatedText ?? this.translatedText,
      recordedAudioPath: recordedAudioPath ?? this.recordedAudioPath,
    );
  }

  bool get isAllDataLoaded {
    return diagnosis != null && explanation != null && educationalContent != null;
  }

  bool get hasErrors {
    return errorMessage != null || explanationError != null || educationError != null;
  }
}

class DiagnosisNotifier extends StateNotifier<DiagnosisState> {
  final DiagnosisController _controller;

  DiagnosisNotifier(this._controller) : super(DiagnosisState());

  // Method for processing voice input - handles the transcription and language detection flow
  Future<void> processVoiceInput(String transcription, {String? audioPath}) async {
    try {
      // Update state to show transcribing
      state = state.copyWith(
        voiceProcessingState: VoiceProcessingState.transcribing,
        transcribedText: transcription,
        recordedAudioPath: audioPath,
      );
      
      // Small delay to show the transcribing state visually
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update to detecting language state
      state = state.copyWith(voiceProcessingState: VoiceProcessingState.detectingLanguage);
      
      // Call the API to process the voice transcription
      final result = await _controller.diagnosisFromSpeech(transcription);
      
      // Update state with detected language
      state = state.copyWith(
        voiceProcessingState: VoiceProcessingState.translating,
        detectedLanguage: result.spokenLanguage,
      );
      
      // Small delay to show the translating state
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update with translated text
      state = state.copyWith(
        voiceProcessingState: VoiceProcessingState.completed,
        translatedText: result.translatedText ?? transcription,
      );
      
      // Return successfully
      return;
    } catch (e) {
      state = state.copyWith(
        voiceProcessingState: VoiceProcessingState.error,
        errorMessage: 'Error processing voice: ${e.toString()}',
      );
      throw e;
    }
  }

  Future<void> processFullDiagnosis(String symptoms, {bool isSpeech = false, String? originalLanguage}) async {
    try {
      state = state.copyWith(status: DiagnosisStatus.loading, processingProgress: 25);

      final DiagnosisModel diagnosis;
      if (isSpeech) {
        diagnosis = await _controller.fullDiagnosisFromSpeech(symptoms);
      } else {
        diagnosis = await _controller.diagnosisFromText(symptoms);
      }

      state = state.copyWith(
        diagnosis: diagnosis,
        processingProgress: 50,
      );

      if (diagnosis.conditions.isNotEmpty) {
        state = state.copyWith(
          status: DiagnosisStatus.loadingExplanation,
          isLoadingExplanation: true,
        );

        final primaryCondition = diagnosis.conditions
            .reduce((a, b) => a.confidence > b.confidence ? a : b)
            .name;

        try {
          final explanation = await _controller.getConditionExplanation(primaryCondition);
          state = state.copyWith(
            explanation: explanation,
            isLoadingExplanation: false,
            processingProgress: 75,
          );
        } catch (e) {
          state = state.copyWith(
            isLoadingExplanation: false,
            explanationError: 'Error loading explanation: ${e.toString()}',
          );
        }

        state = state.copyWith(
          status: DiagnosisStatus.loadingEducation,
          isLoadingEducation: true,
        );

        try {
          final educationalContent = await _controller.getEducationalContent(primaryCondition);
          state = state.copyWith(
            educationalContent: educationalContent,
            isLoadingEducation: false,
            processingProgress: 100,
          );
        } catch (e) {
          state = state.copyWith(
            isLoadingEducation: false,
            educationError: 'No educational content found for "$primaryCondition".',
          );
        }

        if (!state.hasErrors) {
          state = state.copyWith(status: DiagnosisStatus.allDataLoaded);
        }
      }
    } catch (e) {
      state = state.copyWith(
        status: DiagnosisStatus.error,
        errorMessage: 'Error analyzing symptoms: ${e.toString()}',
      );
    }
  }

  void resetVoiceProcessing() {
    state = state.copyWith(
      voiceProcessingState: VoiceProcessingState.idle,
      detectedLanguage: null,
      transcribedText: null,
      translatedText: null,
      recordedAudioPath: null,
    );
  }

  void reset() {
    state = DiagnosisState();
  }

  void diagnosisFromImage(File file) {}
}

final diagnosisControllerProvider = Provider<DiagnosisController>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiagnosisController(dioClient);
});

final diagnosisProvider = StateNotifierProvider<DiagnosisNotifier, DiagnosisState>((ref) {
  final controller = ref.watch(diagnosisControllerProvider);
  return DiagnosisNotifier(controller);
});

