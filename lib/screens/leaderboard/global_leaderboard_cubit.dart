import 'package:educ_core/data/models/leaderboard_entry.dart';
import 'package:educ_core/data/models/league.dart';
import 'package:educ_core/data/repositories/leaderboard_repository.dart';
import 'package:educ_core/data/repositories/league_repository.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:material_ui/material_ui.dart';

class GlobalLeaderboardCubit extends DataCubit<GlobalLeaderboardState>
    with GlobalLeaderboardScrollManagerMixin {
  GlobalLeaderboardCubit() : super(GlobalLeaderboardInitial()) {
    initializeScrollControllers();
    fetch();
  }
 bool showAssistantBefore =false;
  List<League> leagues = [];
  List<LeaderboardEntry> entries = [];
  int selectedLeagueIndex = 0;

  final _leaderboardRepository = LeaderboardRepository();
  final _leagueRepository = LeagueRepository();

  String get currentLeagueName {
    try {
      return leagues[selectedLeagueIndex].name;
    } catch (e) {
      return "";
    }
  }

  @override
  Future<void> fetch() async {
    await fetchLeagues();
    if (leagues.isNotEmpty) {
      selectedLeagueIndex = leagues.lastIndexWhere(
        (league) => league.isLocked == true,
      );
      fetchCurrentLeaderboard();
    }
  }

  Future<void> fetchCurrentLeaderboard() async {
    if (leagues.isNotEmpty) {
      await fetchLeaderboard(leagues[selectedLeagueIndex].id);
    }
  }

  Future<void> fetchLeaderboard(String competitionId) async {
    emit(GlobalLeaderboardLoading());

    final result =
        await _leaderboardRepository.getGlobalLeaderboard(competitionId);

    result.fold(
      (data) {
        entries = data;
        emit(GlobalLeaderboardLoaded());
      },
      (failure) => emit(GlobalLeaderboardError(failure)),
    );
  }

  Future<void> fetchLeagues() async {
    emit(GlobalLeaderboardLeaguesLoading());
    final result = await _leagueRepository.getAllLeagues();

    result.fold(
      (data) {
        leagues = data;
        emit(GlobalLeaderboardLeaguesLoaded());
      },
      (failure) => emit(GlobalLeaderboardLeaguesError(failure)),
    );
  }

  void onLeagueSelected(int index) {
    if (index == selectedLeagueIndex && state is GlobalLeaderboardLoading) {
      return;
    }
    selectedLeagueIndex = index;
    fetchLeaderboard(leagues[index].id);
    _ensureVisibleLeague();
  }
}



sealed class GlobalLeaderboardState {}

final class GlobalLeaderboardInitial extends GlobalLeaderboardState {}

// leaderboard

class GlobalLeaderboardLoading extends GlobalLeaderboardState {}

class GlobalLeaderboardLoaded extends GlobalLeaderboardState {}

class GlobalLeaderboardError extends GlobalLeaderboardState {
  final Failure failure;

  GlobalLeaderboardError(this.failure);
}

// leagues

class GlobalLeaderboardLeaguesLoading extends GlobalLeaderboardState {}

class GlobalLeaderboardLeaguesLoaded extends GlobalLeaderboardState {}

class GlobalLeaderboardLeaguesError extends GlobalLeaderboardState {
  final Failure failure;

  GlobalLeaderboardLeaguesError(this.failure);
}



mixin GlobalLeaderboardScrollManagerMixin {
  final selectedLeagueKey = GlobalKey();
  late final ScrollController leaguesScrollController;

  final highlightedEntryKey = GlobalKey();
  late final ScrollController leaderboardScrollController;

  void initializeScrollControllers() {
    leaguesScrollController = ScrollController(onAttach: (_) {
      _onLeaguesScrollViewAttached();
    });

    leaderboardScrollController = ScrollController(onAttach: (_) {
      _onLeaderboardScrollViewAttached();
    });
  }

  Future<void> _onLeaguesScrollViewAttached() async {
    await Future.delayed(const Duration(milliseconds: 100)).whenComplete(
          () => _ensureVisibleLeague(),
    );
  }

  Future<void> _onLeaderboardScrollViewAttached() async {
    await Future.delayed(const Duration(milliseconds: 100)).whenComplete(
          () => _ensureVisibleEntry(),
    );
  }

  void _ensureVisibleLeague() {
    doPostFrame((_) {
      final context = selectedLeagueKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutQuart,
          alignment: 0.5,
        );
      }
    });
  }

  void _ensureVisibleEntry() {
    doPostFrame((_) {
      final context = highlightedEntryKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutQuart,
          alignment: 0.14,
        );
      }
    });
  }
}
