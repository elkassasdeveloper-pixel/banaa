import 'dart:convert';

import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_student/core/constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddPostCubit extends Cubit<AddPostCubitState> {
  AddPostCubit() : super(InitAddPostCubitState());

  final dio = DioHelper.dio;
  final bodyController = TextEditingController();
  final quillController = QuillController.basic();

  Future<void> addPost(BuildContext context) async {
    Logger.Green("addPost");
    Logger.Magenta("userId: ${DioHelper.userId}");
    Logger.Magenta("groupId: ${Strings.groupId}");
    Logger.Magenta("body: ${bodyController.text}");
    emit(AddPostLoading());
    try {
      await DioHelper.post(
        context: context,
        endPoint: 'https://banaaapi.hodhdsoft.com/posts/user',
        data: {"postedById": DioHelper.userId, "approvedPostCreationRequestId": "", "groupId": Strings.groupId, "body": jsonEncode(quillController.document.toDelta().toJson())},
        onError: () {
          emit(AddPostError());
        },
        onSuccess: () {
          context.showSuccessSnackBar("post_added_successfully".tr());
          context.pop();
          context.pop();
          emit(AddPostSuccess());
        },
        successSilent: true,
      );
    } catch (e) {
      Logger.Red(e);
      emit(AddPostError());
    }
  }
}

abstract class AddPostCubitState {}

class InitAddPostCubitState extends AddPostCubitState {}

class AddPostLoading extends AddPostCubitState {}

class AddPostSuccess extends AddPostCubitState {}

class AddPostError extends AddPostCubitState {}
