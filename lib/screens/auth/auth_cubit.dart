import 'dart:async';
import 'dart:math' as math;

import 'package:educ_core/constants/strings.dart';
import 'package:educ_core/data/models/user.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/data/repositories/user_repository.dart';
import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_core/widgets/smooth_corner/smooth_rectangle_border.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class AuthCubit extends DataCubit<AuthState> {
  AuthCubit() : super(Unauthenticated());

  final _accountRepository = AccountRepository();
  final _userRepository = UserRepository();
  static const int maxAttempts = 5;
  static const int refillSeconds = 60;
  final ValueNotifier<int?> attemptsCountdown = ValueNotifier(null);
  Timer? _attemptsTimer;
  bool _refilling = false;

  bool get isAuthenticated => state is Authenticated;

  int get accountAttempts {
    final state = this.state;
    return state is Authenticated ? state.user.totalAttempts : 5;
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    _syncAttemptsTimer(change.nextState); // onChange runs before `state` updates
  }

  void _syncAttemptsTimer(AuthState s) {
    final attempts = s is Authenticated ? s.user.totalAttempts : null;

    if (attempts == null || attempts >= maxAttempts) {
      _attemptsTimer?.cancel();
      _attemptsTimer = null;
      attemptsCountdown.value = null;
      return;
    }
    if (_attemptsTimer?.isActive ?? false) return;

    attemptsCountdown.value = refillSeconds;
    _attemptsTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = (attemptsCountdown.value ?? 1) - 1;
      if (left > 0) {
        attemptsCountdown.value = left;
      } else {
        t.cancel();
        _attemptsTimer = null;
        _refill();
      }
    });
  }

  Future<void> _refill() async {
    if (_refilling) return;
    _refilling = true;
    try {
      await DioHelper.dio.put(Endpoints.incrementAccountAttempts);
      await fetchUser();
    } catch (e) {
      Logger.Red("Failed to increment attempts: $e", name: "AuthCubit");
      await fetchUser();
    } finally {
      _refilling = false;
    }
    if (!isClosed) _syncAttemptsTimer(state); // restarts if still < 5
  }


  @override
  Future<void> fetch() async {
    await fetchUser();
  }

  void setAuthenticated(BuildContext context, User user) {
    try {
      context.setLanguage(user.languageCode);
    } catch (e) {
      Logger.Red("Failed to set locale: $e", name: "AuthCubit");
    }
    emit(Authenticated(user: user));
  }

  Future<void> decrementAccountAttempts({BuildContext? context}) async {
    final state = this.state;
    Logger.Black((state is Authenticated).toString());
    if (state is Authenticated) {
      final user = state.user;
      final oldAttempts = user.totalAttempts;
      user.totalAttempts = math.max(0, user.totalAttempts - 1);
      emit(Authenticated(user: user));
      await _accountRepository.decrementAccountAttempts();
      fetchUser();

      if (context != null && context.mounted && oldAttempts > user.totalAttempts) {
        final hasShown = CacheHelper.getHasShownHeartLossGuidance();
        if (!hasShown) {
          await CacheHelper.setHasShownHeartLossGuidance(true);
        if(context.mounted)  _showFirstHeartLossGuidance(context);
        }
      }
    }
  }

  void _showFirstHeartLossGuidance(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: context.colorScheme.surfaceContainerLow,
        shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieBuilder.asset(
              Lotties.brokenHeart,
              height: 100,
              repeat: false,
            ),
            const SizedBox(height: 12),
            Text(
              "first_heart_lost_title".tr(),
              textAlign: TextAlign.center,
              style: Omnes.w700.getStyle(fontSize: 18, color: context.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              "first_heart_lost_desc".tr(),
              textAlign: TextAlign.center,
              style: Omnes.w400.getStyle(fontSize: 14, color: context.colorScheme.onSurface),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ok".tr(), style: Omnes.w500.getStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> signOut(BuildContext context,{bool showDialog = true}) async {
    if (showDialog) {
      final result = await _showDialog(context);
      if (result) return;
    }
    DioHelper.onSignOut();
    emit(Unauthenticated());
    if(context.mounted) context.goNamed(Routes.AUTH);
  }
  Future<bool> _showDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colorScheme.surfaceContainerLow,
          shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          content: Text("are_you_sure_you_want_to_exit".tr(), style: Omnes.w700.getStyle(fontSize: 20, color: context.colorScheme.primary)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: context.colorScheme.primary),
              child: Text("no".tr(), style: Omnes.w500.getStyle(fontSize: 16)),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, false); // اختار نعم
              },
              style: FilledButton.styleFrom(foregroundColor: context.colorScheme.onError, backgroundColor: context.colorScheme.error),
              child: Text("yes".tr(), style: Omnes.w500.getStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );

    return result ?? true;
  }
  Future<void> fetchUser() async {
    final current = state;
    final userId = current is Authenticated
        ? current.user.id
        : CacheHelper.getData("user_id");
    if (userId == null || CacheHelper.getToken() == null) return;
    final result = await _userRepository.getUser(userId);

      result.fold(
        (data) {
          emit(Authenticated(user: data));
        },
        (failure) {
          Logger.Red("Failed to fetch user: $failure", name: "AuthCubit");
        },
      );
  }
  @override
  Future<void> close() {
    _attemptsTimer?.cancel();
    attemptsCountdown.dispose();
    return super.close();
  }
}

abstract class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  Authenticated({required this.user});
}

// class AuthState {
//   final User? user;
//   final bool isLoading;
//   final String? error;
//
//   const AuthState.authenticated({required this.user})
//       : error = null,
//         isLoading = false;
//
//   const AuthState.unauthenticated()
//       : user = null,
//         error = null,
//         isLoading = false;
//
//   const AuthState({
//     this.user,
//     this.error,
//     this.isLoading = false,
//   });
//
//   AuthState copyWith({
//     User? user,
//     String? error,
//     bool? isLoading,
//   }) {
//     return AuthState(
//       user: user ?? this.user,
//       error: error,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }
