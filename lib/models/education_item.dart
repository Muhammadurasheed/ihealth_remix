import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/models/education_point.dart';

class EducationItem {
  final String title;
  final IconData icon;
  final Color color;
  final List<EducationPoint> points;
  
  EducationItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.points,
  });
}


