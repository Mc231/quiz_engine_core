import 'package:quiz_engine_core/src/business_logic/quiz_state/quiz_state.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';

import '../bloc/single_subscription_bloc.dart';
import '../model/answer.dart';
import '../model/question.dart';
import '../model/random_pick_result.dart';
import '../random_item_picker.dart';

/// A business logic component (BLoC) that manages the state of a quiz game.
///
/// The `QuizBloc` class no longer depends on a specific `QuizDataProvider`.
/// Instead, the user must provide a function that supplies quiz data.
class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  /// Function to fetch quiz data.
  ///
  /// This function should return a `Future<List<QuestionEntry>>`.
  final Future<List<QuestionEntry>> Function() dataProvider;

  /// The random item picker used to select random items for questions.
  final RandomItemPicker randomItemPicker;

  /// A filter function to apply when loading data (optional).
  final bool Function(QuestionEntry)? filter;

  /// Callback function to be invoked when the game is over.
  Function(String result)? gameOverCallback;

  /// The list of quiz data items available for the game.
  List<QuestionEntry> _items = [];

  /// The current progress indicating how many questions have been answered.
  int _currentProgress = 0;

  /// The total number of questions in the game.
  int _totalCount = 0;

  /// The current question being asked to the player.
  late Question currentQuestion;

  /// The list of answers provided by the player.
  final List<Answer> _answers = [];

  /// Creates a `QuizBloc` with a provided data fetch function.
  QuizBloc(this.dataProvider, this.randomItemPicker, {this.filter});

  /// The initial state of the game, set to loading.
  @override
  QuizState get initialState => QuizState.loading();

  /// Performs the initial data load when the screen is loaded.
  ///
  /// This method retrieves quiz data using the provided `dataProvider` function,
  /// applies the optional filter, and initializes the random picker.
  Future<void> performInitialLoad() async {
    var items = await dataProvider();

    // Apply filter if provided, otherwise keep all items
    _items = filter != null ? items.where(filter!).toList() : items;

    _totalCount = _items.length;
    randomItemPicker.replaceItems(_items);
    _pickQuestion();
  }

  /// Processes the player's answer to the current question.
  void processAnswer(QuestionEntry selectedItem) {
    var answer = Answer(selectedItem, currentQuestion);
    _answers.add(answer);
    _currentProgress++;
    _pickQuestion();
  }

  /// Picks the next question or ends the game if no more items are available.
  void _pickQuestion() {
    var randomResult = randomItemPicker.pick();
    if (_isGameOver(randomResult)) {
      var state = QuizState.question(currentQuestion, _currentProgress, _totalCount);
      dispatchState(state);
      _notifyGameOver();
    } else {
      var question = Question.fromRandomResult(randomResult!);
      currentQuestion = question;
      var state = QuizState.question(question, _currentProgress, _totalCount);
      dispatchState(state);
    }
  }

  /// Determines if the game is over based on the random picker result.
  bool _isGameOver(RandomPickResult? result) => result == null;

  /// Notifies the game-over state and invokes the callback with the final result.
  void _notifyGameOver() {
    var correctAnswers = _answers.where((answer) => answer.isCorrect).length;
    var result = '$correctAnswers / $_totalCount';
    gameOverCallback?.call(result);
  }
}