// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/theme/provider.dart';

typedef Language = String;

class SettingController extends GetxController {
  late bool isDark;
  final List<Language> languages = ['language.enUS', 'language.zhCN'];

  String? selectedLanguage;
  late String style;
  var settingFormKey = GlobalKey<FormState>();
  String currentLanguage = Guard.language;
  TextEditingController serverAddressController =
      TextEditingController(text: Guard.server);

  void setServer() {
    Guard.setServer(serverAddressController.text);
  }

  void unsetServer() {
    serverAddressController.text = Guard.server;
  }

  @override
  void onInit() {
    isDark = ThemeProvider.isDark;
    style = ThemeProvider.styleName;
    super.onInit();
  }

  void setDarkMode() {
    ThemeProvider.setTheme(isDark, style);
  }

  void setTheme() {
    ThemeProvider.setTheme(isDark, style);
  }

  void reset(BuildContext context) {
    ThemeProvider.setTheme(false, ThemeStyle.primary);
    Guard.resetLanguage();
    showTipDialog(context, content: 'set_save'.tr);
  }
}
