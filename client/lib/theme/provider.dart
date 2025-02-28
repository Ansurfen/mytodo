// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/i18n/i18n.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/store.dart';

class ThemeProvider {
  static final Map<String, TodoThemeData> _data = {
    ThemeStyle.primary: TodoThemeData(0x00a1e5, 0xb6d7e4, 0x006bbb),
    ThemeStyle.success: TodoThemeData(0x04b9ae, 0xa3cac7, 0x027b77),
    ThemeStyle.info: TodoThemeData(0x8866e9, 0xb1b2d6, 0x5e38cc),
    ThemeStyle.danger: TodoThemeData(0xd251a6, 0xdab7ce, 0xbb1b85),
    ThemeStyle.warning: TodoThemeData(0xff7b52, 0xe2c5bb, 0xe55426),
    ThemeStyle.red: TodoThemeData(0xf94162, 0xF56C6C, 0xb25252),
  };

  static late bool isDark;
  static late TodoThemeData style;
  static late String styleName;

  static void init() {
    String? theme = Store.localStorage.getString("theme");
    styleName = theme ?? ThemeStyle.primary;
    TodoThemeData? td = _data[styleName];
    if (td == null) {
      style = _data[ThemeStyle.primary]!;
      styleName = ThemeStyle.primary;
    } else {
      style = td;
    }
    final bool? dark = Store.localStorage.getBool("dark");
    if (dark == null) {
      isDark = false;
    } else {
      isDark = dark;
    }
    setTheme(isDark, styleName);
  }

  static void setTheme(bool isDark, String style) {
    ThemeProvider.isDark = isDark;
    Store.localStorage.setBool("dark", isDark);
    Store.localStorage.setString('theme', style);
    late ThemeData themeData;
    if (isDark) {
      themeData = TodoThemeData._darkTheme;
    } else {
      themeData = TodoThemeData._lightTheme;
    }
    TodoThemeData? todoThemeData = _data[style];
    if (todoThemeData != null) {
      Get.changeTheme(
        themeData.copyWith(
          primaryColorLight: todoThemeData.light(),
          primaryColor: todoThemeData.normal(),
          primaryColorDark: todoThemeData.dark(),
        ),
      );
      TodoThemeData._lightTheme = TodoThemeData._lightTheme.copyWith(
        primaryColorLight: todoThemeData.light(),
        primaryColor: todoThemeData.normal(),
        primaryColorDark: todoThemeData.dark(),
      );
      TodoThemeData._darkTheme = TodoThemeData._darkTheme.copyWith(
        primaryColorLight: todoThemeData.light(),
        primaryColor: todoThemeData.normal(),
        primaryColorDark: todoThemeData.dark(),
      );
    }
  }

  static void setLightMode() {
    Store.localStorage.setBool("dark", false);
    Get.changeThemeMode(ThemeMode.light);
  }

  static void setDarkMode() {
    Store.localStorage.setBool("dark", true);
    Get.changeThemeMode(ThemeMode.dark);
  }

  static void setStyle(String s) {
    styleName = s;
    Store.localStorage.setString('theme', s);
    TodoThemeData? todoThemeData = _data[s];
    if (todoThemeData != null) {
      style = todoThemeData;
      if (isDark) {
        Get.changeTheme(
          TodoThemeData._darkTheme.copyWith(
            primaryColorLight: todoThemeData.light(),
            primaryColor: todoThemeData.normal(),
            primaryColorDark: todoThemeData.dark(),
          ),
        );
      } else {
        Get.changeTheme(
          TodoThemeData._lightTheme.copyWith(
            primaryColorLight: todoThemeData.light(),
            primaryColor: todoThemeData.normal(),
            primaryColorDark: todoThemeData.dark(),
          ),
        );
      }
    }
  }

  static Color backgroundColor() {
    if (isDark) {
      return HexColor("#1e2434");
    }
    return const Color(0xFFF2F3F8);
  }

  static Color textColor() {
    if (isDark) {
      return Colors.white;
    }
    // 0xFF253840
    return const Color(0xFF253840);
  }

  static void forEachStyle(
    void Function(String styleName, TodoThemeData data) fn,
  ) {
    _data.forEach((key, value) {
      fn(key, value);
    });
  }

  static TodoThemeData? themeData(String name) {
    return _data[name];
  }

  static bool isDarkByContext(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color plainColor(BuildContext context) {
    if (isDarkByContext(context)) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color contrastColor(
    BuildContext context, {
    Color light = Colors.white,
    Color dark = Colors.black,
  }) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }
}

class TodoThemeData {
  static ThemeData _lightTheme = ThemeData(
    useMaterial3: false,
    primaryColor: ThemeProvider.style.normal(),
    primaryColorDark: ThemeProvider.style.dark(),
    primaryColorLight: ThemeProvider.style.light(),
    fontFamily: getFontFamilyByLanguage(),
    iconTheme: IconThemeData(color: ThemeProvider.style.normal()),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ThemeProvider.style.normal(),
      selectionColor: Colors.grey.withOpacity(0.8),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.white,
      onPrimary: Color(0xFF090912),
      secondary: Colors.white70,
      onSecondary: Color(0xFF1B2339),
      error: Colors.white,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.white,
      tertiary: Colors.white38,
      onTertiary: Color(0xFF282E45),
    ),
  );
  static ThemeData _darkTheme = ThemeData(
    useMaterial3: false,
    fontFamily: getFontFamilyByLanguage(),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ThemeProvider.style.normal(),
      selectionColor: Colors.grey.withOpacity(0.8),
    ),
    iconTheme: IconThemeData(color: ThemeProvider.style.normal()),
    primaryColor: ThemeProvider.style.normal(),
    primaryColorDark: ThemeProvider.style.dark(),
    primaryColorLight: ThemeProvider.style.light(),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF090912),
      onPrimary: Colors.white,
      secondary: Color(0xFF1B2339),
      onSecondary: Colors.white70,
      error: Colors.white,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.white,
      tertiary: Color(0xFF282E45),
      onTertiary: Colors.white38,
    ),
  );
  late final Color _normal;
  late final Color _light;
  late final Color _dark;

  TodoThemeData(int n, l, d) {
    _normal = HexColor.fromInt(n);
    _light = HexColor.fromInt(l);
    _dark = HexColor.fromInt(d);
  }

  Color normal() {
    return _normal;
  }

  Color light() {
    return _light;
  }

  Color dark() {
    return _dark;
  }

  static lightTheme() {
    return _lightTheme;
  }

  static darkTheme() {
    return _darkTheme;
  }
}

abstract class ThemeStyle {
  static String primary = "primary";
  static String info = "info";
  static String success = "success";
  static String warning = "warning";
  static String danger = "danger";
  static String red = "red";
}

enum ThemeStyleName {
  primary("primary"),
  info("info"),
  success("success"),
  warning("warning"),
  danger("danger"),
  red("red");

  const ThemeStyleName(this.value);

  final String value;
}
