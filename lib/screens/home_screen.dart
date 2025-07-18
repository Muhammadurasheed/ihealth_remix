
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/logo_widget.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onCheckSymptoms;
  final VoidCallback onViewHistory;

  const HomeScreen({
    super.key,
    required this.onCheckSymptoms,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LogoWidget(),
                  IconButton(
                    onPressed: onViewHistory,
                    icon: const Icon(
                      Icons.history,
                      color: AppTheme.textMutedColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'How can we help?',
                      style: AppTheme.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check your symptoms and find healthcare assistance',
                      style: AppTheme.bodyTextMuted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Check Symptoms Button
                    ElevatedButton.icon(
                      onPressed: onCheckSymptoms,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Check Symptoms'),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Health Tips Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.article_outlined,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Health Tips',
                                  style: AppTheme.headingSmall,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Stay hydrated during the hot season to prevent dehydration, especially if you have a fever.',
                                  style: AppTheme.bodyTextMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'This app is not a substitute for professional medical advice, diagnosis, or treatment.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMutedColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}