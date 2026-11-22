import 'package:educ_core/data/models/post.dart';
import 'package:educ_core/data/repositories/post_repository.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';

class GroupPostsCubit extends DataCubit<GroupPostsState> {
  GroupPostsCubit(this.groupId) : super(GroupPostsInitial()) {
    fetch();
  }

  final String groupId;

  final _postRepository = PostRepository();
  List<Post> posts = [];
  String searchQuery = '';

  List<Post> get filteredPosts {
    if (searchQuery.isEmpty) return posts;
    return posts
        .where((p) => p.body.toLowerCase().contains(searchQuery))
        .toList();
  }

  void search(String query) {
    searchQuery = query.trim().toLowerCase();
    emit(GroupPostsLoaded());
  }

  @override
  Future<void> fetch() async {
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    emit(GroupPostsLoading());
    Logger.Magenta("fetchPosts");
    Logger.Magenta(groupId);
    final result = await _postRepository.getGroupPosts(groupId);

    result.fold(
      (data) {
        posts = data;
        emit(GroupPostsLoaded());
      },
      (failure) => emit(GroupPostsError(failure)),
    );
  }
}


@immutable
sealed class GroupPostsState {}

final class GroupPostsInitial extends GroupPostsState {}

final class GroupPostsLoading extends GroupPostsState {}

final class GroupPostsLoaded extends GroupPostsState {}

final class GroupPostsError extends GroupPostsState {
  final Failure failure;

  GroupPostsError(this.failure);
}
