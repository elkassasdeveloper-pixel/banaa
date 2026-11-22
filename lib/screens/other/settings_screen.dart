import 'package:educ_core/educ_core.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/services/log_file.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:educ_student/core/assets.dart';
import 'package:educ_student/core/helpers.dart';
import 'package:educ_student/core/routes.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:educ_student/screens/auth/auth_cubit.dart';
import 'package:educ_student/screens/other/settings_cubit.dart';
import 'package:educ_student/widgets/back_arrow_button.dart';
import 'package:educ_student/widgets/custom_dropdown.dart';
import 'package:educ_student/widgets/gradiant_screen.dart';
import 'package:educ_student/widgets/banaa_button.dart';
import 'package:educ_student/widgets/loading_indicator.dart';
import 'package:educ_student/widgets/theme_mode_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();


    // LoadingIndicator.show(context, () => cubit.fetchPreferences(delayed: true));

    return BlocProvider.value(
      value: cubit,
      child: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          final cubit = context.read<SettingsCubit>();
          if (state is SettingsError) {
            context.showFailureSnackBar(state.failure);
          } else if (state is SettingUpdateSuccess) {
            doPostFrame((_) {
              context.setLanguage(cubit.prefs.languageCode);
              DataCubit.onLanguageChanged();
            });
            context.showSuccessSnackBar("save_success".tr());
          }
        },
        builder: (context, state) {
          return GradiantScreen(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  "settings".tr(),
                  style: Omnes.w400.getStyle(color: context.colorScheme.primary, fontSize: 18.0),
                ),
                leading: const BackArrowButton(),
                actions: [
                  IconButton(
                    onPressed: () => context.read<AuthCubit>().signOut(context),
                    style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
                    icon: const Icon(Icons.logout),
                    tooltip: 'logout'.tr(),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _Header(title: "account".tr(), iconPath: Svgs.profileSettings),
                        ...() {
                          if (DioHelper.token!.role != "Guest") {
                            return [
                              _Tile(
                                title: "edit_profile".tr(),
                                onPressed: () {
                                  context.goNamed(Routes.EDITPROFILE);
                                },
                              ),
                              _Tile(
                                title: "change_password".tr(),
                                onPressed: () {
                                  context.goNamed(Routes.CHANGEPASSWORD);
                                },
                              ),
                            ];
                          } else {
                            return [
                              _Tile(
                                title: "link_account".tr(),
                                onPressed: () {
                                  context.goNamed(Routes.LINK_ACCOUNT);
                                },
                              ),
                            ];
                          }
                        }(),
                        _Tile(
                          title: "edit_profile_picture".tr(),
                          onPressed: () {
                            context.goNamed(Routes.EditAvatar);
                          },
                        ),
                        // const SizedBox(height: 16),
                        // _Header(title: "notifications".tr(),
                        //     iconPath: Svgs.notificationSettings),
                        // _SwitchTile(
                        //   title: "study_reminders".tr(),
                        //   value: cubit.prefs.isStudyingNotificationEnabled,
                        //   onChanged: cubit.setStudyReminders,
                        // ),
                        // _SwitchTile(
                        //   title: "community_reminders".tr(),
                        //   value: cubit.prefs.isCommunityNotificationEnabled,
                        //   onChanged: cubit.setCommunityReminders,
                        // ),
                        /*  _DropdownButtonTile(
                          title: "reminder_time".tr(),
                          dropdown: CustomDropdown(
                            value: cubit.reminderTime,
                            items: cubit.reminderTimes,
                            itemBuilder: (item) {
                              return Text(item.format(context));
                            },
                            onChanged: (value) {
                              if (value != null) {
                                cubit.setReminderTime(value);
                              }
                            },
                          ),
                        ),*/
                        const SizedBox(height: 16),
                        _Header(title: "general_settings".tr(), iconPath: Svgs.generalSettings),
                        ThemeModeSwitch.tile(
                          title: _Tile.buildTitle(context, "theme_mode".tr()),
                          isDark: cubit.isDarkMode,
                          onChanged: cubit.setDarkMode,
                        ),
                        // _SwitchTile(
                        //   title: "sound_effects".tr(),
                        //   value: cubit.prefs.isSoundFXEnabled,
                        //   onChanged: cubit.setSoundEffects,
                        // ),
                        // _SwitchTile(
                        //   title: "motivational_messages".tr(),
                        //   value: cubit.prefs.isMotivationalMessageEnabled,
                        //   onChanged: cubit.setMotivationalMessages,
                        // ),
                        _SwitchTile(
                          title: "show_correct_answers".tr(),
                          value: CacheHelper.getPermissionsToSeeCorrect() ?? false,
                          onChanged: cubit.setPermissionsToSeeCorrect,
                        ),
                        _DropdownButtonTile(
                          title: "language".tr(),
                          dropdown: CustomDropdown(
                            value: context.locale,
                            items: context.supportedLocales,
                            itemBuilder: (item) {
                              return Text(localeToLanguageName(item).tr());
                            },
                            onChanged: (value) {
                              if (value != null) {
                                cubit.setLanguage(value.languageCode);
                              }
                            },
                          ),
                        ),

                        Text(
                          "      ${"version".tr()}   1.0.45",
                          style: Omnes.w500.getStyle(
                            color: context.colorScheme.primary,
                            fontSize: 16.0,
                          ),
                        ),
if(kDebugMode)
                        _Tile(
                          title: "view_notification_history".tr(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LogViewerPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BanaaButton(
                          isEnabled: state is! SettingsLoading,
                          label: "save".tr(),
                          // onPressed: () => cubit.sendMailDirectly(),
                          onPressed: () async {
                            _showLoadingDialog(
                              context,
                              invocation: cubit.saveChanges,
                              message: "saving_changes".tr(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLoadingDialog(
    BuildContext context, {
    required Future Function() invocation,
    String? message,
  }) async {
    BuildContext popContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        popContext = context;
        return LoadingIndicator(message: message);
      },
    );

    await invocation().then((_) {
      if(context.mounted)   Navigator.pop(popContext);
    });
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String iconPath;

  const _Header({required this.title, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Omnes.w700.getStyle(color: context.colorScheme.primary, fontSize: 20),
      ),
      leading: SizedBox.square(
        dimension: 32.0,
        child: SvgPicture.asset(
          iconPath,
          // colorFilter: context.colorScheme.primary.toColorFilter(),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const _Tile({required this.title, required this.onPressed});

  static Widget buildTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Omnes.w500.getStyle(color: context.colorScheme.primary, fontSize: 16.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: buildTitle(context, title),
      onTap: onPressed,
      trailing: SvgPicture.asset(
        Svgs.forwardArrow,
        colorFilter: context.colorScheme.primary.toColorFilter(),
        matchTextDirection: true,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: _Tile.buildTitle(context, title),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _DropdownButtonTile<T> extends StatelessWidget {
  final String title;
  final CustomDropdown dropdown;

  const _DropdownButtonTile({required this.title, required this.dropdown});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title.tr(),
        style: Omnes.w500.getStyle(color: context.colorScheme.primary, fontSize: 16.0),
      ),
      trailing: IntrinsicWidth(child: dropdown),
    );
  }
}


class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  String? logContent;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _loadLogFile() async {
    setState(() {
      isLoading = true;
      logContent = null;
    });

    try {
      final content = await LogFileService.readLog();

      if (mounted) {
        setState(() {
          logContent = content ?? "⚠️ الملف غير موجود بعد!";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          logContent = "❌ حصل خطأ أثناء قراءة الملف:\n$e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _clearLogFile() async {
    try {
      await LogFileService.clearLog();

      if (mounted) {
        setState(() {
          logContent = "🧹 تم مسح محتوى الملف بنجاح!";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          logContent = "❌ فشل مسح الملف: $e";
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _loadLogFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📄 عرض سجل الخلفية"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "تحديث",
            onPressed: _loadLogFile,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "مسح الملف",
            onPressed: _clearLogFile,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {}, // يسمح بالسحب بدون تعارض مع SelectableText
            behavior: HitTestBehavior.translucent,
            child: Text(
              logContent ?? "لم يتم تحميل أي بيانات بعد",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
