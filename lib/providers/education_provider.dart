import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/education_controller.dart';
import '../models/condition_content.dart';

class EducationState {
  final bool isLoading;
  final String? errorMessage;
  final ConditionContent? content;
  final String? videoUrl;

  EducationState({
    this.isLoading = false,
    this.errorMessage,
    this.content,
    this.videoUrl,
  });

  EducationState copyWith({
    bool? isLoading,
    String? errorMessage,
    ConditionContent? content,
    String? videoUrl,
  }) {
    return EducationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}

class EducationNotifier extends StateNotifier<EducationState> {
  final EducationController _educationController;

  EducationNotifier(this._educationController) : super(EducationState());

  Future<void> getConditionContent(String condition) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final response = await _educationController.getConditionContent(
        condition: condition,
      );
      
      if (response.statusCode == 200) {
        final content = ConditionContent.fromJson(response.data);
        state = state.copyWith(content: content, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load content',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  Future<void> generateVideo({
    required String condition,
    required String prompt,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final response = await _educationController.generateVideo(
        condition: condition,
        prompt: prompt,
      );
      
      if (response.statusCode == 200) {
        final videoUrl = response.data['videoUrl'];
        state = state.copyWith(videoUrl: videoUrl, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to generate video',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void clearContent() {
    state = EducationState();
  }
}

final educationProvider = StateNotifierProvider<EducationNotifier, EducationState>((ref) {
  return EducationNotifier(ref.read(educationControllerProvider));
});
