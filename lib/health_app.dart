import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/main.dart';
import 'package:ihealth_naija_test_version/models/condition_education_model.dart';
import 'package:ihealth_naija_test_version/models/condition_explanation_model.dart';
import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';
import 'package:ihealth_naija_test_version/providers/auth_provider.dart';
import 'package:ihealth_naija_test_version/screens/analyzing_symptoms_screen.dart';
import 'package:ihealth_naija_test_version/screens/diagnosis_results_screen.dart';
import 'package:ihealth_naija_test_version/screens/health_map_screen.dart';
import 'package:ihealth_naija_test_version/screens/history_screen.dart';
import 'package:ihealth_naija_test_version/screens/home_screen.dart';
import 'package:ihealth_naija_test_version/screens/login_screen.dart';
import 'package:ihealth_naija_test_version/screens/onboarding_screen.dart';
import 'package:ihealth_naija_test_version/screens/profile_screen.dart';
import 'package:ihealth_naija_test_version/screens/register_screen.dart';
import 'package:ihealth_naija_test_version/screens/splash_screen.dart';
import 'package:ihealth_naija_test_version/screens/symptom_input_screen.dart';
import 'package:ihealth_naija_test_version/services/auth_service.dart';
import 'package:ihealth_naija_test_version/widgets/bottom_navigation.dart';

class HealthApp extends ConsumerStatefulWidget {
  const HealthApp({Key? key}) : super(key: key);

  @override
  ConsumerState<HealthApp> createState() => _HealthAppState();
}

class _HealthAppState extends ConsumerState<HealthApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth service
    ref.read(authServiceProvider).initialize();
    
    // Set initial screen to splash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenProvider.notifier).state = AppScreen.splash;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = ref.watch(currentScreenProvider);
    final currentDiagnosis = ref.watch(currentDiagnosisProvider);
    final currentExplanation = ref.watch(currentExplanationProvider);
    final currentEducation = ref.watch(currentEducationProvider);
    final currentTab = ref.watch(currentTabProvider);
    final authState = ref.watch(authProvider);

    // Debug info
    debugPrint('Current screen: $currentScreen');
    debugPrint('Auth state: $authState');

    // Determine if the current screen should show the bottom navigation
    final bool showBottomNav = [
      AppScreen.home,
      AppScreen.symptomInput,
      AppScreen.history,
      AppScreen.profile,
      AppScreen.map,
    ].contains(currentScreen);

    return Scaffold(
      body: SafeArea(
        child: _buildScreen(
          currentScreen,
          ref,
          currentDiagnosis,
          currentExplanation,
          currentEducation,
          authState,
        ),
      ),
      bottomNavigationBar:
          showBottomNav
              ? BottomNavigation(
                currentIndex: currentTab,
                onTap: (index) {
                  // Set the tab index
                  ref.read(currentTabProvider.notifier).state = index;

                  // Change the screen based on tab index
                  switch (index) {
                    case 0:
                      ref.read(currentScreenProvider.notifier).state =
                          AppScreen.home;
                      break;
                    case 1:
                      ref.read(currentScreenProvider.notifier).state =
                          AppScreen.symptomInput;
                      break;
                    case 2:
                      ref.read(currentScreenProvider.notifier).state =
                          AppScreen.map;
                      break;
                    case 3:
                      ref.read(currentScreenProvider.notifier).state =
                          AppScreen.history;
                      break;
                    case 4:
                      ref.read(currentScreenProvider.notifier).state =
                          AppScreen.profile;
                      break;
                  }
                },
              )
              : null,
    );
  }

  Widget _buildScreen(
    AppScreen screen,
    WidgetRef ref,
    DiagnosisModel? diagnosis,
    ConditionExplanationModel? explanation,
    ConditionEducationModel? education,
    AuthState authState,
  ) {
    switch (screen) {
      case AppScreen.splash:
        return SplashScreen(
          onComplete: () async {
            // Navigate based on authentication state
            if (authState == AuthState.authenticated) {
              // User is authenticated, go to home
              ref.read(currentScreenProvider.notifier).state = AppScreen.home;
            } else if (authState == AuthState.error) {
              // Auth error, go to login
              ref.read(currentScreenProvider.notifier).state = AppScreen.login;
            } else {
              // Not authenticated, go to register first
              ref.read(currentScreenProvider.notifier).state = AppScreen.register;
            }
          },
        );
      case AppScreen.onboarding:
        return OnboardingScreen(
          onComplete: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.register,
        );
      case AppScreen.login:
        return LoginScreen(
          onRegister: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.register,
          onLoginSuccess: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.home,
        );
      case AppScreen.register:
        return RegisterScreen(
          onLogin: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.login,
          onRegisterSuccess: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.home,
        );
      case AppScreen.home:
        // If somehow we reached home but aren't authenticated, redirect to register
        if (authState != AuthState.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentScreenProvider.notifier).state = AppScreen.register;
          });
          return const Center(child: CircularProgressIndicator());
        }
        
        return HomeScreen(
          onCheckSymptoms: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.symptomInput,
          onViewHistory: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.history,
        );
      case AppScreen.symptomInput:
        // If somehow we reached here but aren't authenticated, redirect to register
        if (authState != AuthState.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentScreenProvider.notifier).state = AppScreen.register;
          });
          return const Center(child: CircularProgressIndicator());
        }
        
        return SymptomInputScreen(
          onSubmit: (_) => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.analyzing,
          onOpenImageScan: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.symptomImageScan,
        );

      case AppScreen.analyzing:
        return AnalyzingSymptomsScreen(
          onComplete: (diagnosis) {
            ref.read(currentDiagnosisProvider.notifier).state = 
                diagnosis as DiagnosisModel?;
            ref.read(currentScreenProvider.notifier).state = AppScreen.results;
          },
          symptoms: '',
        );
      case AppScreen.results:
        if (diagnosis == null) {
          return const Center(child: Text('No diagnosis data available.'));
        }
        if (explanation == null) {
          return const Center(child: Text('No explanation data available.'));
        }
        if (education == null) {
          return const Center(child: Text('No education data available.'));
        }
        return DiagnosisResultsScreen(
          diagnosis: diagnosis,
          onFindClinics: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.map,
          explanation: explanation,
          education: education,
        );
      case AppScreen.map:
        return HealthMapScreen(
          onBack: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.results,
        );
      case AppScreen.history:
        return HistoryScreen(
          onBack: () => 
            ref.read(currentScreenProvider.notifier).state = AppScreen.home,
          onViewDiagnosis: (diagnosis) {
            ref.read(currentDiagnosisProvider.notifier).state = 
                diagnosis as DiagnosisModel?;
            ref.read(currentScreenProvider.notifier).state = AppScreen.results;
          },
        );
      case AppScreen.profile:
        return ProfileScreen();
      case AppScreen.symptomImageScan:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}