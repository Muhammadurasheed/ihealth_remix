
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_validation_model.dart';
import '../providers/community_validation_provider.dart';
import '../config/theme.dart';

class CommunityValidationScreen extends ConsumerStatefulWidget {
  const CommunityValidationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunityValidationScreen> createState() => _CommunityValidationScreenState();
}

class _CommunityValidationScreenState extends ConsumerState<CommunityValidationScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validationState = ref.watch(communityValidationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Guardian Network'),
        subtitle: Text('Trust Score: ${validationState.userTrustScore.toStringAsFixed(1)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () => _showAchievements(context, validationState.achievements),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(validationState),
          Expanded(
            child: validationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildValidationsList(validationState.validations),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(CommunityValidationState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.health_and_safety,
            label: 'Trust Score',
            value: state.userTrustScore.toStringAsFixed(1),
            color: Colors.white,
          ),
          _buildStatItem(
            icon: Icons.people,
            label: 'Contributions',
            value: state.totalContributions.toString(),
            color: Colors.white,
          ),
          _buildStatItem(
            icon: Icons.star,
            label: 'Achievements',
            value: state.achievements.length.toString(),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildValidationsList(List<CommunityValidationModel> validations) {
    if (validations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No community validations available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit a diagnosis to start helping the community!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: validations.length,
      itemBuilder: (context, index) {
        final validation = validations[index];
        return _buildValidationCard(validation);
      },
    );
  }

  Widget _buildValidationCard(CommunityValidationModel validation) {
    final hasUserVoted = validation.communityVotes
        .any((vote) => vote.voterId == 'current_user_id');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusBadge(validation.status),
                const Spacer(),
                Text(
                  'Accuracy: ${validation.accuracyScore.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Case #${validation.validationId.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anonymous symptom pattern: ${validation.anonymizedSymptomsHash}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${validation.communityVotes.length} community votes',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (!hasUserVoted && validation.status == ValidationStatus.pending) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Help validate this diagnosis:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showVoteDialog(validation, true),
                      icon: const Icon(Icons.thumb_up, size: 18),
                      label: const Text('Accurate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showVoteDialog(validation, false),
                      icon: const Icon(Icons.thumb_down, size: 18),
                      label: const Text('Inaccurate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ValidationStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case ValidationStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case ValidationStatus.communityValidated:
        color = Colors.green;
        text = 'Community Validated';
        icon = Icons.verified;
        break;
      case ValidationStatus.doctorValidated:
        color = Colors.blue;
        text = 'Doctor Validated';
        icon = Icons.medical_services;
        break;
      case ValidationStatus.disputed:
        color = Colors.red;
        text = 'Disputed';
        icon = Icons.warning;
        break;
      case ValidationStatus.flagged:
        color = Colors.deepOrange;
        text = 'Flagged';
        icon = Icons.flag;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showVoteDialog(CommunityValidationModel validation, bool isAccurate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAccurate ? 'Vote: Accurate' : 'Vote: Inaccurate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you confident this diagnosis ${isAccurate ? 'is' : 'is not'} accurate based on the symptoms?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Additional feedback (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _submitVote(validation.validationId, isAccurate, _feedbackController.text);
              Navigator.pop(context);
            },
            child: const Text('Submit Vote'),
          ),
        ],
      ),
    );
  }

  void _submitVote(String validationId, bool isAccurate, String feedback) {
    ref.read(communityValidationProvider.notifier).voteOnValidation(
      validationId,
      isAccurate,
      feedback.isEmpty ? null : feedback,
    );
    _feedbackController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for helping validate this diagnosis!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAchievements(BuildContext context, List<String> achievements) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Achievements'),
        content: achievements.isEmpty
            ? const Text('No achievements yet. Keep contributing to earn badges!')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: achievements
                    .map((achievement) => ListTile(
                          leading: const Icon(Icons.star, color: Colors.amber),
                          title: Text(achievement),
                        ))
                    .toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
