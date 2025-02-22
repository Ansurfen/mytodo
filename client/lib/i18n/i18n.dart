import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';
import 'package:my_todo/i18n/zh_cn.dart';
import 'package:my_todo/i18n/en_us.dart';

class I18N extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'zh_CN': zhCN};
}

Locale getCurZone() {
  Locale curLocal = ui.window.locale;
  if (kDebugMode) {
    print(curLocal.languageCode);
  }
  return curLocal.languageCode == 'zh'
      ? const Locale('zh', 'CN')
      : const Locale('en', 'US');
}

String? getFontFamilyByLanguage() {
  Locale curLocal = ui.window.locale;
  return curLocal.languageCode == 'zh' ? null : 'AverageSans';
}
