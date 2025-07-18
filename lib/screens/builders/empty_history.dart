import 'package:flutter/material.dart';
import 'package:ihealth_naija_test_version/config/theme.dart';

class EmptyHistory extends StatelessWidget {
  final bool hasSearchQuery;

  const EmptyHistory({
    Key? key,
    required this.hasSearchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: AppTheme.textMutedColor,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery ? 'No results match your search' : 'No history found',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Try a different search term'
                : 'Your health records will appear here',
            style: AppTheme.bodyTextMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
