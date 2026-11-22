import 'package:educ_core/data/models/quiz.dart';
import 'package:educ_core/data/repositories/question_repository.dart';
import 'package:educ_core/data/repositories/topic_repository.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_student/screens/quiz/i_quiz_cubit.dart';

class AdvancedQuizCubit extends IQuizCubit {
  AdvancedQuizCubit(this.rootCollectionId, this.languageCode) {
    initialize();
    fetchQuiz();
  }

  final String rootCollectionId;
  final String languageCode;

  final _questionRepository = QuestionRepository();
  final _topicRepository = TopicRepository();

  @override
  Future<void> fetchQuiz() async {
    emit(QuizLoading());

    final result = await _questionRepository.getAdvancedQuestions(
      rootCollectionId,
      languageCode,
    );

    await result.fold(
      (data) async {
        quiz = Quiz.advanced(questions: data);
        emit(QuizLoaded());
      },
      (failure) => emit(QuizError(failure)),
    );
  }

  @override
  Future<void> finishQuiz() async {
    final quiz = this.quiz;
    if (quiz == null) return;

    emit(QuizFinished());
    quizTimer.stop();

    Logger.Yellow("Quiz ended.");
    Logger.data("Score", "$score / ${quiz.rewardScore}");
    Logger.data("Percentage", "${calculateResultPercentage()}%");
    Logger.data("Quiz Time", getTotalQuizDurationFormatted());

    final result = await _topicRepository.finishAdvancedQuiz(rootCollectionId);

    result.fold(
      (data) => Logger.Green("Advanced Quiz Finished"),
      (failure) => emit(QuizResultError(failure)),
    );
  }
}
