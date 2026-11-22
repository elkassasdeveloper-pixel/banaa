import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/data/repositories/user_repository.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/auth/login_cubit.dart';
import 'package:educ_student/screens/auth/sign_up_cubit.dart';
import 'package:educ_student/screens/walkthrough/wt_avatars_cubit.dart';
import 'package:educ_student/screens/walkthrough/wt_collections_cubit.dart';
import 'package:educ_student/screens/walkthrough/wt_user_details_form_cubit.dart';
import 'package:educ_student/screens/other/settings_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

Future<Result<User>> fetchCurrentUser() async {
  return UserRepository().getUser(DioHelper.userId ?? "");
}

void onAuthenticated(BuildContext context, User user, {bool go = true}) {
  final authCubit = context.read<AuthCubit>();
  final settingsCubit = context.read<SettingsCubit>();
  Logger.data("Language Code", user.languageCode);
  authCubit.setAuthenticated(context, user);
  settingsCubit.fetchPreferences();

  try {
    TextInput.finishAutofillContext(shouldSave: true);
    context.read<LoginCubit>().reset();
    context.read<SignUpCubit>().reset();
    context.read<WtUserDetailsFormCubit>().reset();
    context.read<WtAvatarsCubit>().reset();
    context.read<WtCollectionsCubit>().reset();

  } catch (_) {}

  if (go) {
    context.goNamed(Routes.LEARN);
  }
}

String localeToLanguageName(Locale locale) {
  return switch (locale.languageCode) {
    "ar" => "العربية",
    "en" => "English",
    _ => ""
  };
}

// void updateLanguageDependencies(BuildContext context) {
//   Future.wait([
//     context.read<AuthCubit>().fetchUser(),
//     context.read<LearnCubit>().fetch(),
//     context.read<GlobalLeaderboardCubit>().init(),
//     context.read<FriendsLeaderboardCubit>().init(),
//     context.read<CommunityGroupsCubit>().init(),
//     context.read<PopularPostsCubit>().init(),
//     context.read<ProfileCubit>().init(),
//   ]);
// }
