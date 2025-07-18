import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/config/theme.dart';

class FacilityTypeBadge extends StatelessWidget {
  final String type;

  const FacilityTypeBadge({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    switch (type) {
      case 'Hospital':
        backgroundColor = AppTheme.severeColor.withOpacity(0.2);
        textColor = AppTheme.severeColor;
        break;
      case 'Clinic':
        backgroundColor = AppTheme.primaryColor.withOpacity(0.2);
        textColor = AppTheme.primaryColor;
        break;
      case 'Pharmacy':
        backgroundColor = AppTheme.accentColor.withOpacity(0.2);
        textColor = AppTheme.accentColor.withOpacity(0.8);
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
