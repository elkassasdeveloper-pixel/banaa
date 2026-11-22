import 'dart:async';

import 'package:educ_core/data/models/group.dart';
import 'package:educ_core/data/models/topic.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/auth/auth_screen.dart';
import 'package:educ_student/screens/auth/change_password_screen.dart';
import 'package:educ_student/screens/auth/login_screen.dart';
import 'package:educ_student/screens/auth/request_reset_passsword_screen.dart';
import 'package:educ_student/screens/auth/reset_password_screen.dart';
import 'package:educ_student/screens/auth/sign_up_screen.dart';
import 'package:educ_student/screens/chat/chat_screen.dart';
import 'package:educ_student/screens/community/community_screen.dart';
import 'package:educ_student/screens/group/group_cubit.dart';
import 'package:educ_student/screens/group/group_screen.dart';
import 'package:educ_student/screens/leaderboard/leaderboard_screen.dart';
import 'package:educ_student/screens/learn/learn_screen.dart';
import 'package:educ_student/screens/main_screen.dart';
import 'package:educ_student/screens/on_boarding/on_boarding_screen.dart';
import 'package:educ_student/screens/other/achievements_screen.dart';
import 'package:educ_student/screens/other/bookmarks_screen.dart';
import 'package:educ_student/screens/other/certificates_screen.dart';
import 'package:educ_student/screens/other/edit_profile.dart';
import 'package:educ_student/screens/other/edit_avatar_screen.dart';
import 'package:educ_student/screens/other/help_center_screen.dart';
import 'package:educ_student/screens/other/link_account_screen.dart';
import 'package:educ_student/screens/other/not_found_screen.dart';
import 'package:educ_student/screens/other/settings_screen.dart';
import 'package:educ_student/screens/post/create_post_screen.dart';
import 'package:educ_student/screens/post/post_cubit.dart';
import 'package:educ_student/screens/post/post_screen.dart';
import 'package:educ_student/screens/profile/profile_screen.dart';
import 'package:educ_student/screens/quiz/advanced_quiz_cubit.dart';
import 'package:educ_student/screens/quiz/quiz_cubit.dart';
import 'package:educ_student/screens/quiz/quiz_screen.dart';
import 'package:educ_student/screens/root_screen.dart';
import 'package:educ_student/screens/topic_details/topic_details_screen.dart';
import 'package:educ_student/screens/walkthrough/walkthrough_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavLearnKey = GlobalKey<NavigatorState>();
  static final shellNavLeaderboardKey = GlobalKey<NavigatorState>();
  static final shellNavCommunityKey = GlobalKey<NavigatorState>();
  static final shellNavProfileKey = GlobalKey<NavigatorState>();

  static final goRouter = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.initialLocation,
    redirect: _globalRedirect,
    routes: [
      GoRoute(
        path: "/",
        name: Routes.ROOT,
        // redirect: _onAppStartRedirect,
        builder: (context, state) => const RootScreen(),
      ),
      GoRoute(
        path: "/welcome",
        name: Routes.ON_BOARDING,
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        path: "/auth",
        name: Routes.AUTH,
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: Routes.LOGIN,
            name: Routes.LOGIN,
            builder: (context, state) => const LoginScreen(),
            routes: [
              GoRoute(
                path: Routes.REQUEST_PASSWORD_RESET,
                name: Routes.REQUEST_PASSWORD_RESET,
                builder: (context, state) => const RequestResetPasswordScreen(),
                routes: [
                  GoRoute(
                    path: Routes.RESET_PASSWORD,
                    name: Routes.RESET_PASSWORD,
                    builder: (context, state) => const ResetPasswordScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.SIGN_UP,
            name: Routes.SIGN_UP,
            builder: (context, state) => const SignUpScreen(),
            routes: [
              GoRoute(
                path: Routes.WALKTHROUGH,
                name: Routes.WALKTHROUGH,
                builder: (context, state) {
                  return const WalkthroughScreen();
                },
                routes: [
                  GoRoute(
                    path: Routes.ADVANCED_QUIZ,
                    name: Routes.ADVANCED_QUIZ,
                    builder: (context, state) {
                      final rootCollectionId = state.uri.queryParameters["rootCollectionId"];
                      final languageCode = state.uri.queryParameters["languageCode"];
                      final extra = state.extra as Future<void> Function()?;

                      if (rootCollectionId != null && languageCode != null) {
                        return BlocProvider(
                          create: (context) => AdvancedQuizCubit(rootCollectionId, languageCode),
                          child: QuizScreen<AdvancedQuizCubit>(signUp: extra),
                        );
                      } else {
                        return const NotFoundScreen();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavLearnKey,
            routes: [
              GoRoute(
                path: "/${Routes.LEARN}",
                name: Routes.LEARN,
                builder: (context, state) => const LearnScreen(),
                // builder: (context, state) => const FinishedAttemptsScreen(),
                routes: [
                  /* GoRoute(
                    path: Routes.TASBEEH,
                    name: Routes.TASBEEH,
                    builder: (context, state) {
                      return const FinishedAttemptsScreen();
                    },
                    // routes: []
                  ),*/
                  GoRoute(
                    path: ":topicId",
                    name: Routes.TOPIC,
                    builder: (context, state) {
                      final extra = state.extra;

                      if (extra is Map<String, dynamic>) {
                        final Topic topic = Topic.fromMap(extra);
                        return TopicDetailsScreen(topic: topic);

                        ///   return FinishedAttemptsScreen();
                      }

                      final topicId = state.pathParameters["topicId"]!;
                      return TopicDetailsScreen.fromId(topicId: topicId);

                      ///    return FinishedAttemptsScreen();
                    },
                    routes: [
                      GoRoute(
                        path: Routes.QUIZ,
                        name: Routes.QUIZ,
                        builder: (context, state) {
                          // final extra = state.extra;
                          //
                          // if (extra is Map<String, dynamic>) {
                          //   final Quiz quiz = Quiz.fromMap(extra);
                          //   return BlocProvider(
                          //     create: (context) => QuizCubit(quiz: quiz),
                          //     child: const QuizScreen(),
                          //   );
                          // }

                          final topicId = state.pathParameters["topicId"]!;
                          return BlocProvider(
                            create: (context) {
                              // CacheHelper.shouldResetAssistantToday("َQuizzesAssistantShown").then((
                              //   shouldShow,
                              // ) {
                              //   if (shouldShow) {
                              //     context.read<AssistantCubit>().assistantBubbles = [
                              //       AssistantBubble(
                              //         app_event_descr_a:
                              //             "جاوب على الأسئلة بدقة لتحصل على أعلى النقاط!",
                              //       ),
                              //       AssistantBubble(
                              //         app_event_descr_a: "لا تقلق من الخطأ، كل محاولة تعلم.",
                              //       ),
                              //       // AssistantBubble(body: "استخدم مهاراتك وابدأ الآن 💪"),
                              //     ];
                              //     context.read<AssistantCubit>().resetAssistant();
                              //   }
                              // });
                              return QuizCubit.fromId(topicId);
                            },
                            child: const QuizScreen<QuizCubit>(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavLeaderboardKey,
            routes: [
              GoRoute(
                path: "/${Routes.LEADERBOARD}",
                name: Routes.LEADERBOARD,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavCommunityKey,
            routes: [
              GoRoute(
                path: "/${Routes.COMMUNITY}",
                name: Routes.COMMUNITY,
                builder: (context, state) => const CommunityScreen(),
                routes: [
                  GoRoute(
                    path: "group/:groupId",
                    name: Routes.GROUP,
                    builder: (context, state) {
                      final extra = state.extra;
                      Logger.Red("extra: $extra");
                      if (extra is Map<String, dynamic>) {
                        final group = Group.fromMapDetail(extra);
                        Logger.Black("group: ${group.toMap()}");
                        Logger.Red("group: ${group.id}");
                        Logger.data("group", group.id);

                        return BlocProvider(
                          create: (context) => GroupCubit(group: group),
                          child: const GroupScreen(),
                        );
                      }
                      final groupId = state.pathParameters["groupId"]!;
                      return BlocProvider(
                        create: (context) => GroupCubit.fromId(groupId),
                        child: const GroupScreen(),
                      );
                    },
                  ),
                  GoRoute(
                    path: "post/:postId",
                    name: Routes.POST,
                    builder: (context, state) {
                      final extra = state.extra;

                      if (extra is Map<String, dynamic>) {
                        final cubit = extra["cubit"] as PostCubit;

                        return BlocProvider.value(value: cubit, child: const PostScreen());
                      }
                      final postId = state.pathParameters["postId"]!;
                      return BlocProvider(
                        create: (context) => PostCubit.fromId(postId),
                        child: const PostScreen(),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: Routes.CREATE_POST,
                        name: Routes.CREATE_POST,

                        /// todo : >>  2024 - 9 - 26
                        builder: (context, state) => CreatePostScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.CHAT,
                    name: Routes.CHAT,
                    builder: (context, state) {
                      return ChatScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavProfileKey,
            routes: [
              GoRoute(
                path: "/${Routes.PROFILE}",
                name: Routes.PROFILE,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: Routes.SETTINGS,
                    name: Routes.SETTINGS,
                    builder: (context, state) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.CHANGEPASSWORD,
                        name: Routes.CHANGEPASSWORD,
                        builder: (context, state) => ChangePasswordScreen(),
                      ),
                      GoRoute(
                        path: Routes.EDITPROFILE,
                        name: Routes.EDITPROFILE,
                        builder: (context, state) => EditProfileScreen(),
                      ),
                      GoRoute(
                        path: Routes.LINK_ACCOUNT,
                        name: Routes.LINK_ACCOUNT,
                        builder: (context, state) => LinkAccountScreen(),
                      ),
                      GoRoute(
                        path: Routes.EditAvatar,
                        name: Routes.EditAvatar,
                        builder: (context, state) => EditAvatarScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.ACHIEVEMENTS,
                    name: Routes.ACHIEVEMENTS,
                    builder: (context, state) => const AchievementsScreen(),
                  ),
                  GoRoute(
                    path: Routes.BOOKMARKS,
                    name: Routes.BOOKMARKS,
                    builder: (context, state) => const BookmarksScreen(),
                  ),
                  GoRoute(
                    path: Routes.CERTIFICATES,
                    name: Routes.CERTIFICATES,
                    builder: (context, state) => const CertificatesScreen(),
                  ),
                  GoRoute(
                    path: Routes.HELP_CENTER,
                    name: Routes.HELP_CENTER,
                    builder: (context, state) => const HelpCenterScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );

  static FutureOr<String?> _globalRedirect(BuildContext context, GoRouterState state) {
    try {
      final token = CacheHelper.getToken();
      final auth = context.read<AuthCubit>();
      final isAuthenticated = auth.isAuthenticated;
      final isAuthRoute = (state.fullPath ?? "").startsWith("/${Routes.AUTH}");
      final isWelcomeRoute = (state.fullPath ?? "").startsWith("/welcome");
      final isRootRoute = (state.fullPath ?? "") == "/";

      // Logger.data("fullPath", state.fullPath);
      // Logger.data("token", token != null);
      // Logger.data("isAuthenticated", isAuthenticated);
      // Logger.data("isAuthRoute", isAuthRoute);
      // Logger.data("isWelcomeRoute", isWelcomeRoute);
      // Logger.data("isRootRoute", isRootRoute);

      // do not redirect if condition is true
      if (isWelcomeRoute || isRootRoute) {
        return null;
      }
      // if is not authenticated, auto redirect to auth route
      else if (!isAuthenticated && !isAuthRoute && token == null) {
        // _resetLocale(context);
        return "/${Routes.AUTH}";
      }
      // if is authenticated, auto redirect to main route
      else if (isAuthenticated && isAuthRoute && token != null) {
        return "/${Routes.LEARN}";
      }
    } catch (e) {
      // log("Redirect error", error: e, name: "AppRouter");
    }

    return null;
  }

  // static void _resetLocale(BuildContext context) {
  //   final platformLanguage = PlatformDispatcher.instance.locale.languageCode;
  //   context.setLanguage(platformLanguage);
  // }
}
