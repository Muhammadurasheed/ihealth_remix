import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';
import 'package:ihealth_naija_test_version/models/image_diagnosis_model.dart';

import '../models/condition_explanation_model.dart';
import '../models/condition_education_model.dart';
import '../services/dio_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class DiagnosisController {
  final DioClient _dioClient;

  DiagnosisController(this._dioClient);

  Future<DiagnosisModel> diagnosisFromText(String symptoms) async {
    debugPrint('🧠 Sending text symptoms: $symptoms');
    try {
      final response = await _dioClient.post(
        '/api/diagnosis/symptom-text',
        data: {'symptoms': symptoms},
      );
      debugPrint('✅ Diagnosis from text success');
      return DiagnosisModel.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ Error in diagnosisFromText: $e');
      rethrow;
    }
  }

  Future<DiagnosisModel> diagnosisFromSpeech(String voiceText, {String? originalLanguage}) async {
    debugPrint('🎙️ Processing speech text: $voiceText');
    try {
      // Step 1: Transcribe and translate
      final translationResponse = await _dioClient.post(
        '/api/diagnosis/speech-text',
        data: {'text': voiceText},
      );
      
      // The response should contain translation and detected language
      final translated = translationResponse.data['translation'];
      final detectedLanguage = translationResponse.data['language'] ?? 'Unknown';
      
      debugPrint('🔍 Detected language: $detectedLanguage');
      debugPrint('🗣️ Translated text: $translated');

      // Create a DiagnosisModel with just the language and translation data
      return DiagnosisModel(
        conditions: [],
        severity: '',
        medicalAdvice: '',
        suggestedRemedies: [],
        note: '',
        ihealthNote: '',
        translatedText: translated,
        spokenLanguage: detectedLanguage,
      );
    } catch (e) {
      debugPrint('❌ Error in diagnosisFromSpeech: $e');
      rethrow;
    }
  }
  
  // Full diagnosis from speech - used when user submits the form
  Future<DiagnosisModel> fullDiagnosisFromSpeech(String voiceText) async {
    debugPrint('🎙️ Getting full diagnosis from speech: $voiceText');
    try {
      // Step 1: Get translation
      final speechModel = await diagnosisFromSpeech(voiceText);
      final translated = speechModel.translatedText ?? voiceText;
      
      // Step 2: Send translated text to diagnosis
      final diagnosisModel = await diagnosisFromText(translated);
      
      // Add the language detection info to the final model
      return DiagnosisModel(
        conditions: diagnosisModel.conditions,
        severity: diagnosisModel.severity,
        medicalAdvice: diagnosisModel.medicalAdvice,
        suggestedRemedies: diagnosisModel.suggestedRemedies,
        note: diagnosisModel.note,
        ihealthNote: diagnosisModel.ihealthNote,
        translatedText: speechModel.translatedText,
        spokenLanguage: speechModel.spokenLanguage,
        createdAt: diagnosisModel.createdAt,
        isFromImage: diagnosisModel.isFromImage,
      );
    } catch (e) {
      debugPrint('❌ Error in fullDiagnosisFromSpeech: $e');
      rethrow;
    }
  }

  Future<ImageDiagnosisModel> diagnosisFromImage(File imageFile) async {
    try {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await _dioClient.post(
        "/api/diagnosis/skin-image",
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      debugPrint("✅ Image Diagnosis Response: ${response.data}");

      return ImageDiagnosisModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        debugPrint('❌ Dio Error: ${e.message}');
        debugPrint('❌ Dio Response Data: ${e.response?.data}');
      } else {
        debugPrint('❌ Other Error: $e');
      }
      rethrow;
    }
  }

  Future<ConditionExplanationModel> getConditionExplanation(
    String condition,
  ) async {
    debugPrint('📖 Getting explanation for: $condition');
    try {
      final response = await _dioClient.get(
        '/api/diagnosis/explanation/$condition',
      );
      return ConditionExplanationModel.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ Error fetching explanation: $e');
      rethrow;
    }
  }

  Future<ConditionEducationModel> getEducationalContent(
    String condition,
  ) async {
    debugPrint('📚 Fetching educational content for: $condition');
    try {
      final response = await _dioClient.get(
        '/api/education/content/$condition',
      );
      return ConditionEducationModel.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ Error fetching education: $e');
      rethrow;
    }
  }
}