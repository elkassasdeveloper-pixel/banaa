import 'package:educ_core/data/models/quiz_result.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/data/repositories/quiz_repository.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_student/screens/quiz/i_quiz_cubit.dart';

class QuizCubit extends IQuizCubit {
  QuizCubit({super.quiz});

  QuizCubit.fromId(super.quizId) : super.fromId();

  final _accountRepository = AccountRepository();
  final _quizRepository = QuizRepository();

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

    final result = await _accountRepository.takeQuiz(
      result: QuizResult(
        quizId: quiz.id,
        timeTakenInSeconds: quizTimer.elapsed.inSeconds,
        result: score,
      ),
    );

    result.fold(
      (data) {
        Logger.Green("Quiz result created");
        // NotificationsProvider().showNotification(
        //     title: "تم إرسال الامتحان ✅",
        //     body: "الإشعارات بتشتغل بشكل سليم"
        // );
      },
      (failure) => emit(QuizResultError(failure)),
    );
  }

  @override
  Future<void> fetchQuiz() async {
    emit(QuizLoading());

    final result = await _quizRepository.getQuizByTopicId(topicId);

    await result.fold(
      (data) async {
        quiz = data;
        emit(QuizLoaded());
        await fetchQuestions();
        // doPostFrame((_) => );
      },
      (failure) {
        if(failure.failureCode == "404"){
          quiz = null;
          emit(EmptyQuiz());
        }else {
          emit(QuizError(failure));
        }},
    );
  }
}
