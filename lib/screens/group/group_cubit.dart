// ignore_for_file: constant_identifier_names

import 'package:educ_core/data/models/group.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/data/repositories/group_repository.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/foundation.dart';

enum SubscriptionOption {
  allNotifications(Svgs.optionAllNotifications), // Receive All Notifications
  importantOnly(Svgs.optionImportantOnly), // Important Notifications Only
  muteNotifications(Svgs.optionDisableNotifications); // Disable All Notifications

  final String iconPath;

  const SubscriptionOption(this.iconPath);

  String getTranslationKey() {
    return switch (this) {
      SubscriptionOption.allNotifications => "all_notifications",
      SubscriptionOption.importantOnly => "important_only",
      SubscriptionOption.muteNotifications => "mute_notifications",
    };
  }

  String getShortTranslationKey() {
    return switch (this) {
      SubscriptionOption.allNotifications => "all",
      SubscriptionOption.importantOnly => "important",
      SubscriptionOption.muteNotifications => "muted",
    };
  }

  factory SubscriptionOption.fromIndex(int index) {
    try {
      return SubscriptionOption.values[index];
    } catch (e) {
      return SubscriptionOption.allNotifications;
    }
  }
}

class GroupCubit extends DataCubit<GroupState> {
  GroupCubit({required Group this.group}) : _groupId = group.id,groupName = group.name, super(GroupInitial()) {
    initialize();
  }

  GroupCubit.fromId(this._groupId) : super(GroupInitial()) {
    fetch().whenComplete(initialize);
  }

  final String _groupId;
  String groupName = "";
  Group? group;

  SubscriptionOption subscriptionOption = SubscriptionOption.allNotifications;

  final _groupRepository = GroupRepository();
  final _accountRepository = AccountRepository();

  void initialize() {
    final group = this.group;
    if (group != null) {
      subscriptionOption = SubscriptionOption.fromIndex(group.subscriptionId);
      emit(GroupSubscriptionChanged());
    }
  }

  @override
  Future<void> fetch() async {
    await fetchGroup();
  }

  Future<void> fetchGroup({bool silent = false}) async {
    if (!silent) {
      emit(GroupLoading());
    } else {
      emit(GroupSilentLoading());
    }

    final result = await _groupRepository.getGroup(_groupId);
    await result.fold((data) {
      group = data;
      emit(GroupLoaded());
      initialize();
    }, (failure) => emit(GroupError(failure)));
  }

  Future<void> joinGroup() async {
    final group = this.group;
    if (state is GroupLoading || state is GroupSilentLoading || group == null) {
      return;
    }

    emit(GroupJoinLoading());
    final result = await _groupRepository.joinGroup(group.id);
    await result.fold((data) {
      emit(GroupJoinSuccess());
      group.hasJoined = 1;
      // fetchGroup(silent: true);
    }, (failure) => emit(GroupJoinError(failure)));
  }

  Future<void> leaveGroup() async {
    final group = this.group;
    if (state is GroupLoading || state is GroupSilentLoading || group == null) {
      return;
    }

    emit(GroupLeaveLoading());
    final result = await _groupRepository.leaveGroup(group.id);
    await result.fold((data) {
      group.hasJoined = 0;
      emit(GroupLeaveSuccess());

      // fetchGroup(silent: true);
    }, (failure) => emit(GroupLeaveError(failure)));
  }

  Future<void> updateSubscription() async {
    final group = this.group;
    if (state is GroupLoading || state is GroupSilentLoading || group == null) {
      return;
    }

    final result = await _accountRepository.setGroupSubscription(
      group.id,
      subscriptionOption.index,
    );
    await result.fold((data) {
      emit(GroupSubscriptionChanged());
      fetchGroup(silent: true);
    }, (failure) => emit(GroupError(failure)));
  }

  void setSubscription(SubscriptionOption? option) {
    if (option != null) {
      subscriptionOption = option;
      group?.subscriptionId = option.index;
      emit(GroupSubscriptionChanged());
      updateSubscription();
    }
  }
}

@immutable
sealed class GroupState {}

final class GroupInitial extends GroupState {}

final class GroupLoading extends GroupState {}

final class GroupSilentLoading extends GroupState {}

final class GroupLoaded extends GroupState {}

final class GroupError extends GroupState {
  final Failure failure;

  GroupError(this.failure);
}

final class GroupJoinLoading extends GroupState {}

final class GroupJoinSuccess extends GroupState {}

final class GroupJoinError extends GroupState {
  final Failure failure;

  GroupJoinError(this.failure);
}

final class GroupLeaveLoading extends GroupState {}

final class GroupLeaveSuccess extends GroupState {}

final class GroupLeaveError extends GroupState {
  final Failure failure;

  GroupLeaveError(this.failure);
}

final class GroupSubscriptionChanged extends GroupState {}
