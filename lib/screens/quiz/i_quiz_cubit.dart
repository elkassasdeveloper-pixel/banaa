import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:educ_core/data/models/question/question.dart';
import 'package:educ_core/data/models/question/user_answer.dart';
import 'package:educ_core/data/models/quiz.dart';
import 'package:educ_core/data/repositories/question_repository.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/quiz/advanced_quiz_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class IQuizCubit extends Cubit<QuizState> {
  IQuizCubit({this.quiz}) : _quizId = quiz?.id ?? "", super(QuizInitial()) {
    initialize();
  }

  IQuizCubit.fromId(this._quizId) : super(QuizInitial()) {
    initialize();
    fetchQuiz();
  }

  final hasPermissionsToSeeCorrect = CacheHelper.getPermissionsToSeeCorrect() ?? false;

  Quiz? quiz;

  bool get isAdvanced => this is AdvancedQuizCubit;

  Future<void> fetchQuiz();

  Future<void> finishQuiz();

  void reloadQuiz() {
    emit(QuizInitial());

    currentPageIndex = 0;
    progress = 0;
    timeLeft = Duration.zero;
    score = 0;
    quizTimer.stop();
    quizTimer.reset();
    currentAnswerResult = AnswerResult.none;

    initialize();
    fetchQuiz();

    // quiz?.questions.forEach(
    //   (element) {
    //     element.userAnswer = null;
    //   },
    // );
  }

  final String _quizId;

  static const defaultQuizDuration = Duration(seconds: 30);

  int currentPageIndex = 0;
  double progress = 0;
  Duration timeLeft = Duration.zero;
  int score = 0;
  AnswerResult currentAnswerResult = AnswerResult.none;

  final _questionRepository = QuestionRepository();

  PageController pageController = PageController();
  Stopwatch quizTimer = Stopwatch();
  Timer questionTimer = Timer(Duration.zero, () {});

  String get topicId => quiz?.topicId ?? _quizId;

  List<IQuestion> get questions => quiz?.questions ?? [];

  bool get isLastPage => currentPageIndex == questions.length - 1;

  bool get isCurrentQuestionAnswered {
    try {
      return questions[currentPageIndex].userAnswer != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> initialize() async {
    try {
      pageController.dispose();
    } catch (_) {}
    pageController = PageController(
      onAttach: (position) {
        doPostFrame((_) {
          resetTimer();
          quizTimer.start();
          initializeAllQuestions();
        });
      },
    );
  }

  int get questionScore {
    if (quiz == null) return 0;
    return quiz!.rewardScore ~/ questions.length;
  }

  double calculateResultPercentage() {
    if (quiz == null) return 0;
    return score / (quiz?.rewardScore ?? 1) * 100;
  }

  Future<void> fetchQuestions() async {
    final quiz = this.quiz;
    if (quiz == null) return;

    emit(QuizQuestionsLoading());

    final questions = await _questionRepository.getQuestionsByQuizId(quizId: quiz.id);

    await questions.fold((data) {
      quiz.questions = data;
      quiz.questions.shuffle();
      doPostFrame((_) => resetTimer);
      emit(QuizQuestionsLoaded());
    }, (failure) => emit(QuizQuestionsError(failure)));
  }

  String getTimeLeftFormatted() {
    final minutes = timeLeft.inMinutes;
    final secondsLeft = timeLeft.inSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${secondsLeft.toString().padLeft(2, '0')}";
  }

  void resetTimer() {
    timeLeft = defaultQuizDuration;
    currentAnswerResult = AnswerResult.none;

    emit(QuizUpdated());

    questionTimer.cancel();
    const oneSec = Duration(seconds: 1);
    questionTimer = Timer.periodic(oneSec, (timer) {
      if (timer.tick >= defaultQuizDuration.inSeconds) {
        onTimeOut();
        timer.cancel();
        return;
      }
      timeLeft -= const Duration(seconds: 1);
      emit(QuizQuestionCountdownUpdated());
    });
  }

  void onTimeOut() {
    emit(QuizAnswerConfirmed());
    final result = verifyCurrentAnswer();
    if (result == null) {
      currentAnswerResult = AnswerResult.timeOut;
      emit(QuizAnswerConfirmed());
    }
  }

  // bool checkMcqAnswer(int questionIndex, int answerIndex) {
  //   final question = questions[questionIndex];
  //
  //   if (question is MultipleChoiceQuestion) {
  //     return question.answers[answerIndex].isCorrect;
  //   } else {
  //     return false;
  //   }
  // }

  @override
  Future<void> close() {
    questionTimer.cancel();
    return super.close();
  }

  void onMcqAnswerSelected(MultipleChoiceQuestion question, McqQuestionAnswer answer) {
    final existingAnswer = question.userAnswer;
    if (existingAnswer != null) {
      existingAnswer.selectedAnswer = answer;
    } else {
      question.userAnswer = McqUserAnswer(
        // questionIndex: questionIndex,
        selectedAnswer: answer,
        correctAnswers: question.answers.where((element) => element.isCorrect).toList(),
      );
    }

    emit(QuizUpdated());
  }

  void onPageChanged(int value) {
    currentPageIndex = value;
    currentAnswerResult = AnswerResult.none;

    emit(QuizQuestionChanged());
  }

  void initializeAllQuestions() {
    for (final question in questions) {
      if (question is FillQuestion) {
        question.userAnswer ??= FillUserAnswer(
          wrongAnswers: question.falseAnswers,
          correctAnswers: question.correctAnswers,
        );
      } else if (question is MatchingQuestion) {
        question.userAnswer ??= MatchingUserAnswer(correctMatches: question.answers);
      }
    }

    emit(QuizQuestionChanged());
  }

  /// Check if current answer is correct
  /// - true: correct
  /// - false: wrong
  /// - null: error (timeout or no selection)
  final _audioPlayer = AudioPlayer();

  Future<void> playOneSecond() async {
    await _audioPlayer.play(AssetSource('sounds/right_answer.mp3'),position: Duration(seconds: 3));
    Future.delayed(const Duration(milliseconds: 2500), () {
      _audioPlayer.stop();
    });
  }
  Future<void> playCorrectAnswer() async {
    await _audioPlayer.play(
      AssetSource('sounds/correct.mp3'),
      // position: Duration(seconds: 3),
    );
    Future.delayed(const Duration(milliseconds: 3000), () {
      _audioPlayer.stop();
    });
  }

  Future<void> playWrongAnswer() async {
    await _audioPlayer.play(
      AssetSource('sounds/wrong.mp3'),
      // position: Duration(seconds: 3),
    );
    Future.delayed(const Duration(milliseconds: 3000), () {
      _audioPlayer.stop();
    });
  }

  bool? verifyCurrentAnswer() {
    try {
      questionTimer.cancel();
      final userAnswer = questions[currentPageIndex].userAnswer;
      bool? result = userAnswer?.verifyAnswer();

      if (result == null) {
        return null;
      } else if (result) {
        currentAnswerResult = AnswerResult.correct;
        log("+ $questionScore");
        score += questionScore;
        playCorrectAnswer();
      } else {
        currentAnswerResult = AnswerResult.wrong;
        if (hasPermissionsToSeeCorrect && questions[currentPageIndex] is MatchingQuestion) {
          final question = questions[currentPageIndex] as MatchingQuestion;
          final correctMatches = <int, int>{};

          for (int i = 0; i < question.answers.length; i++) {
            final a = question.answers[i].a;
            final b = question.answers[i].b;

            final aIndex = question.userAnswer?.aValues.indexOf(a);
            final bIndex = question.userAnswer?.bValues.indexOf(b);

            if (aIndex != null && bIndex != null && aIndex >= 0 && bIndex >= 0) {
              correctMatches[aIndex] = bIndex;
            }
          }

          question.userAnswer?.matches.addAll(correctMatches);
        }
        playWrongAnswer();
      }

      emit(QuizAnswerConfirmed());
      return result;
    } catch (e) {
      Logger.Red(e);
      return null;
    }
  }

  Future<void> goToNextQuestion(int score,IQuizCubit cubit,BuildContext context,Function(BuildContext context) showNoAttemptsDialog /*//ahmed-2025-01-06*/) async {
    final totalAttempts = context.read<AuthCubit>().accountAttempts;
    final quiz = this.quiz;
    if (quiz == null) return;
if(
!cubit.isAdvanced &&
totalAttempts == 0) {
  Logger.Red("accountAttempts: $totalAttempts");
  //her i want Show Dialog
  showNoAttemptsDialog(context);
  return;
}
    if (isLastPage) {
      if (!isAdvanced) {
        if (score > 70) {
          //ahmed-2025-01-06
          finishQuiz();
        } //ahmed-2025-01-06
        else {
          //ahmed-2025-01-06
          emit(QuizFinished());
        } //ahmed-2025-01-06
      } else {
        emit(QuizFinished());
      }
      return;
    }

    resetTimer();

    await pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    resetTimer();
    // initializeAllQuestions();
  }

  String getTotalQuizDurationFormatted() {
    final minutes = quizTimer.elapsed.inMinutes;
    final secondsLeft = quizTimer.elapsed.inSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${secondsLeft.toString().padLeft(2, '0')}";
  }

  void resetQuiz() {
    score = 0;
    currentPageIndex = 0;
    currentAnswerResult = AnswerResult.none;
    progress = 0.0;
    timeLeft = defaultQuizDuration;
    questionTimer.cancel();
    quizTimer.reset();

    for (var question in questions) {
      question.userAnswer = null;
    }

    emit(QuizUpdated());
  }

  void onFillAnswerAdded(FillQuestion question, int slotIndex, String answer) {
    final userAnswer = question.userAnswer;
    if (userAnswer == null) return;

    // 1. Check if the answer is being moved from another slot
    int? oldSlotIndex;
    userAnswer.filledWords.forEach((key, val) {
      if (val == answer && key != slotIndex) {
        oldSlotIndex = key;
      }
    });

    // 2. Check if the target slot already contains a word
    final previousInTarget = userAnswer.filledWords[slotIndex];

    if (oldSlotIndex != null) {
      // Remove word from the previous slot
      userAnswer.filledWords.remove(oldSlotIndex);

      if (previousInTarget != null && previousInTarget != answer) {
        // Swap: Move target's previous word to the old slot
        userAnswer.filledWords[oldSlotIndex!] = previousInTarget;
      }
    } else if (previousInTarget != null && previousInTarget != answer) {
      // Word came from options list: return target's previous word to options
      if (!userAnswer.shuffledAnswers.contains(previousInTarget)) {
        userAnswer.shuffledAnswers.add(previousInTarget);
      }
    }

    // 3. Assign the new answer to the target slot
    userAnswer.filledWords[slotIndex] = answer;

    // 4. Ensure the placed answer is removed from options list
    userAnswer.shuffledAnswers.remove(answer);

    emit(QuizUpdated());
  }

  void onFillAnswerRemoved(FillQuestion question, int slotIndex, String answer) {
    question.userAnswer?.filledWords.remove(slotIndex);

    if (question.userAnswer != null && !question.userAnswer!.shuffledAnswers.contains(answer)) {
      question.userAnswer?.shuffledAnswers.add(answer);
    }

    emit(QuizUpdated());
  }

  void onMatchingSelectedA(MatchingQuestion question, int aIndex) {
    question.userAnswer?.currentSelectedA = aIndex;

    emit(QuizUpdated());
  }

  void onMatchingSelectedB(MatchingQuestion question, int bIndex) {
    final currentA = question.userAnswer?.currentSelectedA;

    if (currentA == null) {
      return;
    }
    try {
      question.userAnswer?.matches.removeWhere((key, value) => value == bIndex);
    } catch (_) {}
    question.userAnswer?.matches.update(currentA, (_) => bIndex, ifAbsent: () => bIndex);
    question.userAnswer?.currentSelectedA = null;

    emit(QuizUpdated());
  }
}

enum AnswerResult { none, timeOut, correct, wrong }

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {}

class EmptyQuiz extends QuizState {}

class QuizError extends QuizState {
  final Failure failure;

  QuizError(this.failure);
}

class QuizResultError extends QuizState {
  final Failure failure;

  QuizResultError(this.failure);
}

class QuizFinished extends QuizState {}

class QuizUpdated extends QuizState {}

class QuizQuestionCountdownUpdated extends QuizState {}

class QuizQuestionChanged extends QuizState {}

class QuizAnswerConfirmed extends QuizState {}

// Quiz Questions

class QuizQuestionsLoading extends QuizState {}

class QuizQuestionsLoaded extends QuizState {}

class QuizQuestionsError extends QuizState {
  final Failure failure;

  QuizQuestionsError(this.failure);
}

// Quiz Next Topic

// class QuizNextTopicLoading extends QuizState {}
//
// class QuizNextTopicLoaded extends QuizState {}
//
// class QuizNextTopicError extends QuizState {
//   final String error;
//
//   QuizNextTopicError({required this.error});
// }
