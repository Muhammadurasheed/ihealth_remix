// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import '../config/theme.dart';
// import '../widgets/scan_animation.dart';
// import '../models/diagnosis_model.dart';
// import '../providers/diagnosis_provider.dart';

// class SymptomImageScanScreen extends ConsumerStatefulWidget {
//   final Function(DiagnosisModel) onComplete;

//   const SymptomImageScanScreen({
//     Key? key,
//     required this.onComplete,
//   }) : super(key: key);

//   @override
//   ConsumerState<SymptomImageScanScreen> createState() => _SymptomImageScanScreenState();
// }

// class _SymptomImageScanScreenState extends ConsumerState<SymptomImageScanScreen>
//     with SingleTickerProviderStateMixin {
//   File? _image;
//   String? _errorMessage;
//   late AnimationController _animationController;
//   late Animation<double> _fadeInAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeInAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     );
//     _animationController.forward();

//     /// ✅ FIXED: Deferring provider mutation to avoid build-time mutation error
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(diagnosisProvider.notifier).reset();
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: source,
//       imageQuality: 80,
//       maxWidth: 1200,
//     );

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _errorMessage = null;
//       });
//     }
//   }

//   void _analyzeImage() {
//     if (_image == null) return;

//     setState(() {
//       _errorMessage = null;
//     });

//     ref.read(diagnosisProvider.notifier).diagnosisFromImage(_image!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final diagnosisState = ref.watch(diagnosisProvider);

//     if (diagnosisState.status == DiagnosisStatus.success &&
//         diagnosisState.diagnosis != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         widget.onComplete(diagnosisState.diagnosis!);
//       });
//     }

//     final bool isAnalyzing = diagnosisState.status == DiagnosisStatus.loading;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Skin Symptom Analysis'),
//         centerTitle: true,
//       ),
//       body: FadeTransition(
//         opacity: _fadeInAnimation,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 'Upload a clear image of the affected skin area',
//                 style: AppTheme.bodyTextMuted,
//               ),
//               const SizedBox(height: 24),

//               if (_errorMessage != null || diagnosisState.errorMessage != null)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.red.shade200),
//                   ),
//                   child: Text(
//                     diagnosisState.errorMessage ?? _errorMessage ?? '',
//                     style: TextStyle(color: Colors.red.shade800),
//                   ),
//                 ),

//               Expanded(
//                 child: _buildImagePreview(isAnalyzing),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
//                       icon: const Icon(Icons.photo_library),
//                       label: const Text('Choose from Gallery'),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         side: BorderSide(color: AppTheme.primaryColor),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: isAnalyzing ? null : () => _pickImage(ImageSource.camera),
//                       icon: const Icon(Icons.camera_alt),
//                       label: const Text('Take a Photo'),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         side: BorderSide(color: AppTheme.primaryColor),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: isAnalyzing || _image == null ? null : _analyzeImage,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: AppTheme.primaryColor,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                 ),
//                 child: isAnalyzing
//                     ? const SizedBox(
//                         height: 24,
//                         width: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Text(
//                         'Analyze Symptoms',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 24),
//               const Center(
//                 child: Text(
//                   'For best results, use good lighting and focus on the affected area only.',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppTheme.textMutedColor,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePreview(bool isAnalyzing) {
//     if (isAnalyzing) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const ScanAnimationWidget(
//             size: 180,
//             label: 'Analyzing Skin Condition...',
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Our AI is examining your image',
//             style: TextStyle(
//               color: AppTheme.primaryColor.withOpacity(0.8),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'This may take a moment',
//             style: AppTheme.bodyTextMuted,
//           ),
//         ],
//       );
//     }

//     if (_image != null) {
//       return Hero(
//         tag: 'skin-image',
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppTheme.borderColor),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.file(
//               _image!,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppTheme.borderColor,
//           style: BorderStyle.solid,
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.add_photo_alternate,
//               size: 64,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'No image selected',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Tap one of the buttons below to add an image',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
