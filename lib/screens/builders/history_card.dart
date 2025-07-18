import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/config/theme.dart';
import 'package:ihealth_naija_test_version/models/diagnosis_history_entry.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  final DiagnosisHistoryEntry entry;
  final VoidCallback onTap;

  const HistoryCard({
    Key? key,
    required this.entry,
    required this.onTap, required Future<void> Function() onDelete,
  }) : super(key: key);

  Color _getUrgencyColor(String urgency) {
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

  @override
  Widget build(BuildContext context) {
    final mainCondition = entry.diagnosis.conditions.isNotEmpty
        ? entry.diagnosis.conditions.first
        : null;

    final formattedDate =
        DateFormat('MMMM d, yyyy - h:mm a').format(entry.date);

    final isImageBased = entry.diagnosis.isFromImage == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for name and severity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isImageBased) ...[
                      const Icon(Icons.image, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      mainCondition?.name ?? 'Unknown Condition',
                      style: AppTheme.headingSmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(entry.diagnosis.severity),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.diagnosis.severity,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: entry.diagnosis.severity == 'mild'
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMutedColor,
              ),
            ),

            const Divider(height: 16),

            // Symptoms or default label
            Text(
              isImageBased
                  ? "Image-based skin diagnosis"
                  : entry.symptoms,
              style: AppTheme.bodyText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
