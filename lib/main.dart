import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ihealth_naija_test_version/health_app.dart';
import 'package:ihealth_naija_test_version/models/condition_education_model.dart';
import 'package:ihealth_naija_test_version/models/condition_explanation_model.dart';
import 'config/theme.dart';
import 'models/diagnosis_model.dart';

// StateProvider to track the current screen - initialize to splash
final currentScreenProvider = StateProvider<AppScreen>((ref) => AppScreen.splash);

// StateProvider to store the current diagnosis and related data
final currentDiagnosisProvider = StateProvider<DiagnosisModel?>((ref) => null);
final currentExplanationProvider = StateProvider<ConditionExplanationModel?>((ref) => null);
final currentEducationProvider = StateProvider<ConditionEducationModel?>((ref) => null);

// StateProvider to track the current bottom navigation tab
final currentTabProvider = StateProvider<int>((ref) => 0);

enum AppScreen {
  splash,
  onboarding,
  login,
  register,
  home,
  symptomInput,
  analyzing,
  results,
  map,
  history,
  profile,
  symptomImageScan,
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: IHealthApp(),
    ),
  );
}

class IHealthApp extends ConsumerWidget {
  const IHealthApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'iHealth Naija',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HealthApp(),
    );
  }
}