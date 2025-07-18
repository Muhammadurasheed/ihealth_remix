import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/main.dart';
import 'package:ihealth_naija_test_version/models/condition_education_model.dart';
import 'package:ihealth_naija_test_version/models/condition_explanation_model.dart';
import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';
import 'package:ihealth_naija_test_version/services/storage_service.dart';
import 'package:ihealth_naija_test_version/utils/map_section_to_education_items.dart';
import 'package:ihealth_naija_test_version/widgets/bottom_navigation.dart';
import 'package:ihealth_naija_test_version/widgets/education_carousel.dart';
import 'package:ihealth_naija_test_version/screens/builders/build_section_card.dart';
import '../config/theme.dart';

class DiagnosisResultsScreen extends ConsumerStatefulWidget {
  final DiagnosisModel diagnosis;
  final ConditionExplanationModel explanation;
  final ConditionEducationModel education;
  final VoidCallback onFindClinics;

  const DiagnosisResultsScreen({
    Key? key,
    required this.diagnosis,
    required this.explanation,
    required this.education,
    required this.onFindClinics,
  }) : super(key: key);

  @override
  ConsumerState<DiagnosisResultsScreen> createState() => _DiagnosisResultsScreenState();
}

class _DiagnosisResultsScreenState extends ConsumerState<DiagnosisResultsScreen>
    with SingleTickerProviderStateMixin {
  bool _showInsights = false;
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _insightsAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _insightsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
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

  String _getUrgencyLabel(String urgency) {
    switch (urgency.toLowerCase()) {
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

  void _toggleInsights() {
    setState(() => _showInsights = !_showInsights);
    _showInsights ? _animationController.forward() : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final explanation = widget.explanation;
    final education = widget.education;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Assessment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Based on your symptoms, here\'s what we found:', style: AppTheme.bodyTextMuted),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getUrgencyColor(widget.diagnosis.severity),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getUrgencyLabel(widget.diagnosis.severity),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.diagnosis.severity == 'mild' ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            BuildSectionCard(
              title: 'Possible Conditions',
              content: Column(
                children: widget.diagnosis.conditions.map((condition) {
                  final percentage = (condition.confidence).round();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              condition.name,
                              softWrap: true,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$percentage%', style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: condition.confidence / 100),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            minHeight: 6,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            BuildSectionCard(
              title: 'Medical Advice',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.diagnosis.medicalAdvice),
                  if (widget.diagnosis.suggestedRemedies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text('Suggested Remedies', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...widget.diagnosis.suggestedRemedies.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(r, softWrap: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _toggleInsights,
              icon: const Icon(Icons.info_outline),
              label: Text(_showInsights ? 'Hide Insights' : 'What Caused This?'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _insightsAnimation,
              child: FadeTransition(
                opacity: _insightsAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: BuildSectionCard(
                    title: 'Condition Insights',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInsightGroup('Causes', explanation.causes),
                        _buildInsightGroup('Triggers', explanation.triggers),
                        _buildInsightGroup('Prevention', explanation.preventions),
                        _buildInsightGroup('Remedies', explanation.suggestedRemedies),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Fixed Education Carousel section with proper text wrapping
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      education.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  EducationCarousel(
                    title: '',
                    items: mapSectionsToEducationItems(education.sections),
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            await ref.read(storageServiceProvider).saveDiagnosis(widget.diagnosis);
                            if (mounted) {
                              setState(() => _isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saved to history')),
                              );
                            }
                          },
                    icon: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.history),
                    label: const Text('Save for Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onFindClinics,
                    icon: const Icon(Icons.place),
                    label: const Text('Find Clinics'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'This assessment is not a substitute for medical advice. Please consult a doctor.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMutedColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: ref.watch(currentTabProvider),
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
          switch (index) {
            case 0:
              ref.read(currentScreenProvider.notifier).state = AppScreen.home;
              break;
            case 1:
              ref.read(currentScreenProvider.notifier).state = AppScreen.symptomInput;
              break;
            case 2:
              ref.read(currentScreenProvider.notifier).state = AppScreen.map;
              break;
            case 3:
              ref.read(currentScreenProvider.notifier).state = AppScreen.history;
              break;
            case 4:
              ref.read(currentScreenProvider.notifier).state = AppScreen.profile;
              break;
          }
        },
      ),
    );
  }

  Widget _buildInsightGroup(String title, List<String> points) {
    if (points.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(point, softWrap: true),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}