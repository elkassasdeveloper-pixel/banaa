import 'dart:io';

import 'package:educ_core/constants/strings.dart';
import 'package:educ_core/data/models/topic.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/data/repositories/topic_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class TopicCubit extends DataCubit<TopicState> {
  TopicCubit({required Topic this.topic})
      : _topicId = topic.id,
        super(TopicInitial()) {
    doPostFrame((_) => setRecentTopic());
  }

  TopicCubit.fromId(this._topicId) : super(TopicInitial()) {
    fetch();
  }

  final String _topicId;
  Topic? topic;
  bool isButtonVisible = true;

  double lastScrollDelta = 0;

  final _topicRepository = TopicRepository();
  final _accountRepository = AccountRepository();

  String get topicId => topic?.id ?? _topicId;

  @override
  Future<void> fetch() async {
    await fetchTopic();
    await setRecentTopic();
  }

  Future<void> fetchTopic({bool silent = false}) async {
    if (!silent) {
      emit(TopicLoading());
    }

    final result = await _topicRepository.getTopic(topicId);

    await result.fold(
      (data) {
        topic = data;
        emit(TopicLoaded());
      },
      (failure) => emit(TopicError(failure)),
    );
  }

  void setButtonVisibility(bool value) {
    isButtonVisible = value;
    emit(TopicChanged());
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta != null) {
        if (lastScrollDelta.sign != delta.sign) {
          lastScrollDelta = delta;
          if (delta > 0) {
            setButtonVisibility(false);
          } else {
            setButtonVisibility(true);
          }
        }
      }
    }
    return false;
  }

  Future<void> setRecentTopic() async {
    try {
      emit(TopicChanged());
      await _accountRepository.setRecentTopic(topicId: topicId);
    } catch (e) {
      Logger.Red(e);
    }
  }

  Future<void> toggleBookmark(String topicId) async {
    if (topic == null) return;

    if (topic!.isBookmarked) {
      await removeBookmark(topicId);
    } else {
      await addBookmark(topicId);
    }
  }

  Future<void> addBookmark(String topicId) async {
    final topic = this.topic;
    if (topic == null) return;
    final current = topic.isBookmarked;

    emit(TopicBookmarkLoading());
    final result = await _accountRepository.addTopicBookmark(topicId);
    result.fold(
      (data) {
        topic.isBookmarked = true;
        emit(TopicAddBookmarkSuccess());
        fetchTopic(silent: true);
      },
      (failure) {
        topic.isBookmarked = current;
        emit(TopicAddBookmarkError(failure));
      },
    );
  }

  Future<void> removeBookmark(String topicId) async {
    final topic = this.topic;
    if (topic == null) return;
    final current = topic.isBookmarked;

    emit(TopicBookmarkLoading());
    final result = await _accountRepository.removeTopicBookmark(topicId);
    result.fold(
      (data) {
        topic.isBookmarked = false;
        // fetchTopic(silent: false);
        emit(TopicRemoveBookmarkSuccess());

      },
      (failure) {
        topic.isBookmarked = current;
        emit(TopicRemoveBookmarkError(failure));
      },
    );
  }

  Future<void> shareTopic(BuildContext context) async {
    final topic = this.topic;
    if (topic == null) return;

    final uri = Uri.parse(
      "$WEBSITE_URL/#/${Routes.LEARN}/${topic.id}",
    );
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final shareResult = await SharePlus.instance.share(
          ShareParams(
            text:  "user_shared_post".tr(
              namedArgs: {
                "app_name": "app_name".tr(),
                "link": uri.toString(),
              },
            ),
          )
      );

      if (shareResult.status != ShareResultStatus.success) return;
    } else {
      Clipboard.setData(ClipboardData(text: uri.toString()));
      context.showSuccessSnackBar("link_copied_to_clipboard".tr());
    }
  }
}

abstract class TopicState {}

class TopicInitial extends TopicState {}

class TopicLoading extends TopicState {}

class TopicLoaded extends TopicState {}

class TopicError extends TopicState {
  final Failure failure;

  TopicError(this.failure);
}

class TopicChanged extends TopicState {}

// bookmark
final class TopicBookmarkLoading extends TopicState {}

// add bookmark
final class TopicAddBookmarkSuccess extends TopicState {}

final class TopicAddBookmarkError extends TopicError {
  TopicAddBookmarkError(super.failure);
}

// remove bookmark
final class TopicRemoveBookmarkSuccess extends TopicState {}

final class TopicRemoveBookmarkError extends TopicError {
  TopicRemoveBookmarkError(super.failure);
}

// class TopicState {
//   final Topic? topic;
//   final bool isLoading;
//   final String? error;
//   final bool isButtonVisible;
//
//   TopicState({
//     this.topic,
//     this.isLoading = false,
//     this.error,
//     this.isButtonVisible = true,
//   });
//
//   TopicState copyWith({
//     Topic? topic,
//     bool? isLoading,
//     String? error,
//     bool? isButtonVisible,
//   }) {
//     return TopicState(
//       topic: topic ?? this.topic,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//       isButtonVisible: isButtonVisible ?? this.isButtonVisible,
//     );
//   }
// }
