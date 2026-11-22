import 'dart:io';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:educ_core/constants/strings.dart';
import 'package:educ_core/data/models/post.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/data/repositories/post_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/post/post_images_slider_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> with PostImagesSliderMixin {
  PostCubit({required Post this.post})
      : _postId = post.id,
        super(PostInitial()) {
    initPageController();
  }

  PostCubit.fromId(this._postId) : super(PostInitial()) {
    initPageController();
    fetchPost();
  }

  final String _postId;
  Post? post;

  String get postId => post?.id ?? _postId;

  final _postRepository = PostRepository();
  final _accountRepository = AccountRepository();

  Future<void> fetchPost({bool silent = false}) async {
    if (!silent) {
      emit(PostLoading());
    } else {
      emit(PostSilentLoading());
    }

    final result = await _postRepository.getPostById(postId);

    result.fold(
      (data) {
        post = data;
        emit(PostLoaded());
      },
      (failure) => emit(PostError(failure)),
    );
  }

  Future<void> toggleLike() async {
    if (post == null) return;

    if (post!.isLiked) {
      await dislike();
    } else {
      await like();
    }
  }

  Future<void> like() async {
    if (state is PostLoading || state is PostSilentLoading) {
      return;
    }

    final post = this.post;
    if (post == null) return;

    final currentIsLiked = post.isLiked;
    final currentLikesCount = post.likesCount;

    post.isLiked = true;
    post.likesCount++;
    emit(PostLikeLoading());

    final result = await _accountRepository.likePost(postId);
    result.fold(
      (data) {
        emit(PostLikeSuccess());
        fetchPost(silent: true);
      },
      (failure) {
        post.isLiked = currentIsLiked;
        post.likesCount = currentLikesCount;
        emit(PostLikeError(failure));
      },
    );
  }

  Future<void> dislike() async {
    if (state is PostLoading || state is PostSilentLoading) {
      return;
    }

    final post = this.post;
    if (post == null) return;

    final currentIsLiked = post.isLiked;
    final currentLikesCount = post.likesCount;

    post.isLiked = false;
    post.likesCount = math.max(0, post.likesCount - 1);

    emit(PostUnlikeLoading());
    final result = await _accountRepository.dislikePost(postId);
    result.fold(
      (data) {
        emit(PostUnlikeSuccess());
        fetchPost(silent: true);
      },
      (failure) {
        post.isLiked = currentIsLiked;
        post.likesCount = currentLikesCount;
        emit(PostUnlikeError(failure));
      },
    );
  }

  Future<void> sharePost(BuildContext context) async {
    final post = this.post;
    if (post != null) {
      final uri = Uri.parse(
        "$WEBSITE_URL/#/${Routes.COMMUNITY}/${Routes.POST}/${post.id}",
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

      final currentSharesCount = post.sharesCount;
      post.sharesCount++;

      emit(PostShareLoading());
      final result = await _accountRepository.sharePost(post.id);

      result.fold(
        (data) {
          emit(PostShareSuccess());
          fetchPost(silent: true);
        },
        (failure) {
          post.sharesCount = currentSharesCount;
          emit(PostShareError(failure));
        },
      );
    }
  }

}
