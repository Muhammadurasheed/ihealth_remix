import 'package:flutter/material.dart';

class CommunityPulseWidget extends StatefulWidget {
  final Map<String, dynamic> communityPulse;
  final VoidCallback onViewDetails;

  const CommunityPulseWidget({
    Key? key,
    required this.communityPulse,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  State<CommunityPulseWidget> createState() => _CommunityPulseWidgetState();
}

class _CommunityPulseWidgetState extends State<CommunityPulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildPulseMetrics(),
          const SizedBox(height: 16),
          _buildTrendingSymptoms(),
          const SizedBox(height: 16),
          _buildHealthAlerts(),
          const SizedBox(height: 16),
          _buildViewDetailsButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final healthScore = widget.communityPulse['community_health_score'] ?? 0.84;
    
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getHealthScoreColor(healthScore).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Community Health Pulse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Real-time health insights',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getHealthScoreColor(healthScore).withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _getHealthScoreColor(healthScore).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            '${(healthScore * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPulseMetrics() {
    final activeGuardians = widget.communityPulse['active_guardians'] ?? 1247;
    final validationsToday = widget.communityPulse['validations_today'] ?? 89;
    final healthAlerts = widget.communityPulse['health_alerts'] ?? 2;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Active Guardians',
            '$activeGuardians',
            Icons.shield,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Validations Today',
            '$validationsToday',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Health Alerts',
            '$healthAlerts',
            Icons.warning,
            healthAlerts > 0 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSymptoms() {
    final trendingSymptoms = widget.communityPulse['trending_symptoms'] as List<dynamic>? ?? [];
    
    if (trendingSymptoms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'Trending Symptoms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trendingSymptoms.take(3).map((symptom) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                symptom.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthAlerts() {
    final outbreakRisk = widget.communityPulse['outbreak_risk'] ?? 'low';
    final preventionTips = widget.communityPulse['prevention_tips'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.health_and_safety,
              color: _getRiskColor(outbreakRisk),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Health Status: ${outbreakRisk.toUpperCase()}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (preventionTips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            preventionTips.first.toString(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildViewDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onViewDetails,
        icon: const Icon(Icons.analytics, size: 18),
        label: const Text('View Detailed Analytics'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 0.8) return const Color(0xFF4CAF50);
    if (score >= 0.6) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return const Color(0xFF4CAF50);
      case 'moderate':
        return const Color(0xFFFF9800);
      case 'high':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }
}