import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/utils/pulsing_text.dart';
import 'package:ihealth_naija_test_version/utils/circle_progress_painter.dart';
import 'package:ihealth_naija_test_version/providers/diagnosis_provider.dart';
import '../config/theme.dart';
import '../models/diagnosis_model.dart';
import '../services/storage_service.dart';

class AnalyzingSymptomsScreen extends ConsumerStatefulWidget {
  final Function(DiagnosisModel) onComplete;
  final String symptoms;
  final bool isSpeech;

  const AnalyzingSymptomsScreen({
    super.key,
    required this.onComplete,
    required this.symptoms,
    this.isSpeech = false,
  });

  @override
  ConsumerState<AnalyzingSymptomsScreen> createState() => _AnalyzingSymptomsScreenState();
}

class _AnalyzingSymptomsScreenState extends ConsumerState<AnalyzingSymptomsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _progress = 0;
  String _currentStep = 'Analyzing symptoms';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysis();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _runAnalysis() async {
    ref.read(diagnosisProvider.notifier).reset();

    try {
      if (widget.isSpeech) {
        await ref.read(diagnosisProvider.notifier).processFullDiagnosis(
              widget.symptoms,
              isSpeech: true,
            );
      } else {
        await ref.read(diagnosisProvider.notifier).processFullDiagnosis(
              widget.symptoms,
            );
      }

      final diagnosis = ref.read(diagnosisProvider).diagnosis;
      if (diagnosis != null) {
        await ref.read(storageServiceProvider).saveDiagnosis(diagnosis);
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisState = ref.watch(diagnosisProvider);

    if (diagnosisState.status != DiagnosisStatus.initial && mounted) {
      _progress = diagnosisState.processingProgress;
      _progressController.animateTo(_progress / 100);

      switch (diagnosisState.status) {
        case DiagnosisStatus.loading:
          _currentStep = 'Analyzing symptoms';
          break;
        case DiagnosisStatus.loadingExplanation:
          _currentStep = 'Getting condition details';
          break;
        case DiagnosisStatus.loadingEducation:
          _currentStep = 'Preparing educational content';
          break;
        case DiagnosisStatus.allDataLoaded:
          _currentStep = 'Complete';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (diagnosisState.isAllDataLoaded && mounted) {
              widget.onComplete(diagnosisState.diagnosis!);
            }
          });
          break;
        case DiagnosisStatus.error:
          setState(() {
            _hasError = true;
            _errorMessage = diagnosisState.errorMessage ?? 'Unknown error occurred';
          });
          break;
        default:
          break;
      }
    }

    if (diagnosisState.hasErrors && !_hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = diagnosisState.errorMessage ??
            diagnosisState.explanationError ??
            diagnosisState.educationError ??
            'Unknown error occurred';
      });
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _hasError ? _buildErrorView() : _buildProgressView(),
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
              ),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(120, 120),
                    painter: CircleProgressPainter(
                      progress: _progressController.value,
                      color: AppTheme.primaryColor,
                      strokeWidth: 8,
                    ),
                  );
                },
              ),
              Text(
                '$_progress%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _currentStep,
          style: AppTheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Our AI is analyzing your symptoms to provide personalized health advice.',
          style: AppTheme.bodyTextMuted,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 24),
        const PulsingText(
          text: 'This might take a moment...',
          style: TextStyle(fontSize: 14, color: AppTheme.textMutedColor),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 24),
        const Text(
          'Diagnosis Error',
          style: AppTheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Return to Symptom Input'),
        ),
      ],
    );
  }
}
