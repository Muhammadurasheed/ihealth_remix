import 'package:flutter/material.dart';

class ConditionEducationModel {
  final String title;
  final List<EducationSection> sections;

  ConditionEducationModel({
    required this.title,
    required this.sections,
  });

  factory ConditionEducationModel.fromJson(Map<String, dynamic> json) {
    return ConditionEducationModel(
      title: json['title'] ?? '',
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((section) => EducationSection.fromJson(section))
          .toList(),
    );
  }
}

class EducationSection {
  final String heading;
  final List<KeyPoint> keyPoints;

  EducationSection({
    required this.heading,
    required this.keyPoints,
  });

  factory EducationSection.fromJson(Map<String, dynamic> json) {
  final rawPoints = json['key_points'] as List<dynamic>? ?? [];

  return EducationSection(
    heading: json['heading'] ?? '',
    keyPoints: rawPoints.map((point) {
      if (point is String && point.isNotEmpty) {
        final emoji = point.characters.first; // captures first grapheme
        final text = point.substring(emoji.length).trim();
        return KeyPoint(emoji: emoji, text: text);
      } else if (point is Map<String, dynamic>) {
        return KeyPoint.fromJson(point);
      } else {
        return KeyPoint(emoji: '📌', text: point.toString());
      }
    }).toList(),
  );
}

}

class KeyPoint {
  final String emoji;
  final String text;

  KeyPoint({
    required this.emoji,
    required this.text,
  });

  factory KeyPoint.fromJson(Map<String, dynamic> json) {
    return KeyPoint(
      emoji: json['emoji'] ?? '📌',
      text: json['text'] ?? '',
    );
  }
}
