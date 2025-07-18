import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/models/onboarding_step.dart';
import '../config/theme.dart';
import '../widgets/logo_widget.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      icon: Icons.mic,
      title: 'Share Your Symptoms',
      description: 'Tell us how you\'re feeling in your own words. You can type or speak in English or Pidgin.',
    ),
    OnboardingStep(
      icon: Icons.description,
      title: 'Get Smart Advice',
      description: 'Our AI helps identify possible conditions based on your symptoms and provides guidance.',
    ),
    OnboardingStep(
      icon: Icons.map,
      title: 'Find Nearby Help',
      description: 'Easily locate and get directions to health centers near you when needed.',
    ),
  ];

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const LogoWidget(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildStepContent(_steps[index]);
                },
              ),
            ),
            _buildStepIndicators(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _handleNext,
                    child: Text(
                      _currentStep < _steps.length - 1 ? 'Next' : 'Get Started',
                      style: AppTheme.buttonText,
                    ),
                  ),
                  if (_currentStep < _steps.length - 1)
                    TextButton(
                      onPressed: widget.onComplete,
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              step.icon,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            step.title,
            style: AppTheme.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            step.description,
            style: AppTheme.bodyTextMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (index) => Container(
          width: index == _currentStep ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == _currentStep
                ? AppTheme.primaryColor
                : AppTheme.textMutedColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
