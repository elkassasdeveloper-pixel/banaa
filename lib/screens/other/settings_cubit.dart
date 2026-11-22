import 'dart:convert';

import 'package:educ_core/data/models/account_preferences.dart';
import 'package:educ_core/data/repositories/account_repository.dart';
import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/extensions.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/data_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    reminderTime = reminderTimes.first;

    if (DioHelper.token != null) {
      fetchPreferences();
    }
  }

  String? greetMessage; // لتخزين الرسالة الأخيرة
  String fixUtf8(String garbled) {
    final bytes = garbled.runes.toList();
    return utf8.decode(bytes);
  }

  void updateGreetMessage(String message) {
    greetMessage = fixUtf8(message);
    emit(SettingsChanged());
  }




  final _accountRepository = AccountRepository();
  final List<TimeOfDay> _reminderTimes = const [
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
  ];

  AccountPreferences prefs = AccountPreferences.def();
  ThemeMode _themeMode = ThemeMode.light;
  late TimeOfDay reminderTime;

  final refreshIndicator = GlobalKey<RefreshIndicatorState>();

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  List<TimeOfDay> get reminderTimes => _reminderTimes;

  void setDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    prefs.isDarkThemed = value;
    emit(SettingsChanged());
  }

  Future<void> fetchPreferences({bool delayed = false}) async {
    if (delayed) {
      doPostFrame((_) {
        fetchPreferences(delayed: false);
      });
    }

    emit(SettingsLoading());

    final result = await _accountRepository.getPreferences();

    result.fold((data) {
      prefs = data;
      emit(SettingsLoaded());
    }, (failure) => emit(SettingsError(failure)));
  }

  void setLanguage(String code) {
    prefs.languageCode = code;
    emit(SettingsChanged());
  }

  void setStudyReminders(bool value) {
    prefs.isStudyingNotificationEnabled = value;
    emit(SettingsChanged());
  }

  void setCommunityReminders(bool value) {
    prefs.isCommunityNotificationEnabled = value;
    emit(SettingsChanged());
  }

  void setReminderTime(TimeOfDay value) {
    reminderTime = value;
    emit(SettingsChanged());
  }

  void setSoundEffects(bool value) {
    prefs.isSoundFXEnabled = value;
    emit(SettingsChanged());
  }

  void setMotivationalMessages(bool value) {
    prefs.isMotivationalMessageEnabled = value;
    emit(SettingsChanged());
  }

  void setPermissionsToSeeCorrect(bool value) {
    CacheHelper.setPermissionsToSeeCorrect(value);
    emit(SettingsChanged());
  }

  Future<void> saveChanges() async {
    // prefs.assistantId = '5';///TODO
    emit(SettingsLoading());

    final result = await _accountRepository.updatePreferences(prefs);
    result.fold((data) => emit(SettingUpdateSuccess()), (failure) => emit(SettingsError(failure)));
  }

  // Future<void> sendMailDirectly() async {
  //   final smtpServer = gmail('banaa.app.info@gmail.com', 'xqxd doxy qaez gkec'); // Use App Password!
  //
  //   final message = Message()
  //     ..from = Address('banaa.app.info@gmail.com', 'Banaa')
  //     ..recipients.add('ahmed.ebrahim.5115@gmail.com')
  //     ..subject = 'Test Subject'
  //     ..text = 'Hello, this is a test email from Flutter app.';
  //
  //   try {
  //     final sendReport = await send(message, smtpServer);
  //     print('Message sent successfully to: ${message.recipients}');
  //     print('Message sent: $sendReport');
  //   } catch (e) {
  //     print('Message not sent. $e');
  //   }
  // }

  void applyPreferences(BuildContext context) {
    setDarkMode(prefs.isDarkThemed);
    try {
      doPostFrame((_) {
        context.setLanguage(prefs.languageCode);
        DataCubit.onLanguageChanged();
      });
    } catch (e) {
      Logger.Red("Failed to set locale: $e", name: "SettingsCubit");
    }
  }
}

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {}

class SettingsChanged extends SettingsState {}

class SettingUpdateSuccess extends SettingsState {}

class SettingsError extends SettingsState {
  final Failure failure;

  SettingsError(this.failure);
}
