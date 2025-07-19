import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/revolutionary_health_controller.dart';
import '../widgets/animated_metric_card.dart';
import '../widgets/viral_moment_card.dart';
import '../widgets/trust_indicator_widget.dart';
import '../widgets/community_pulse_widget.dart';

class RevolutionaryDashboardScreen extends ConsumerStatefulWidget {
  const RevolutionaryDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RevolutionaryDashboardScreen> createState() => _RevolutionaryDashboardScreenState();
}

class _RevolutionaryDashboardScreenState extends ConsumerState<RevolutionaryDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? _viralMoment;
  Map<String, dynamic>? _communityPulse;
  Map<String, dynamic>? _trustData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
  }

  Future<void> _loadDashboardData() async {
    try {
      final controller = ref.read(revolutionaryHealthControllerProvider);
      
      // Load viral moment data
      final viralMomentFuture = controller.createCommunityGuardianMoment(
        userId: 'current_user_id', // Replace with actual user ID
        location: 'Lagos, Nigeria', // Replace with actual location
        recentSymptoms: ['fever', 'cough'], // Replace with actual symptoms
      );

      // Load trust data (simulated)
      final trustDataFuture = _loadTrustData();

      final results = await Future.wait([
        viralMomentFuture,
        trustDataFuture,
      ]);

      setState(() {
        _viralMoment = results[0];
        _communityPulse = _viralMoment?['community_pulse'];
        _trustData = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Error loading dashboard data: $e');
    }
  }

  Future<Map<String, dynamic>> _loadTrustData() async {
    // Simulate loading trust verification data
    await Future.delayed(const Duration(seconds: 1));
    return {
      'trust_score': 0.92,
      'medical_validation_rate': 0.89,
      'community_accuracy': 0.94,
      'transparency_score': 1.0,
      'user_trust_level': 'Verified Health Guardian',
    };
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: _buildGradientBackground(),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Loading Your Health Guardian Dashboard...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildViralMomentCard(),
                  const SizedBox(height: 20),
                  _buildMetricsGrid(),
                  const SizedBox(height: 20),
                  _buildCommunityPulseWidget(),
                  const SizedBox(height: 20),
                  _buildTrustIndicatorWidget(),
                  const SizedBox(height: 20),
                  _buildActionCards(),
                  const SizedBox(height: 20),
                  _buildReferralBoostCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFF6B73FF),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildHeader() {
    final guardianScore = _viralMoment?['personal_guardian_score'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shield,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Guardian Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level: ${guardianScore['level'] ?? 'Health Guardian'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '${guardianScore['current_score'] ?? 750} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViralMomentCard() {
    if (_viralMoment == null) return const SizedBox.shrink();

    return ViralMomentCard(
      viralMoment: _viralMoment!,
      onShare: _handleViralShare,
      onExplore: _handleExploreViralMoment,
    );
  }

  Widget _buildMetricsGrid() {
    final impactMetrics = _viralMoment?['impact_metrics'] ?? {};
    final guardianScore = _viralMoment?['personal_guardian_score'] ?? {};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        AnimatedMetricCard(
          title: 'People Helped',
          value: '${impactMetrics['people_helped'] ?? 0}',
          icon: Icons.people,
          color: Colors.blue,
          animationDelay: 0,
        ),
        AnimatedMetricCard(
          title: 'Accuracy Rate',
          value: '${((impactMetrics['accuracy_rate'] ?? 0.0) * 100).round()}%',
          icon: Icons.verified,
          color: Colors.green,
          animationDelay: 200,
        ),
        AnimatedMetricCard(
          title: 'Community Trust',
          value: '${((impactMetrics['community_trust_score'] ?? 0.0) * 100).round()}%',
          icon: Icons.favorite,
          color: Colors.red,
          animationDelay: 400,
        ),
        AnimatedMetricCard(
          title: 'Contributions',
          value: '${guardianScore['monthly_contribution'] ?? 0}',
          icon: Icons.star,
          color: Colors.orange,
          animationDelay: 600,
        ),
      ],
    );
  }

  Widget _buildCommunityPulseWidget() {
    if (_communityPulse == null) return const SizedBox.shrink();

    return CommunityPulseWidget(
      communityPulse: _communityPulse!,
      onViewDetails: _handleViewCommunityDetails,
    );
  }

  Widget _buildTrustIndicatorWidget() {
    if (_trustData == null) return const SizedBox.shrink();

    return TrustIndicatorWidget(
      trustData: _trustData!,
      onViewTransparencyReport: _handleViewTransparencyReport,
    );
  }

  Widget _buildActionCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'New Diagnosis',
                subtitle: 'Get AI health insights',
                icon: Icons.medical_services,
                onTap: _handleNewDiagnosis,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Validate Community',
                subtitle: 'Help others',
                icon: Icons.fact_check,
                onTap: _handleValidateCommunity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralBoostCard() {
    final referralIncentive = _viralMoment?['referral_incentive'] ?? {};
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Referral Super Boost',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            referralIncentive['reward_description'] ?? 'Unlock premium features for every friend you refer',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleReferFriends,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF8C00),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Refer Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  referralIncentive['referral_code'] ?? 'HEALTH123',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _handleViralShare(Map<String, dynamic> sharingData) {
    // Implement viral sharing functionality
    print('Sharing viral moment: $sharingData');
  }

  void _handleExploreViralMoment() {
    // Navigate to detailed viral moment exploration
    print('Exploring viral moment');
  }

  void _handleViewCommunityDetails() {
    // Navigate to community details screen
    print('Viewing community details');
  }

  void _handleViewTransparencyReport() {
    // Navigate to transparency report
    print('Viewing transparency report');
  }

  void _handleNewDiagnosis() {
    // Navigate to new diagnosis screen
    Navigator.pushNamed(context, '/symptom-input');
  }

  void _handleValidateCommunity() {
    // Navigate to community validation screen
    Navigator.pushNamed(context, '/community-validation');
  }

  void _handleReferFriends() {
    // Open referral sharing interface
    print('Opening referral interface');
  }
}