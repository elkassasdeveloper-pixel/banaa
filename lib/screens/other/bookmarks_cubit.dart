import 'package:educ_core/data/models/topic.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';

class BookmarksCubit extends DataCubit<BookmarksState> {
  BookmarksCubit() : super(BookmarksInitial()) {
    fetch();
  }

  List<Topic>? bookmarks;
  final _accountRepository = AccountRepository();

  @override
  Future<void> fetch() async {
    await fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    emit(BookmarksLoading());
    final result = await _accountRepository.getBookmarks();
    result.fold(
      (data) {
        bookmarks = data;
        emit(BookmarksLoaded());
      },
      (failure) => emit(BookmarksError(failure)),
    );
  }
}

@immutable
sealed class BookmarksState {}

final class BookmarksInitial extends BookmarksState {}

final class BookmarksLoading extends BookmarksState {}

final class BookmarksLoaded extends BookmarksState {}

final class BookmarksError extends BookmarksState {
  final Failure failure;

  BookmarksError(this.failure);
}
