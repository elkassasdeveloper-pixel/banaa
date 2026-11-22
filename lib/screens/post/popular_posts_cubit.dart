import 'package:educ_core/data/models/post.dart';
import 'package:educ_core/data/repositories/post_repository.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';

class PopularPostsCubit extends DataCubit<PopularPostsState> {
  PopularPostsCubit() : super(PopularPostsInitial()) {
    fetch();
  }

  final _postRepository = PostRepository();
  List<Post> popularPosts = [];
  String searchQuery = '';

  @override
  Future<void> fetch() async {
    await fetchPopularPosts();
  }

  Future<void> fetchPopularPosts() async {
    emit(PopularPostsLoading());

    final result = await _postRepository.getPopularPosts();

    result.fold(
      (data) {
        popularPosts = data;
        emit(PopularPostsLoaded());
      },
      (failure) => emit(PopularPostsError(failure)),
    );
  }

  List<Post> get filteredPosts {
    if (searchQuery.isEmpty) return popularPosts;
    return popularPosts
        .where((p) => p.body.toLowerCase().contains(searchQuery))
        .toList();
  }

  void search(String query) {
    searchQuery = query.trim().toLowerCase();
    emit(PopularPostsLoaded());
  }
}

@immutable
sealed class PopularPostsState {}

final class PopularPostsInitial extends PopularPostsState {}

final class PopularPostsLoading extends PopularPostsState {}

final class PopularPostsLoaded extends PopularPostsState {}

final class PopularPostsError extends PopularPostsState {
  final Failure failure;

  PopularPostsError(this.failure);
}
