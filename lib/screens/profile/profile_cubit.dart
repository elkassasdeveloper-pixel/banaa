import 'dart:developer';

import 'package:educ_core/data/models/profile.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/services/centrifugo/conf.dart' as conf;
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';

class ProfileCubit extends DataCubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial()) {
    fetch();
  }

  Profile? profile;
  final _accountRepository = AccountRepository();

  @override
  Future<void> fetch() async {
    await fetchProfile();
  }

  Future<void> fetchProfile() async {
    emit(ProfileLoading());

    final result = await _accountRepository.getProfile();
    result.fold(
      (data) {
        profile = data;
        if(profile != null){
          conf.userName = "${profile!.firstName} ${profile!.lastName}";//todo
        }
        emit(ProfileLoaded());
      },
      (failure) => emit(ProfileError(failure)),
    );

    log(profile?.firstName ?? "no profile");
  }
}



sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {}

class ProfileError extends ProfileState {
  final Failure failure;

  ProfileError(this.failure);
}

// class ProfileState {
//   final Profile? profile;
//   final bool isLoading;
//   final String? error;
//
//   const ProfileState({
//     this.profile,
//     this.isLoading = false,
//     this.error,
//   });
//
//   ProfileState copyWith({
//     Profile? profile,
//     bool? isLoading,
//     String? error,
//   }) {
//     return ProfileState(
//       profile: profile ?? this.profile,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//     );
//   }
// }
