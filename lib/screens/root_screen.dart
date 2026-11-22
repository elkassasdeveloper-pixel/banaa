import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:educ_student/core/routes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    _onAppLaunch(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          Svgs.banaaLogo,
        ),
      ),
    );
  }
}

Future<void> _onAppLaunch(BuildContext context) async {
  try {
    final isFirstRun = CacheHelper.getIsFirstRun();

    if (!isFirstRun) {
      final token = DioHelper.token;

      if (token != null) {
        Logger.Green(
          "Token found. Proceeding to fetch current user",
          name: "onAppLaunch",
        );
        final result = await fetchCurrentUser();
        result.fold(
          (user) {
            onAuthenticated(context, user);
          },
          (failure) {
            Logger.Red(
              "Failed to fetch current user, error: ${failure.failureCode.tr()}",
              name: "onAppLaunch",
            );
            Logger.Cyan("Proceeding to auth screen", name: "onAppLaunch");
            context.replaceNamed(Routes.AUTH);
          },
        );
      } else {
        doPostFrame((_) => context.replaceNamed(Routes.AUTH));
      }
    } else {
      doPostFrame((_) => context.replaceNamed(Routes.ON_BOARDING));
    }
  } catch (e) {
    // log("error on app launch", name: "onAppLaunch", error: e);
    doPostFrame((_) => context.replaceNamed(Routes.AUTH));
  }
}
