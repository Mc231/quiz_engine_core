import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/random_item_picker.dart';

void main() {
  late RandomItemPicker<int> sut;

  setUp(() {
    sut = RandomItemPicker([]);
  });

  group('RandomItemPicker Tests', () {
    test('replace items', () {
      // Given
      final expectedItems = Iterable<int>.generate(10).toList();
      expect(sut.items, isEmpty);

      // When
      sut.replaceItems(expectedItems);

      // Then
      expect(sut.items, equals(expectedItems));
      expect(sut.items.length, equals(10));
    });

    test('empty items', () {
      // Given
      expect(sut.items, isEmpty);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNull);
    });

    test('pick when count == items.length', () {
      // Given
      final expectedItems = Iterable<int>.generate(4).toList();
      expect(sut.items, isEmpty);

      // When
      sut.replaceItems(expectedItems);
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(result!.options.length, equals(4)); // Should pick all items as options
      expect(result.options.contains(result.answer), isTrue);
    });

    test('pick when items < count', () {
      // Given
      final expectedItems = [1, 2]; // Only 2 items but count is 4 by default
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(result!.options.length, equals(2)); // Only available items can be options
    });

    test('pick random item', () {
      // Given
      final expectedItems = Iterable<int>.generate(10).toList();
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(result!.options.length, lessThanOrEqualTo(4)); // Max options should be count (4)
      expect(result.options.contains(result.answer), isTrue);
    });

    test('ensure picked items are added to answered list', () {
      // Given
      final expectedItems = [1, 2, 3, 4, 5];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(sut.items.contains(result!.answer), isFalse);
    });

    test('pick all items until empty', () {
      // Given
      final expectedItems = Iterable<int>.generate(4).toList();
      sut.replaceItems(expectedItems);

      // When
      for (var i = 0; i < expectedItems.length; i++) {
        final result = sut.pick();
        expect(result, isNotNull);
      }

      // Then
      final lastResult = sut.pick();
      expect(lastResult, isNull); // Should return null after all items are picked
    });

    test('pick when count > available items and answered items exist', () {
      // Given
      sut.replaceItems([1, 2]);
      sut.pick(); // Pick first item
      sut.pick(); // Pick second item

      // When
      final result = sut.pick(); // Should use answered items

      // Then
      expect(result, isNull);
    });

    test('ensure options list contains only unique values', () {
      // Given
      final expectedItems = [1, 2, 3, 4, 5];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(result!.options.length, result.options.toSet().length);
    });

    test('ensure answer is always part of options', () {
      // Given
      final expectedItems = [1, 2, 3, 4, 5];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(result!.options.contains(result.answer), isTrue);
    });

    test('pick shuffles options', () {
      // Given
      final expectedItems = [1, 2, 3, 4, 5];
      sut.replaceItems(expectedItems);

      // When
      final result1 = sut.pick();
      final result2 = sut.pick();

      // Then
      expect(result1, isNotNull);
      expect(result2, isNotNull);
      expect(result1!.options, isNot(equals(result2!.options))); // Expect shuffle
    });
  });
}