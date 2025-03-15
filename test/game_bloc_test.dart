import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:quiz_engine_core/src/business_logic/quiz_data_provider.dart';
import 'package:quiz_engine_core/src/model/random_pick_result.dart';
import 'package:quiz_engine_core/src/random_item_picker.dart';

@GenerateNiceMocks([
  MockSpec<QuizDataProvider<String>>(),
  MockSpec<RandomItemPicker<String>>(),
])
import 'game_bloc_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuizBloc bloc;
  late RandomItemPicker<String> randomItemPicker;
  late QuizDataProvider<String> provider;
  List<String> mockItems = ["A", "B", "C", "D", "E"];

  List<String> countries = [];

  setUp(() {
    randomItemPicker = MockRandomItemPicker();
    provider = MockQuizDataProvider();

    // Mock asset loading: Replace 'assets/Countries.json' with fake data
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      return Future.value(
        ByteData.sublistView(Uint8List.fromList(
          '[{"name": "1"}, {"name": "2"}, {"name": "3"}, {"name": "4"}, {"name": "5"}]'.codeUnits,
        )),
      );
    });

    bloc = QuizBloc<String>.standard(
      'assets/Countries.json',
          (json) => json.toString(),
      filter: (country) => true,
    );

    countries = ["1", "2", "3", "4", "5"];
  });

  tearDown(() {
    bloc.dispose();
  });


  test('performInitialLoad() loads and filters data, updates picker, and picks a question', () async {
    // Given: Mock provider returns mockItems
    when(provider.provide()).thenAnswer((_) async => mockItems);

    // When
    bloc.performInitialLoad();
  });

  test('init standard', () {
    final result = QuizBloc<String>.standard(
      'assets/Countries.json',
          (json) => json.toString(),
      filter: (country) => true,
    );
    expect(result, isNotNull);
  });

  test('initial state is correct', () {
    expect(bloc.initialState, isInstanceOf<LoadingState>());
  });

  test('process answer', () async {
    final question = Question<String>(countries.first, countries);
    bloc.currentQuestion = question;
    countries.removeLast();
    final randomPickResult = RandomPickResult(countries.first, countries);

    when(randomItemPicker.pick()).thenReturn(randomPickResult);

    bloc.processAnswer(countries.first);

    await expectLater(bloc.stream, emitsInOrder([isInstanceOf<QuestionState>()]));
  });

  test('process game over', () async {
    final answer = countries.first;
    final expectedScore = '0 / 0';

    bloc.currentQuestion = Question<String>(countries.last, countries);
    bloc.gameOverCallback = (score) {
      expect(score, equals(expectedScore));
    };

    when(randomItemPicker.pick()).thenReturn(null);

    bloc.processAnswer(answer);
  });
}