import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/helpers/speech_to_text_helper.dart';
import 'package:ihealth_naija_test_version/screens/skin_symptom_screen.dart';
import 'package:ihealth_naija_test_version/utils/pulse_animation.dart';
import 'package:ihealth_naija_test_version/controllers/symptom_input_controller.dart';
import 'package:ihealth_naija_test_version/main.dart';
import 'package:just_audio/just_audio.dart';
import '../config/theme.dart';

final isRecordingProvider = StateProvider<bool>((ref) => false);
final recordingTimeProvider = StateProvider<int>((ref) => 0);
final languageProvider = StateProvider<Language>((ref) => Language.english);
final symptomsTextProvider = StateProvider<String>((ref) => '');
final processingStateProvider = StateProvider<ProcessingState>(
  (ref) => ProcessingState.idle,
);
final processingMessageProvider = StateProvider<String>((ref) => '');
final recordedAudioProvider = StateProvider<String?>((ref) => null);
final detectedLanguageProvider = StateProvider<String?>((ref) => null);
final isPlayingAudioProvider = StateProvider<bool>((ref) => false);

enum Language { english, pidgin }

enum ProcessingState {
  idle,
  recording,
  transcribing,
  detectingLanguage,
  translating,
  processing,
  completed,
  error,
}

class SymptomInputScreen extends ConsumerStatefulWidget {
  final Function(String)? onSubmit;
  final AppScreen Function()? onOpenImageScan;

  const SymptomInputScreen({Key? key, this.onSubmit, this.onOpenImageScan})
    : super(key: key);

  @override
  ConsumerState<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends ConsumerState<SymptomInputScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final SpeechToTextHelper _speechHelper = SpeechToTextHelper();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  String? _recordedTranscription;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _speechHelper.initSpeech();
    _symptomsController.addListener(() {
      ref.read(symptomsTextProvider.notifier).state = _symptomsController.text;
    });
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _timer?.cancel();
    _speechHelper.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // Reset previous state
    _recordedTranscription = null;
    ref.read(detectedLanguageProvider.notifier).state = null;
    ref.read(recordedAudioProvider.notifier).state = null;

