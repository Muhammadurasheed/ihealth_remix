import 'package:flutter/material.dart';

class ViralMomentCard extends StatefulWidget {
  final Map<String, dynamic> viralMoment;
  final Function(Map<String, dynamic>) onShare;
  final VoidCallback onExplore;

  const ViralMomentCard({
    Key? key,
    required this.viralMoment,
    required this.onShare,
    required this.onExplore,
  }) : super(key: key);

  @override
  State<ViralMomentCard> createState() => _ViralMomentCardState();
}

class _ViralMomentCardState extends State<ViralMomentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
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
    final momentType = widget.viralMoment['viral_moment_type'] ?? '';
    final sharingOpportunities = widget.viralMoment['sharing_opportunities'] as List<dynamic>? ?? [];
    final networkGrowth = widget.viralMoment['network_growth_potential'] ?? {};

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(_glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
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
                _buildHeader(momentType),
                const SizedBox(height: 16),
                _buildMetrics(networkGrowth),
                const SizedBox(height: 16),
                _buildSharingSection(sharingOpportunities),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String momentType) {
    String title = 'Health Guardian Network';
    String subtitle = 'Your community impact is growing!';
    IconData icon = Icons.network_check;

    switch (momentType) {
      case 'community_guardian_network':
        title = 'Guardian Network Active';
        subtitle = 'Your health community is thriving';
        icon = Icons.shield;
        break;
      case 'accuracy_revelation':
        title = 'AI Accuracy Moment';
        subtitle = 'Incredible health insights achieved';
        icon = Icons.psychology;
        break;
      case 'health_hero_transformation':
        title = 'Health Hero Milestone';
        subtitle = 'Your transformation inspires others';
        icon = Icons.star;
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: const Text(
            'VIRAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetrics(Map<String, dynamic> networkGrowth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            'Growth Rate',
            networkGrowth['growth_rate'] ?? 'High',
            Icons.trending_up,
          ),
          _buildMetricItem(
            'Viral Score',
            '${((networkGrowth['viral_coefficient'] ?? 1.8) * 10).round()}/10',
            Icons.rocket_launch,
          ),
          _buildMetricItem(
            'Reach',
            networkGrowth['untapped_population'] ?? '2.3M',
            Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSection(List<dynamic> sharingOpportunities) {
    if (sharingOpportunities.isEmpty) return const SizedBox.shrink();

    final opportunity = sharingOpportunities.first as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.share,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Viral Sharing Opportunity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            opportunity['title'] ?? 'Share your health journey',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            opportunity['content'] ?? 'Join the health revolution',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => widget.onShare(widget.viralMoment),
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667eea),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onExplore,
            icon: const Icon(Icons.explore, size: 18),
            label: const Text('Explore'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}