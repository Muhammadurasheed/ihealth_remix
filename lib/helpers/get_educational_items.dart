import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/config/theme.dart';

import 'package:ihealth_naija_test_version/models/education_item.dart';
import 'package:ihealth_naija_test_version/models/education_point.dart';
 // Make sure to import the Condition model

List<EducationItem> getEducationItems(List conditions) {
    // This would ideally come from your API based on the diagnosis
    final condition = conditions.isNotEmpty
        ? conditions[0].name
        : 'General Health';
    
    if (condition.toLowerCase().contains('malaria')) {
      return [
        EducationItem(
          title: 'About Malaria',
          icon: Icons.coronavirus_outlined,
          color: AppTheme.primaryColor,
          points: [
            EducationPoint(
              emoji: '🦟',
              text: 'Transmitted by female Anopheles mosquitoes',
            ),
            EducationPoint(
              emoji: '🌡️',
              text: 'Symptoms include fever, chills, headache, and fatigue',
            ),
            EducationPoint(
              emoji: '⏰',
              text: 'Early treatment is crucial to prevent complications',
            ),
          ],
        ),
        EducationItem(
          title: 'Prevention Tips',
          icon: Icons.shield_outlined,
          color: Colors.green,
          points: [
            EducationPoint(
              emoji: '🛏️',
              text: 'Sleep under insecticide-treated mosquito nets',
            ),
            EducationPoint(
              emoji: '🧴',
              text: 'Use mosquito repellent on exposed skin',
            ),
            EducationPoint(
              emoji: '🚿',
              text: 'Eliminate standing water where mosquitoes breed',
            ),
          ],
        ),
        EducationItem(
          title: 'Treatment Options',
          icon: Icons.medication_outlined,
          color: Colors.blue,
          points: [
            EducationPoint(
              emoji: '💊',
              text: 'Artemisinin-based combination therapies (ACTs)',
            ),
            EducationPoint(
              emoji: '💧',
              text: 'Stay hydrated during treatment',
            ),
            EducationPoint(
              emoji: '🏥',
              text: 'Seek medical care for severe symptoms',
            ),
          ],
        ),
      ];
    } else if (condition.toLowerCase().contains('typhoid')) {
      return [
        EducationItem(
          title: 'About Typhoid',
          icon: Icons.coronavirus_outlined,
          color: AppTheme.primaryColor,
          points: [
            EducationPoint(
              emoji: '🦠',
              text: 'Caused by Salmonella Typhi bacteria',
            ),
            EducationPoint(
              emoji: '🥤',
              text: 'Spread through contaminated food and water',
            ),
            EducationPoint(
              emoji: '🌡️',
              text: 'Causes high fever, weakness, stomach pain',
            ),
          ],
        ),
        EducationItem(
          title: 'Prevention Tips',
          icon: Icons.shield_outlined,
          color: Colors.green,
          points: [
            EducationPoint(
              emoji: '💧',
              text: 'Drink only safe, treated water',
            ),
            EducationPoint(
              emoji: '🧼',
              text: 'Wash hands with soap before eating',
            ),
            EducationPoint(
              emoji: '🥗',
              text: 'Avoid raw vegetables and unpeeled fruits',
            ),
          ],
        ),
      ];
    } else {
      return [
        EducationItem(
          title: 'General Health Tips',
          icon: Icons.favorite_outline,
          color: AppTheme.primaryColor,
          points: [
            EducationPoint(
              emoji: '💧',
              text: 'Stay hydrated by drinking plenty of water daily',
            ),
            EducationPoint(
              emoji: '🥗',
              text: 'Eat a balanced diet with fruits and vegetables',
            ),
            EducationPoint(
              emoji: '😴',
              text: 'Get adequate sleep (7-8 hours) for recovery',
            ),
          ],
        ),
        EducationItem(
          title: 'When to See a Doctor',
          icon: Icons.medical_services_outlined,
          color: Colors.orange,
          points: [
            EducationPoint(
              emoji: '🌡️',
              text: 'Fever above 38.5°C for more than two days',
            ),
            EducationPoint(
              emoji: '😵',
              text: 'Severe headache with stiff neck',
            ),
            EducationPoint(
              emoji: '💨',
              text: 'Difficulty breathing or chest pain',
            ),
          ],
        ),
      ];
    }
  }