    // Update UI to recording state
    ref.read(processingStateProvider.notifier).state =
        ProcessingState.recording;
    ref.read(processingMessageProvider.notifier).state =
        'Listening to your voice...';
    ref.read(isRecordingProvider.notifier).state = true;
    ref.read(recordingTimeProvider.notifier).state = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = ref.read(recordingTimeProvider);
      ref.read(recordingTimeProvider.notifier).state = current + 1;
      if (current >= 40) {
        _stopRecording();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording started. Press stop when finished.'),
      ),
    );

    try {
      final language = ref.read(languageProvider);
      final locale = language == Language.english ? 'en_US' : 'en_NG';

      // Start speech recognition but don't await its completion
      _speechHelper
          .listenOnce(localeId: locale, timeout: const Duration(seconds: 40))
          .then((transcription) {
            // We only reach here if speech recognition completes on its own (timeout)
            // This should not happen when user presses stop button
            debugPrint(
              '[Screen] Speech recognition completed on its own: $transcription',
            );

            if (transcription.isNotEmpty) {
              _recordedTranscription = transcription;

              // Only process if still recording (user hasn't manually stopped)
              if (ref.read(isRecordingProvider)) {
                _stopRecording();
              }
            }
          })
          .catchError((e) {
            debugPrint('[Screen] Speech recognition error: $e');
            _handleRecordingError(e);
          });
    } catch (e) {
      _handleRecordingError(e);
    }
  }

  Future<void> _processRecording(String transcription) async {
    if (transcription.isEmpty) {
      _handleRecordingError('No speech detected');
      return;
    }

    try {
      // Stop the recording timer but continue processing
      _timer?.cancel();
      ref.read(isRecordingProvider.notifier).state = false;

      // Update UI to transcribing state
      ref.read(processingStateProvider.notifier).state =
          ProcessingState.transcribing;
      ref.read(processingMessageProvider.notifier).state =
          'Converting speech to text...';
      await Future.delayed(const Duration(seconds: 1));

      // Update UI to detecting language state
      ref.read(processingStateProvider.notifier).state =
          ProcessingState.detectingLanguage;
      ref.read(processingMessageProvider.notifier).state =
          'Detecting your spoken language...';
      await Future.delayed(const Duration(seconds: 1));

      // Submit to backend for processing and translation
      final diagnosisProvider = ref.read(symptomInputControllerProvider);
      final result = await diagnosisProvider.processVoiceTranscription(
        transcription,
        ref,
      );

      // Extract the detected language and translated text
      String detectedLanguage = result.spokenLanguage ?? 'Unknown';
      ref.read(detectedLanguageProvider.notifier).state = detectedLanguage;

      // Update UI to translating state
      ref.read(processingStateProvider.notifier).state =
          ProcessingState.translating;
      ref.read(processingMessageProvider.notifier).state =
          'Translating $detectedLanguage to English...';
      await Future.delayed(const Duration(seconds: 1));

      // Set the translated text in the text field
      if (result.translatedText != null) {
        _symptomsController.text = result.translatedText!;
      } else {
        _symptomsController.text =
            transcription; // Fallback to original transcription
      }

      // Update UI to completed state
      ref.read(processingStateProvider.notifier).state =
          ProcessingState.completed;
      ref.read(processingMessageProvider.notifier).state =
          'Voice input processed successfully!';

      // Reset state after some delay
      Future.delayed(const Duration(seconds: 3), () {
        if (ref.read(processingStateProvider) == ProcessingState.completed) {
          ref.read(processingStateProvider.notifier).state =
              ProcessingState.idle;
        }
      });
    } catch (e) {
      _handleRecordingError(e);
    }
  }

  void _handleRecordingError(dynamic error) {
    _timer?.cancel();
    ref.read(isRecordingProvider.notifier).state = false;
    ref.read(processingStateProvider.notifier).state = ProcessingState.error;
    ref.read(processingMessageProvider.notifier).state =
        'Error processing voice. Please try again.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voice processing error: ${error.toString()}')),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (ref.read(processingStateProvider) == ProcessingState.error) {
        ref.read(processingStateProvider.notifier).state = ProcessingState.idle;
      }
    });
  }

  void _stopRecording() {
    if (!ref.read(isRecordingProvider)) return; // Avoid double-stopping

    debugPrint('[Screen] Manual stop recording triggered');

    // Update UI first
    _timer?.cancel();
    ref.read(isRecordingProvider.notifier).state = false;

    // Get the current transcription before stopping
    final currentTranscription = _speechHelper.getLastRecognizedWords();
    debugPrint(
      '[Screen] Current transcription before stopping: $currentTranscription',
    );

    // Stop speech recognition
    _speechHelper.stopListening();

    // Save the transcription2
    if (currentTranscription.isNotEmpty) {
      _recordedTranscription = currentTranscription;

      // Save audio reference
      _speechHelper.saveAudioToFile(currentTranscription).then((audioPath) {
        if (audioPath != null) {
          ref.read(recordedAudioProvider.notifier).state = audioPath;
        }

        // Process the recording
        _processRecording(currentTranscription);
      });
    } else {
      _handleRecordingError('No speech detected');
    }
  }

  Future<void> _toggleAudioPlayback() async {
    final audioPath = ref.read(recordedAudioProvider);

    if (audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recorded audio available')),
      );
      return;
    }

    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });

    if (_isPlayingAudio) {
      try {
        await _speechHelper.playRecordedAudio();

        // Reset state when playback finishes
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
        }
      } catch (e) {
        setState(() {
          _isPlayingAudio = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    } else {
      await _speechHelper.stopAudio();
    }
  }

  Future<void> _handleSubmit() async {
    final text = _symptomsController.text.trim();
    if (text.isNotEmpty) {
      ref.read(processingStateProvider.notifier).state =
          ProcessingState.processing;
      ref.read(processingMessageProvider.notifier).state =
          'Processing your symptoms...';

      await ref
          .read(symptomInputControllerProvider)
          .handleTextSubmission(text, ref);
      ref.read(processingStateProvider.notifier).state = ProcessingState.idle;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your symptoms to continue.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getProcessingColor(ProcessingState state) {
    switch (state) {
      case ProcessingState.recording:
        return Colors.red;
      case ProcessingState.transcribing:
      case ProcessingState.detectingLanguage:
      case ProcessingState.translating:
      case ProcessingState.processing:
        return Colors.orange;
      case ProcessingState.completed:
        return Colors.green;
      case ProcessingState.error:
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildProcessingIndicator() {
    final state = ref.watch(processingStateProvider);
    final message = ref.watch(processingMessageProvider);

    if (state == ProcessingState.idle) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: _getProcessingColor(state).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getProcessingColor(state).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (state != ProcessingState.completed &&
              state != ProcessingState.error)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProcessingColor(state),
                ),
              ),
            )
          else
            Icon(
              state == ProcessingState.completed
                  ? Icons.check_circle
                  : Icons.error,
              color: _getProcessingColor(state),
              size: 16,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getProcessingColor(state),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayback() {
    final detectedLanguage = ref.watch(detectedLanguageProvider);
    final audioPath = ref.watch(recordedAudioProvider);

    if (detectedLanguage == null ||
        _recordedTranscription == null ||
        audioPath == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.language,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Detected language: $detectedLanguage',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlayingAudio ? Icons.stop : Icons.play_arrow,
                  color: AppTheme.primaryColor,
                ),
                onPressed: _toggleAudioPlayback,
                tooltip: _isPlayingAudio ? 'Stop audio' : 'Play recorded audio',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isPlayingAudio ? 'Stop playback' : 'Play recording',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(isRecordingProvider);
    final recordingTime = ref.watch(recordingTimeProvider);
    final language = ref.watch(languageProvider);
    final processingState = ref.watch(processingStateProvider);

    final bool isProcessing =
        processingState != ProcessingState.idle &&
        processingState != ProcessingState.completed &&
        processingState != ProcessingState.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us your symptoms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe how you feel in detail to get the most accurate help.',
              style: AppTheme.bodyTextMuted,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isProcessing
                            ? null
                            : () =>
                                ref.read(languageProvider.notifier).state =
                                    Language.english,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          language == Language.english
                              ? AppTheme.primaryColor
                              : Colors.white,
                      foregroundColor:
                          language == Language.english
                              ? Colors.white
                              : AppTheme.textColor,
                      side: BorderSide(
                        color:
                            language == Language.english
                                ? Colors.transparent
                                : AppTheme.primaryColor,
                      ),
                    ),
                    child: const Text('English'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isProcessing
                            ? null
                            : () =>
                                ref.read(languageProvider.notifier).state =
                                    Language.pidgin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          language == Language.pidgin
                              ? AppTheme.primaryColor
                              : Colors.white,
                      foregroundColor:
                          language == Language.pidgin
                              ? Colors.white
                              : AppTheme.textColor,
                      side: BorderSide(
                        color:
                            language == Language.pidgin
                                ? Colors.transparent
                                : AppTheme.primaryColor,
                      ),
                    ),
                    child: const Text('Pidgin'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProcessingIndicator(),
            _buildAudioPlayback(),
            const SizedBox(height: 16),
            TextField(
              controller: _symptomsController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    language == Language.english
                        ? 'Describe your symptoms here...'
                        : 'Tell us how your body dey...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
              ),
              enabled: !isProcessing,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isProcessing && !isRecording
                            ? null
                            : (isRecording ? _stopRecording : _startRecording),
                    icon: Icon(isRecording ? Icons.mic_off : Icons.mic),
                    label: Text(
                      isRecording
                          ? 'Stop Recording (${_formatTime(recordingTime)})'
                          : 'Record Voice',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isRecording ? Colors.red : AppTheme.primaryColor,
                      side: BorderSide(
                        color: isRecording ? Colors.red : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: isProcessing ? null : _handleSubmit,
                  backgroundColor:
                      isProcessing ? Colors.grey : AppTheme.primaryColor,
                  child:
                      isProcessing
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
            if (isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const PulseAnimation(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recording your voice...',
                      style: AppTheme.bodyTextMuted,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed:
                  isProcessing
                      ? null
                      : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SkinSymptomScreen(),
                          ),
                        );
                      },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Upload image of skin condition'),
              style: TextButton.styleFrom(
                foregroundColor:
                    isProcessing ? Colors.grey : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
