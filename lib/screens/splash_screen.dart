import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/logo_widget.dart';
import '../services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAnimating = true;
  bool _initialCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.repeat(reverse: true);

    // Start auth check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Ensure minimum display time for splash
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Get the auth service and check authentication
    final authService = ref.read(authServiceProvider);
    await authService.checkInitialAuthState();

    // Set flag that initial check is complete
    if (mounted) {
      setState(() {
        _initialCheckComplete = true;
      });
    }
  }

  void _completeAnimation() {
    if (mounted) {
      setState(() {
        _isAnimating = false;
      });
      // Wait for fade-out animation
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes in the build method
    ref.listen<AuthState>(authProvider, (previous, current) {
      debugPrint('Auth state in splash listener: $current');
      if (current != AuthState.initial && current != AuthState.loading) {
        _completeAnimation();
      }
    });

    // If initial check is complete and auth state is already determined
    if (_initialCheckComplete) {
      final currentAuthState = ref.read(authProvider);
      if (currentAuthState != AuthState.initial && currentAuthState != AuthState.loading) {
        _completeAnimation();
      }
    }

    return AnimatedOpacity(
      opacity: _isAnimating ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoWidget(size: LogoSize.large),
              const SizedBox(height: 16),
              const Text(
                'Diagnose',
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.textMutedColor,
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withOpacity(
                            Interval(
                              index * 0.2,
                              0.6 + index * 0.2,
                              curve: Curves.easeInOut,
                            ).transform(_animationController.value),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}