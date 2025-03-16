import 'dart:convert';

/// Sealed class for representing different types of quiz questions.
sealed class QuestionType {
  /// Converts to JSON format.
  String get asJson;

  factory QuestionType.image(String imagePath) = ImageQuestion;

  factory QuestionType.text(String text) = TextQuestion;

  const QuestionType();

  /// Factory constructor for creating `QuestionType` from JSON.
  factory QuestionType.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'image':
        return ImageQuestion(json['imagePath']);
      case 'text':
        return TextQuestion(json['text']);
      default:
        throw ArgumentError('Invalid QuestionType: ${json['type']}');
    }
  }

  /// Converts `QuestionType` to a JSON-compatible map.
  Map<String, dynamic> toJson();
}

/// Represents an image-based question.
class ImageQuestion extends QuestionType {
  final String imagePath;

  ImageQuestion(this.imagePath);

  @override
  String get asJson => jsonEncode({'type': 'image', 'imagePath': imagePath});

  @override
  Map<String, dynamic> toJson() => {'type': 'image', 'imagePath': imagePath};
}

/// Represents a text-based question.
class TextQuestion extends QuestionType {
  final String text;

  TextQuestion(this.text);

  @override
  String get asJson => jsonEncode({'type': 'text', 'text': text});

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}
