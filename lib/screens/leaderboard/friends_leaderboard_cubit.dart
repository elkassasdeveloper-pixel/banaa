import 'package:educ_core/data/models/collection.dart';
import 'package:educ_core/data/models/leaderboard_entry.dart';
import 'package:educ_core/data/repositories/collection_repository.dart';
import 'package:educ_core/data/repositories/leaderboard_repository.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:material_ui/material_ui.dart';

class FriendsLeaderboardCubit extends DataCubit<FriendsLeaderboardState>
    with FriendsLeaderboardScrollManager {
  FriendsLeaderboardCubit() : super(FriendsLeaderboardInitial()) {
    initializeScrollControllers();
    fetch();
  }

  List<Collection> rootCollections = [];
  List<LeaderboardEntry> entries = [];
  int selectedCollectionIndex = 0;

  final _leaderboardRepository = LeaderboardRepository();
  final _collectionRepository = CollectionRepository();

  String get currentCollectionName {
    try {
      return rootCollections[selectedCollectionIndex].name;
    } catch (e) {
      return "";
    }
  }

  @override
  Future<void> fetch({String languageCode = "ar"}) async {
    await fetchRootCollections(languageCode);
    await fetchCurrentLeaderboard();
  }

  Future<void> fetchCurrentLeaderboard() async {
    if (rootCollections.isNotEmpty) {
      await fetchLeaderboard(rootCollections[selectedCollectionIndex].id);
    }
  }

  Future<void> fetchLeaderboard(String collectionId) async {
    emit(FriendsLeaderboardLoading());

    final result =
        await _leaderboardRepository.getFriendsLeaderboard(collectionId);

    result.fold(
      (data) {
        entries = data;
        emit(FriendsLeaderboardLoaded());
      },
      (failure) => emit(FriendsLeaderboardError(failure)),
    );
  }

  Future<void> fetchRootCollections(String languageCode) async {
    emit(FriendsLeaderboardCollectionsLoading());
    final result = await _collectionRepository
        .getAllRootCollections(languageCode.toLowerCase());

    result.fold(
      (data) {
        rootCollections = data;
        emit(FriendsLeaderboardCollectionsLoaded());
      },
      (failure) => emit(FriendsLeaderboardCollectionsError(failure)),
    );
  }

  void onRootCollectionSelected(int index) {
    selectedCollectionIndex = index;
    fetchLeaderboard(rootCollections[index].id);
    _ensureVisibleCollection();
  }
}



sealed class FriendsLeaderboardState {}

final class FriendsLeaderboardInitial extends FriendsLeaderboardState {}

// leaderboard

class FriendsLeaderboardLoading extends FriendsLeaderboardState {}

class FriendsLeaderboardLoaded extends FriendsLeaderboardState {}

class FriendsLeaderboardError extends FriendsLeaderboardState {
  final Failure failure;

  FriendsLeaderboardError(this.failure);
}

// collections

class FriendsLeaderboardCollectionsLoading extends FriendsLeaderboardState {}

class FriendsLeaderboardCollectionsLoaded extends FriendsLeaderboardState {}

class FriendsLeaderboardCollectionsError extends FriendsLeaderboardState {
  final Failure failure;

  FriendsLeaderboardCollectionsError(this.failure);
}




mixin FriendsLeaderboardScrollManager {
  final highlightedEntryKey = GlobalKey();
  late final ScrollController collectionsScrollController;

  final selectedCollectionKey = GlobalKey();
  late final ScrollController leaderboardScrollController;

  void initializeScrollControllers() {
    collectionsScrollController = ScrollController(onAttach: (position) {
      _onCollectionsScrollViewAttached();
    });

    leaderboardScrollController = ScrollController(onAttach: (position) {
      _onLeaderboardScrollViewAttached();
    });
  }

  Future<void> _onCollectionsScrollViewAttached() async {
    await Future.delayed(const Duration(milliseconds: 100)).whenComplete(
          () => _ensureVisibleCollection(),
    );
  }

  Future<void> _onLeaderboardScrollViewAttached() async {
    await Future.delayed(const Duration(milliseconds: 100)).whenComplete(
          () => _ensureVisibleEntry(),
    );
  }

  void _ensureVisibleCollection() {
    doPostFrame((_) async {
      final context = selectedCollectionKey.currentContext;
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
    doPostFrame((_) async {
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
