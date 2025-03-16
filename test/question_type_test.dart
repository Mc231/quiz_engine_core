import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';

void main() {
  group('QuestionType', () {
    test('TextQuestion should serialize and deserialize correctly', () {
      final textQuestion = TextQuestion("What is 2 + 2?");
      final jsonMap = textQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<TextQuestion>());
      expect((reconstructed as TextQuestion).text, "What is 2 + 2?");
    });

    test('ImageQuestion should serialize and deserialize correctly', () {
      final imageQuestion = ImageQuestion("assets/images/question.png");
      final jsonMap = imageQuestion.toJson();
      final jsonString = jsonEncode(jsonMap);
      final parsedJson = jsonDecode(jsonString);

      final reconstructed = QuestionType.fromJson(parsedJson);

      expect(reconstructed, isA<ImageQuestion>());
      expect((reconstructed as ImageQuestion).imagePath, "assets/images/question.png");
    });

    test('Invalid QuestionType should throw ArgumentError', () {
      final invalidJson = jsonDecode('{"type": "unknown", "value": "random"}');

      expect(() => QuestionType.fromJson(invalidJson), throwsArgumentError);
    });

    test('toJson should correctly output a JSON representation for TextQuestion', () {
      final textQuestion = TextQuestion("Example Question");
      final expectedJson = {'type': 'text', 'text': "Example Question"};

      expect(textQuestion.toJson(), expectedJson);
    });

    test('toJson should correctly output a JSON representation for ImageQuestion', () {
      final imageQuestion = ImageQuestion("assets/example.png");
      final expectedJson = {'type': 'image', 'imagePath': "assets/example.png"};

      expect(imageQuestion.toJson(), expectedJson);
    });

    test('asJson should return correct JSON string for TextQuestion', () {
      final textQuestion = TextQuestion("What is 2 + 2?");
      final expectedJson = '{"type":"text","text":"What is 2 + 2?"}';

      expect(textQuestion.asJson, expectedJson);
    });

    test('asJson should return correct JSON string for ImageQuestion', () {
      final imageQuestion = ImageQuestion("assets/images/sample.png");
      final expectedJson = '{"type":"image","imagePath":"assets/images/sample.png"}';

      expect(imageQuestion.asJson, expectedJson);
    });
  });
}