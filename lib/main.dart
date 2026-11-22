import 'dart:io';
import 'dart:ui';

import 'package:educ_core/educ_core.dart';
import 'package:educ_core/utils/env.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_student/core/constants.dart';
import 'package:educ_student/core/dark_app_theme.dart';
import 'package:educ_student/core/go_router.dart';
import 'package:educ_student/core/light_app_theme.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/auth/login_cubit.dart';
import 'package:educ_student/screens/auth/sign_up_cubit.dart';
import 'package:educ_student/screens/other/settings_cubit.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workmanager/workmanager.dart';

import 'background_notification_worker.dart';
import 'notification_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppDependencies(environment: kDebugMode ? DebugEnv() : ProductionEnv());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final deviceLocale = PlatformDispatcher.instance.locale;
  Logger.data("Device Locale", deviceLocale);
  // final appLifecycleHandler = AppLifecycleHandler();
  // WidgetsBinding.instance.addObserver(appLifecycleHandler);
  debugPrint('step: ${DateTime.now().toString()}  001');
  debugPrint('step: ${DateTime.now().toString()}  002');
  if(!kIsWeb) {
    await NotificationService().initNotification();
  }
  debugPrint('step: ${DateTime.now().toString()}  003');
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    debugPrint('step: ${DateTime.now().toString()}  004');
    await Workmanager().initialize(backgroundNotificationDispatcher);
    debugPrint('step: ${DateTime.now().toString()}  005');
    await Workmanager().registerPeriodicTask(
      "fetch_notifications_${DateTime.now().millisecondsSinceEpoch}",
      workManagerTaskKey,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresCharging: false,
        requiresBatteryNotLow: false,
        requiresStorageNotLow: false,
      ),
    );
    debugPrint('step: ${DateTime.now().toString()}  006');
  } else {
    debugPrint("⚠️ Workmanager is disabled for this platform.");
  }
  debugPrint('step: ${DateTime.now().toString()}  007');

  runApp(
    EasyLocalization(
      useOnlyLangCode: true,
      path: "assets/translations",
      supportedLocales: Consts.supportedLocales,
      startLocale: Locale('ar'),
      saveLocale: false,
      fallbackLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      debugPrint('step: ${DateTime.now().toString()}  008');
      await NotificationService().requestNotificationPermission();
      debugPrint('step: ${DateTime.now().toString()}  009');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final List<BlocProvider> _providers = [
    BlocProvider<AuthCubit>(create: (context) => AuthCubit()..fetch(), lazy: false),
    BlocProvider<SettingsCubit>(create: (context) => SettingsCubit(), lazy: false),
    BlocProvider<LoginCubit>(create: (context) => LoginCubit(), lazy: true),
    BlocProvider<SignUpCubit>(create: (context) => SignUpCubit(), lazy: true),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _providers,
      child: ScreenUtilInit(
        designSize: Consts.designSize,
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            final cubit = context.read<SettingsCubit>();
            if (state is SettingsLoaded) {
              cubit.applyPreferences(context);
            }
          },
          builder: (context, state) {
            final cubit = context.read<SettingsCubit>();
            return MaterialApp.router(
              routerConfig: AppRouter.goRouter,
              title: Strings.appNameAr,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: [
                FlutterQuillLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
                ...context.localizationDelegates,
              ],
              debugShowCheckedModeBanner: false,
              theme: LightAppTheme().themeData,
              darkTheme: DarkAppTheme().themeData,
              themeMode: cubit.themeMode,
              builder: (context, widget) {
                return ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
                    physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  ),
                  child: widget ?? const SizedBox(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
