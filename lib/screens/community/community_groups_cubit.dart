import 'package:educ_core/data/models/group.dart';
import 'package:educ_core/data/repositories/group_repository.dart';
import 'package:educ_core/services/centrifugo/jwt_decoder.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:educ_core/services/centrifugo/conf.dart' as conf;

class CommunityGroupsCubit extends DataCubit<CommunityGroupsState> {
  CommunityGroupsCubit() : super(CommunityGroupsInitial()) {
    fetch();
  }

  final _groupRepository = GroupRepository();
  bool showAssistantBefore = false;
  List<Group> groups = [];
  Map<String,dynamic> room = {};
  String searchQuery = '';

  @override
  Future<void> fetch() async {
    await fetchGroups();
    await fetchChatData();
  }

  Future<void> fetchGroups() async {
    emit(CommunityGroupsLoading());

    final result = await _groupRepository.getAllGroups();

    result.fold((data) {
      groups = data;
      emit(CommunityGroupsLoaded());
    }, (failure) => emit(CommunityGroupsError(failure)));
  }

  Future<void> fetchChatData() async {
    emit(ChatDataLoading());
    try {
      DioHelper.dio.get(
      "/api/HodhdAuthorization/user_any_admin",
      ).then((response) {
          if(response.data["data"] != null){
            final result = response.data["data"] as List;
            if(result.isNotEmpty){
              room = result.first;
              conf.subscriptionJwtToken = room["private_admin"];
              final decodedToken = JwtDecoder.decode(conf.subscriptionJwtToken);
              conf.channel = decodedToken["channel"];
              conf.userId = decodedToken["sub"];
              conf.userJwtToken = room["token2"];
            }else{
              room = {};
            }
        }
          emit(ChatDataLSuccess());
      },);
    } catch (e) {
      debugPrint(e.toString());
      emit(ChatDataError());
    }
  }

  void updateGroup(Group group) {
    final index = groups.indexWhere((element) => element.id == group.id);
    if (index != -1) {
      groups[index] = group;
    }
    emit(CommunityGroupsLoaded());
  }

  List<Group> get filteredGroups {
    if (searchQuery.isEmpty) return groups;
    return groups
        .where((g) => g.name.toLowerCase().contains(searchQuery))
        .toList();
  }

  void search(String query) {
    searchQuery = query.trim().toLowerCase();
    emit(CommunityGroupsLoaded());
  }
}

@immutable
sealed class CommunityGroupsState {}

final class CommunityGroupsInitial extends CommunityGroupsState {}

final class ChatDataLoading extends CommunityGroupsState {}

final class ChatDataLSuccess extends CommunityGroupsState {}

final class ChatDataError extends CommunityGroupsState {}

final class CommunityGroupsLoading extends CommunityGroupsState {}

final class CommunityGroupsLoaded extends CommunityGroupsState {}

final class CommunityGroupsError extends CommunityGroupsState {
  final Failure failure;

  CommunityGroupsError(this.failure);
}
