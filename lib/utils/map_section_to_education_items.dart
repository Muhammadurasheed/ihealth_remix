import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/models/condition_education_model.dart';
import 'package:ihealth_naija_test_version/models/education_item.dart';
import 'package:ihealth_naija_test_version/models/education_point.dart';

List<EducationItem> mapSectionsToEducationItems(
  List<EducationSection> sections,
) {
  final List<Color> sectionColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];

  final List<IconData> sectionIcons = [
    Icons.health_and_safety,
    Icons.local_hospital,
    Icons.healing,
    Icons.info,
    Icons.school,
  ];

  return List.generate(sections.length, (index) {
    final section = sections[index];
    final icon = sectionIcons[index % sectionIcons.length];
    final color = sectionColors[index % sectionColors.length];

    return EducationItem(
      title: section.heading,
      icon: icon,
      color: color,
      points:
          section.keyPoints
              .map((kp) => EducationPoint(emoji: kp.emoji, text: kp.text))
              .toList(),
    );
  });
}
