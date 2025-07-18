import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';
import 'package:ihealth_naija_test_version/providers/diagnosis_provider.dart';
import 'package:ihealth_naija_test_version/main.dart';

class SymptomInputController {
  /// Called when user submits text
  Future<void> handleTextSubmission(String text, WidgetRef ref) async {
    // Start full processing from text
    await ref.read(diagnosisProvider.notifier).processFullDiagnosis(text);

    final diagnosis = ref.read(diagnosisProvider).diagnosis;
    final explanation = ref.read(diagnosisProvider).explanation;
    final education = ref.read(diagnosisProvider).educationalContent;

    if (diagnosis != null && explanation != null && education != null) {
      // Push to results screen
      ref.read(currentDiagnosisProvider.notifier).state = diagnosis;
      ref.read(currentExplanationProvider.notifier).state = explanation;
      ref.read(currentEducationProvider.notifier).state = education;
      ref.read(currentScreenProvider.notifier).state = AppScreen.analyzing;
    }
  }
  
  /// Process voice transcription only (without navigating to diagnosis)
  Future<DiagnosisModel> processVoiceTranscription(String transcription, WidgetRef ref) async {
    debugPrint('🎙️ Processing voice transcription: $transcription');
    try {
      // Get the controller from the diagnosisControllerProvider
      final diagnosisController = ref.read(diagnosisControllerProvider);
      
      // This should call the API endpoint that detects language and translates
      final translationResponse = await diagnosisController.diagnosisFromSpeech(transcription);
      
      // Return the updated diagnosis model with language and translation info
      return translationResponse;
    } catch (e) {
      debugPrint('❌ Error processing voice transcription: $e');
      throw e;
    }
  }

  /// Called when voice is fully processed and user clicks submit
  Future<void> handleVoiceSubmission(
    String transcription,
    WidgetRef ref,
  ) async {
    await ref
        .read(diagnosisProvider.notifier)
        .processFullDiagnosis(transcription, isSpeech: true);

    final diagnosis = ref.read(diagnosisProvider).diagnosis;
    final explanation = ref.read(diagnosisProvider).explanation;
    final education = ref.read(diagnosisProvider).educationalContent;

    if (diagnosis != null && explanation != null && education != null) {
      ref.read(currentDiagnosisProvider.notifier).state = diagnosis;
      ref.read(currentExplanationProvider.notifier).state = explanation;
      ref.read(currentEducationProvider.notifier).state = education;
      ref.read(currentScreenProvider.notifier).state = AppScreen.analyzing;
    }
  }
}

final symptomInputControllerProvider = Provider(
  (ref) => SymptomInputController(),
);