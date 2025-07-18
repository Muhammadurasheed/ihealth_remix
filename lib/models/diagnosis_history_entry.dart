import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';

class DiagnosisHistoryEntry {
  final String id;
  final DateTime date;
  final String symptoms;
  final DiagnosisModel diagnosis;

  DiagnosisHistoryEntry({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.diagnosis,
  });
}