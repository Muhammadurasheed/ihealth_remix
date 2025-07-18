class EducationPoint {
  final String emoji;
  final String text;
  
  EducationPoint({
    required this.emoji,
    required this.text,
  });
  factory EducationPoint.fromJson(Map<String, dynamic> json) {
    return EducationPoint(
      emoji: json['emoji'] ?? '',
      text: json['text'] ?? '',
      
    );
  }
}
