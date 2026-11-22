import 'package:educ_core/data/models/achievement.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';
class AchievementsCubit extends DataCubit<AchievementsState> {
  AchievementsCubit() : super(AchievementsInitial()) {
    fetch();
  }

  List<Achievement>? achievements;
  final _accountRepository = AccountRepository();

  @override
  Future<void> fetch() async {
    await fetchAchievements();
  }

  Future<void> fetchAchievements() async {
    emit(AchievementsLoading());
    final result = await _accountRepository.getAchievements();
    result.fold(
      (data) {
        achievements = data;
        emit(AchievementsLoaded());
      },
      (failure) => emit(AchievementsError(failure)),
    );
  }
}

@immutable
sealed class AchievementsState {}

final class AchievementsInitial extends AchievementsState {}

final class AchievementsLoading extends AchievementsState {}

final class AchievementsLoaded extends AchievementsState {}

final class AchievementsError extends AchievementsState {
  final Failure failure;

  AchievementsError(this.failure);
}
