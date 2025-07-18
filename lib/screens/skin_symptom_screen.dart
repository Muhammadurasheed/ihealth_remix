import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/config/theme.dart';
import 'package:ihealth_naija_test_version/main.dart';
import 'package:ihealth_naija_test_version/models/image_diagnosis_model.dart';
import 'package:ihealth_naija_test_version/providers/diagnosis_provider.dart';
import 'package:ihealth_naija_test_version/providers/image_diagnosis_provider.dart';
import 'package:ihealth_naija_test_version/helpers/skin_symptom_helper.dart';
import 'package:ihealth_naija_test_version/screens/diagnosis_results_screen.dart';
import 'package:ihealth_naija_test_version/services/storage_service.dart';
import 'package:ihealth_naija_test_version/widgets/bottom_navigation.dart';
import 'package:ihealth_naija_test_version/widgets/scan_animation.dart';
import 'package:image_picker/image_picker.dart';

class SkinSymptomScreen extends ConsumerStatefulWidget {
  const SkinSymptomScreen({super.key});

  @override
  ConsumerState<SkinSymptomScreen> createState() => _SkinSymptomScreenState();
}

class _SkinSymptomScreenState extends ConsumerState<SkinSymptomScreen> {
  File? _imageFile;
  final SkinSymptomHelper _helper = SkinSymptomHelper();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _helper.pickImage(source, context);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });

      // Reset the diagnosis state when a new image is picked
      ref.read(imageDiagnosisProvider.notifier).reset();
    }
  }

  void _analyzeImage() {
    if (_imageFile == null) return;

    // Process image diagnosis using the provider
    ref.read(imageDiagnosisProvider.notifier).analyzeImage(_imageFile!);
  }

  void _showImageSourceDialog() {
    _helper.showImageSourceDialog(context, _pickImage);
  }

  // In the SkinSymptomScreen class, add this method to get more detailed analysis
  void _getDetailedAnalysis(ImageDiagnosisModel diagnosis) async {
    if (diagnosis.analysis.isEmpty) return;

    // Get the highest confidence condition
    final highestConfidenceCondition = diagnosis.analysis.reduce(
      (curr, next) => curr.confidence > next.confidence ? curr : next,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Getting detailed analysis..."),
              ],
            ),
          ),
    );

    try {
      // Use the diagnosisFromText endpoint with the condition name
      final diagnosisController = ref.read(diagnosisControllerProvider);
      final detailedDiagnosis = await diagnosisController.diagnosisFromText(
        "I have ${highestConfidenceCondition.condition}",
      );

      // Get explanations for the condition
      final explanation = await diagnosisController.getConditionExplanation(
        highestConfidenceCondition.condition,
      );

      // Get educational content
      final education = await diagnosisController.getEducationalContent(
        highestConfidenceCondition.condition,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to the detailed results screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => DiagnosisResultsScreen(
                diagnosis: detailedDiagnosis,
                explanation: explanation,
                education: education,
                onFindClinics: () {
                  // Handle clinic finding navigation
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ref.read(currentTabProvider.notifier).state = 2; // Map tab
                  ref.read(currentScreenProvider.notifier).state =
                      AppScreen.map;
                },
              ),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting detailed analysis: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisState = ref.watch(imageDiagnosisProvider);

    final bool isAnalyzing =
        diagnosisState.status == ImageDiagnosisStatus.loading;
    final bool hasResult = diagnosisState.result != null;
    final bool hasError = diagnosisState.status == ImageDiagnosisStatus.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Skin Symptoms')),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          // Handle bottom navigation tap
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload a clear image of your skin condition',
              style: AppTheme.bodyText,
            ),
            const SizedBox(height: 8),
            const Text(
              'This will help our AI analyze possible skin conditions more accurately.',
              style: AppTheme.bodyTextMuted,
            ),
            const SizedBox(height: 24),

            // Image preview or placeholder with scan animation overlay when analyzing
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: isAnalyzing ? null : _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child:
                        _imageFile != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                            : _helper.buildImagePlaceholder(),
                  ),
                ),
                if (isAnalyzing)
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ScanAnimationWidget(
                      size: 150,
                      label: "Analyzing skin condition...",
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            if (hasError)
              _helper.buildErrorContainer(
                diagnosisState.errorMessage ??
                    'An error occurred during analysis',
              ),

            if (_imageFile == null) _helper.tipsContainer,

            if (_imageFile != null && !hasResult && !isAnalyzing && !hasError)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _analyzeImage,
                    child: const Text('Analyze Skin Condition'),
                  ),
                ),
              ),

            if (hasResult && diagnosisState.result is ImageDiagnosisModel) ...[
              const SizedBox(height: 24),
              const Text('Analysis Results', style: AppTheme.headingMedium),
              const SizedBox(height: 16),

              Builder(
                builder: (context) {
                  final imageDiagnosis =
                      diagnosisState.result as ImageDiagnosisModel;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _helper.getUrgencyColor(
                            imageDiagnosis.urgency,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _helper.getUrgencyLabel(imageDiagnosis.urgency),
                          style: TextStyle(
                            color:
                                imageDiagnosis.urgency == 'mild'
                                    ? Colors.black
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Possible Conditions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...imageDiagnosis.analysis.map<Widget>((condition) {
                              final percentage = condition.confidence;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          condition.condition,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:
                                            () => _helper.showReasoningDialog(
                                              context,
                                              condition,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppTheme.borderColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '$percentage%',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: condition.confidence / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryColor,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Medical Advice',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(imageDiagnosis.advice),
                            if (imageDiagnosis
                                .suggestedRemedies
                                .isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Suggested Remedies:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...imageDiagnosis.suggestedRemedies.map(
                                (remedy) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(remedy)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      imageDiagnosis.note,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (imageDiagnosis.ihealthNote.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.medical_services_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  imageDiagnosis.ihealthNote,
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16),
                        child: OutlinedButton.icon(
                          onPressed:
                              () => _getDetailedAnalysis(
                                diagnosisState.result as ImageDiagnosisModel,
                              ),
                          icon: const Icon(
                            Icons.analytics_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          label: const Text(
                            'Get Comprehensive Analysis',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.05,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                });
                                ref
                                    .read(imageDiagnosisProvider.notifier)
                                    .reset();
                              },
                              child: const Text('Upload a New Image'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final diagnosis =
                                    imageDiagnosis.toDiagnosisModel();
                                await ref
                                    .read(storageServiceProvider)
                                    .saveDiagnosis(diagnosis);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Save Analysis'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
