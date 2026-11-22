import 'package:educ_core/data/models/group_member.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/data/repositories/group_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';

class GroupMembersCubit extends DataCubit<GroupMembersState> {
  GroupMembersCubit(this.groupId) : super(GroupMembersInitial()) {
    fetch();
  }

  final String groupId;

  final _groupRepository = GroupRepository();
  final _accountRepository = AccountRepository();
  List<GroupMember> members = [];
  String searchQuery = '';

  List<GroupMember> get filteredMembers {
    if (searchQuery.isEmpty) return members;
    return members
        .where((m) => '${m.firstName} ${m.lastName}'
        .toLowerCase()
        .contains(searchQuery))
        .toList();
  }

  void search(String query) {
    searchQuery = query.trim().toLowerCase();
    emit(GroupMembersLoaded());
  }

  @override
  Future<void> fetch() async {
    await fetchMembers();
  }

  Future<void> fetchMembers({bool silent = false}) async {
    if (!silent) {
      emit(GroupMembersLoading());
    } else {
      emit(GroupMembersSilentLoading());
    }

    final result = await _groupRepository.getGroupMembers(groupId);

    result.fold(
      (data) {
        members = data;
        emit(GroupMembersLoaded());
      },
      (failure) => emit(GroupMembersError(failure)),
    );
  }

  Future<void> followUser(String userId) async {
    if (state is GroupMembersLoading || state is GroupMembersSilentLoading) {
      return;
    }

    final member = members.firstWhereOrNull((m) => m.userId == userId);
    member?.isRequesting = true;

    emit(GroupMembersFollowLoading());
    final result = await _accountRepository.followUser(userId);

    result.fold(
      (data) {
        member?.isFollowing = true;
        member?.isRequesting = false;
        emit(GroupMembersFollowSuccess());
        fetchMembers(silent: true);
      },
      (failure) {
        member?.isRequesting = false;
        emit(GroupMembersFollowError(failure));
      },
    );
  }

  Future<void> unfollowUser(String userId) async {
    if (state is GroupMembersLoading || state is GroupMembersSilentLoading) {
      return;
    }

    final member = members.firstWhereOrNull((m) => m.userId == userId);
    member?.isRequesting = true;

    emit(GroupMembersFollowLoading());
    final result = await _accountRepository.unfollowUser(userId);

    result.fold(
      (data) {
        member?.isFollowing = false;
        member?.isRequesting = false;
        emit(GroupMembersFollowSuccess());
        fetchMembers(silent: true);
      },
      (failure) {
        member?.isRequesting = false;
        emit(GroupMembersFollowError(failure));
      },
    );
  }
}

@immutable
sealed class GroupMembersState {}

final class GroupMembersInitial extends GroupMembersState {}

final class GroupMembersLoading extends GroupMembersState {}

final class GroupMembersSilentLoading extends GroupMembersState {}

final class GroupMembersLoaded extends GroupMembersState {}

final class GroupMembersError extends GroupMembersState {
  final Failure failure;

  GroupMembersError(this.failure);
}

final class GroupMembersFollowLoading extends GroupMembersState {}

final class GroupMembersFollowSuccess extends GroupMembersState {}

final class GroupMembersFollowError extends GroupMembersState {
  final Failure failure;

  GroupMembersFollowError(this.failure);
}
