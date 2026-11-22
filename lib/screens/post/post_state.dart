part of 'post_cubit.dart';

@immutable
sealed class PostState {}

final class PostInitial extends PostState {}

// post
final class PostLoading extends PostState {}

final class PostSilentLoading extends PostState {}

final class PostLoaded extends PostState {}

abstract class PostErrorState extends PostState {
  final Failure failure;

  PostErrorState(this.failure);
}

final class PostError extends PostErrorState {
  PostError(super.failure);
}

final class PostImagesSliderScrolling extends PostState {}

final class PostImagesSliderPageChanged extends PostState {}

// like
final class PostLikeLoading extends PostState {}

final class PostLikeSuccess extends PostState {}

final class PostLikeError extends PostErrorState {
  PostLikeError(super.failure);
}

// unlike
final class PostUnlikeLoading extends PostState {}

final class PostUnlikeSuccess extends PostState {}

final class PostUnlikeError extends PostErrorState {
  PostUnlikeError(super.failure);
}

// share
final class PostShareLoading extends PostState {}

final class PostShareSuccess extends PostState {}

final class PostShareError extends PostErrorState {
  PostShareError(super.failure);
}
