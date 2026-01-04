import 'dart:ui';

import 'package:coach_life/utils/lang/arabic.dart';
import 'package:coach_life/utils/lang/english.dart';
import 'package:get/get.dart';

class TranslationManager extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en': English.translations,
    'ar': Arabic.translations
  };

  static List<Locale> supportedLocales = [
    const Locale('en'),
    const Locale('ar')
  ];

}