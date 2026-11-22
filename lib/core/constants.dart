// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:educ_core/constants/enums.dart';

class Consts {
  Consts._();

  static const Size designSize = Size(390, 822);
  static const double assistantSize = 90.0;
  static const Gender defaultGender = Gender.female;

  static const supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];
}

class Strings {
  Strings._();

  static const String appNameEn = "Banaa";
  static const String appNameAr = "بَنَّاء";

  // cache keys
  static const String token = "token";
  static const String profile = "profile";
  // add post screen
  static String groupId = "";
  static String userId = "";
  static const String logoHeroTag = "logo_hero_tag";
}

class CacheKeys {
  CacheKeys._();

  static const String guestUUID = "guest_uuid";
}
