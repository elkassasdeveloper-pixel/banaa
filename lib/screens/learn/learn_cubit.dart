import 'package:educ_core/data/models/collection.dart';
import 'package:educ_core/data/models/dtos/collections_or_topics.dart';
import 'package:educ_core/data/models/topic.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/data/repositories/collection_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LearnCubit extends DataCubit<LearnState> {
  final selectedRootCollectionKey = GlobalKey();
  late final ScrollController rootCollectionsScrollController;

  LearnCubit() : super(LearnInitial()) {
    initializeScrollControllers();
    fetch();
  }

  final CollectionRepository _collectionRepository = CollectionRepository();
  final AccountRepository _accountRepository = AccountRepository();

  List<Topic> topics = [];

  List<Collection> rootCollections = [];
  List<Collection> subCollections = [];
  Collection? selectedRootCollection;
  Collection? selectedSubCollection;
  String? activeCollectionId;
  String? activeRootCollectionName;
  String activePath = "";

  final scrollController = ScrollController();
  final listKey = GlobalKey();

  @override
  Future<void> fetch({String languageCode = "ar"}) async {
    emit(LearnInitial());
    topics = [];
    subCollections = [];
    selectedRootCollection = null;
    selectedSubCollection = null;
    activeCollectionId = null;
    activeRootCollectionName = null;
    activePath = "";

    await _fetchRecentTopics();
    await _fetchRootCollections(languageCode);
    await _updateInitialData();
  }

  Future onRefresh(BuildContext context) async {
    return Future.wait([
      fetch(languageCode: context.locale.languageCode),
      context.read<AuthCubit>().fetchUser(),
    ]);
  }

  Future<void> _updateInitialData() async {
    try {
      if (activeRootCollectionName != null && activeRootCollectionName!.isNotEmpty) {
        final rootCollection = rootCollections.firstWhere(
          (element) => element.name == activeRootCollectionName,
        );

        await updateSelectedRootCollection(rootCollection, ignoreTopics: true);

        if (activeCollectionId != null) {
          try {
            final subCollection = subCollections.firstWhere(
              (c) => c.id == activeCollectionId,
            );

            await updateSelectedSubCollection(subCollection);
          } catch (_) {
            activePath = rootCollection.name;
            emit(LearnChanged());
          }
        }
      } else if (rootCollections.isNotEmpty) {
        await updateSelectedRootCollection(rootCollections.first, ignoreTopics: false);
      }
    } catch (_) {
      // do nothing
    }
  }

  void initializeScrollControllers() {
    rootCollectionsScrollController = ScrollController(
      onAttach: (position) {
        doPostFrame((_) => onRootCollectionsListAttached);
      },
    );
  }

  Future<void> onRootCollectionsListAttached() async {
    await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() {
      final context = selectedRootCollectionKey.currentContext;
      if (context != null) {
        if(context.mounted) { Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutQuart,
          alignment: 0.5,
        );
      }}
    });
  }

  Future<void> _fetchRootCollections(String languageCode) async {
    emit(LearnCollectionsLoading());
    final result = await _collectionRepository.getAllRootCollections(
      languageCode.toLowerCase(),
    );

    await result.fold((collections) {
      rootCollections = collections;
      emit(LearnCollectionsLoaded());
    }, (failure) => emit(LearnCollectionsError(failure)));
  }

  Future<CollectionsOrTopics?> _fetchCollectionsOrTopics(
    String collectionId,
  ) async {
    emit(LearnCollectionsLoading());
    final result = await _collectionRepository.getCollectionChildren(
      parentId: collectionId,
    );

    return result.fold(
      (data) {
        return data.fold(
          (collections) {
            return CollectionsOrTopics(
              collections: collections,
              topics: [],
              isTopic: false,
              rootCollectionName: "",
            );
          },
          (topics) {
            return CollectionsOrTopics(
              collections: [],
              topics: topics,
              isTopic: true,
              rootCollectionName: topics.first.rootCollectionName,
            );
          },
        );
      },
      (failure) {
        emit(LearnCollectionsError(failure));
        return null;
      },
    );
  }

  Future<void> _fetchAndUpdateSubData(
    Collection col, {
    bool ignoreTopics = false,
  }) async {
    final subData = await _fetchCollectionsOrTopics(col.id);
    if (subData != null) {
      if (subData.collections.isNotEmpty) {
        subCollections = subData.collections;

        try {
          selectedSubCollection = subData.collections.firstWhere(
            (element) => element.id == activeCollectionId,
          );
        } catch (_) {
          //
        }
        emit(LearnCollectionsLoaded());
      } else if (subData.topics.isNotEmpty) {
        if (col.parentId == "1") {
          subCollections = [col];
          selectedSubCollection = col;
          emit(LearnCollectionsLoaded());
        }
        if (!ignoreTopics) {
          Collection? openedRootCollection;
          final bool collectionExists = rootCollections.any(
            (element) => element.name == subData.rootCollectionName,
          );
          try {
            openedRootCollection = collectionExists
                ? rootCollections.firstWhere(
                    (element) => element.name == subData.rootCollectionName,
                  )
                : null;
          } catch (_) {
            openedRootCollection = null;
          }

          if (openedRootCollection != null) {
            _accountRepository.setRecentCollection(collectionId: col.id);
          }
          topics = subData.topics;
          activeCollectionId = col.id;
          activeRootCollectionName = subData.rootCollectionName;
          selectedSubCollection = col;
        }
        emit(LearnTopicsLoaded());
      } else {
        topics = subData.topics;
        activeCollectionId = col.id;
        activeRootCollectionName = selectedRootCollection?.name;
        selectedSubCollection = col;
        emit(LearnTopicsLoaded());
      }
    } else {
      emit(LearnCollectionsLoaded());
    }
  }

  Future<void> updateSelectedRootCollection(
    Collection collection, {
    bool ignoreTopics = false,
  }) async {
    selectedRootCollection = collection;
    onRootCollectionsListAttached();
    subCollections = [];
    selectedSubCollection = null;
    // emit(state.copyWith(
    //     selectedRootCollection: collection,
    //     subCollections: [],
    //     selectedSubCollection: null,
    //     error: null));
    activePath = collection.name;
    emit(LearnChanged());
    await _fetchAndUpdateSubData(collection /* ignoreTopics: ignoreTopics*/);
  }

  Future<void> updateSelectedSubCollection(Collection collection) async {
    selectedSubCollection = collection;

    activePath = collection.name;
    emit(LearnChanged());
    await _fetchAndUpdateSubData(collection);
  }

  Future<void> refreshTopics() async {
    if (selectedSubCollection != null) {
      final result = await _collectionRepository.getCollectionChildren(
        parentId: selectedSubCollection!.id,
      );
      result.fold(
        (data) {
          data.fold(
            (collections) {},
            (newTopics) {
              topics = newTopics;
              emit(LearnTopicsLoaded());
            },
          );
        },
        (_) {},
      );
    }
  }

  Future<void> _fetchRecentTopics() async {
    emit(LearnTopicsLoading());

    final recentCollection = await _fetchRecentCollection();
    if (recentCollection != null) {
      topics = await _fetchTopics(recentCollection.id);

      activeCollectionId = recentCollection.id;
      if (topics.isNotEmpty) {
        activeRootCollectionName = topics.first.rootCollectionName;
      } else {
        activeRootCollectionName = "";
      }

      emit(LearnTopicsLoaded());
    } else {
      topics = [];
      activeCollectionId = null;
      activeRootCollectionName = "";
      selectedSubCollection = null;
      emit(LearnTopicsLoaded());
    }
  }

  Future<Collection?> _fetchRecentCollection() async {
    final result = await _accountRepository.getRecentCollection();

    return result.fold(
      (data) => data,
      (failure) {
        final code = failure.failureCode;
        final isNotFound = code.contains("User_RecentCollectionNotFound") ||
            code.contains("RecentCollectionNotFound") ||
            code.contains("not_found") ||
            failure.response?.statusCode == 404;

        if (isNotFound) {
          return null;
        }

        emit(LearnCollectionsError(failure));
        return null;
      },
    );
  }

  Future<List<Topic>> _fetchTopics(String collectionId) async {
    final result = await _collectionRepository.getCollectionChildren(
      parentId: collectionId,
    );

    return result.fold((data) {
      return data.fold((collections) => [], (topics) => topics);
    }, (_) => []);
  }

  // ({Topic topic, Topic? nextTopic}) getTopicAndNextTopic(String topicId) {
  //   final index = topics.indexWhere((element) => element.id == topicId);
  //   return (
  //     topic: topics[index],
  //     nextTopic: index + 1 < topics.length ? topics[index + 1] : null,
  //   );
  // }

  void setTopicAsRead(String topicId) {
    final index = topics.indexWhere((element) => element.id == topicId);

    if (index != -1) {
      topics[index].isOpened = true;
      emit(LearnTopicsLoaded());
    }
  }

  Topic? updateTopic(String topicId, Topic topic) {
    final index = topics.indexWhere((element) => element.id == topicId);
    if (index != -1) {
      topics[index] = topic;
      emit(LearnTopicsLoaded());

      return topics[index];
    }
    return null;
  }

  // calculates the percentage of completed topics in the current collection
  double calculateCompletedPercentage() {
    if (topics.isEmpty) {
      return 0;
    } else {
      return (topics.where((element) => element.isFinished == true).length /
              topics.length) *
          100;
    }
  }

  double calculateRemainingReadingTime() {
    if (topics.isEmpty) {
      return 0;
    } else {
      return topics.where((element) => element.isFinished == false).fold(0, (
        previousValue,
        element,
      ) {
        final time = element.calculateReadingTime();
        return previousValue + time;
      });
    }
  }

  void changePath(String newPath) {
    activePath = newPath;
    emit(LearnChanged());
  }
}

abstract class LearnState {}

class LearnInitial extends LearnState {}

class LearnTopicsLoading extends LearnState {}

class LearnTopicsLoaded extends LearnState {}

class LearnTopicsError extends LearnState {
  final Failure failure;

  LearnTopicsError(this.failure);
}

class LearnCollectionsLoading extends LearnState {}

class LearnCollectionsLoaded extends LearnState {}

class LearnCollectionsError extends LearnState {
  final Failure failure;

  LearnCollectionsError(this.failure);
}

class LearnChanged extends LearnState {}
