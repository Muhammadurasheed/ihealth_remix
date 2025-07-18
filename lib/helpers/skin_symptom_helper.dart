import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/config/theme.dart';
import 'package:ihealth_naija_test_version/models/image_diagnosis_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SkinSymptomHelper {
  // Image picker methods
  Future<File?> pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      return null;
    }
  }

  void showImageSourceDialog(BuildContext context, Function(ImageSource) onSourceSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  onSourceSelected(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  onSourceSelected(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialog helpers
  void showReasoningDialog(BuildContext context, ImageDiagnosisCondition condition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(condition.condition),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analysis Reasoning:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(condition.reasoning),
              const SizedBox(height: 16),
              const Text(
                'Confidence Level:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: condition.confidence / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${condition.confidence}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // UI helpers
  Color getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'mild':
        return AppTheme.mildColor;
      case 'moderate':
        return AppTheme.moderateColor;
      case 'severe':
        return AppTheme.severeColor;
      default:
        return Colors.grey;
    }
  }

  String getUrgencyLabel(String urgency) {
    switch (urgency) {
      case 'mild':
        return 'Mild - Monitor at Home';
      case 'moderate':
        return 'Moderate - Medical Attention Advised';
      case 'severe':
        return 'Severe - Seek Immediate Care';
      default:
        return 'Unknown Urgency';
    }
  }

  // UI components as getters
  Widget get tipsContainer => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Tips for a good photo:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 8),
        Text('1. Make sure the affected area is clearly visible'),
        Text('2. Use good lighting (natural light works best)'),
        Text('3. Take the photo close to the skin condition'),
        Text('4. Include some surrounding normal skin for comparison'),
      ],
    ),
  );

  Widget buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.add_a_photo,
          size: 48,
          color: AppTheme.textMutedColor,
        ),
        SizedBox(height: 8),
        Text(
          'Tap to upload an image',
          style: AppTheme.bodyTextMuted,
        ),
      ],
    );
  }

  Widget buildErrorContainer(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(errorMessage),
        ],
      ),
    );
  }

  Widget buildAnalysisButton(bool isAnalyzing, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: isAnalyzing ? null : onPressed,
      child: isAnalyzing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text('Analyzing image...'),
              ],
            )
          : const Text('Analyze Skin Condition'),
    );
  }
}