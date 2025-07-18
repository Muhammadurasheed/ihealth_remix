import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/models/diagnosis_history_entry.dart';
import 'package:ihealth_naija_test_version/screens/builders/empty_history.dart';
import 'package:ihealth_naija_test_version/screens/builders/history_card.dart';
import '../models/diagnosis_model.dart';
import '../services/storage_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final Function(DiagnosisModel) onViewDiagnosis;

  const HistoryScreen({
    Key? key,
    required this.onBack,
    required this.onViewDiagnosis,
  }) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  List<DiagnosisHistoryEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final storageService = ref.read(storageServiceProvider);
    final diagnoses = await storageService.getDiagnoses();

    final symptoms = [
      "I dey feel fever, body dey hot, and I just dey weak.",
      "I get headache and my nose dey run.",
    ];

    if (diagnoses.isNotEmpty) {
      setState(() {
        _entries = diagnoses.asMap().entries.map((entry) {
          final index = entry.key;
          final diagnosis = entry.value;

          return DiagnosisHistoryEntry(
            id: index.toString(),
            date: diagnosis.createdAt,
            symptoms: index < symptoms.length
                ? symptoms[index]
                : "Symptoms not recorded",
            diagnosis: diagnosis,
          );
        }).toList();

        _entries.sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEntry(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this diagnosis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = ref.read(storageServiceProvider);
      await storageService.deleteDiagnosis(index);
      _loadHistory();
    }
  }

  List<DiagnosisHistoryEntry> get filteredEntries {
    if (_searchQuery.isEmpty) {
      return _entries;
    }

    final query = _searchQuery.toLowerCase();
    return _entries.where((entry) {
      return entry.symptoms.toLowerCase().contains(query) ||
          entry.diagnosis.conditions.any(
            (c) => c.name.toLowerCase().contains(query),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search your history...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEntries.isEmpty
                      ? EmptyHistory(hasSearchQuery: _searchQuery.isNotEmpty)
                      : ListView.builder(
                          itemCount: filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = filteredEntries[index];
                            final originalIndex = _entries.indexOf(entry);
                            return HistoryCard(
                              entry: entry,
                              onTap: () => widget.onViewDiagnosis(entry.diagnosis),
                              onDelete: () => _deleteEntry(originalIndex),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
