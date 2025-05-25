// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/config.dart';
import 'package:my_todo/i18n/i18n.dart';
import 'package:my_todo/model/entity/user.dart';
import 'package:my_todo/router/home.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/user.dart';
import 'package:my_todo/utils/file.dart';
import 'package:my_todo/utils/io/dir.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/utils/store.dart';

import 'logger.dart';

class Guard {
  static late String language;
  static late String _server;
  static User? u;
  static EventBus eventBus = EventBus();
  static late Logger log;

  static void setUser(User user) {
    u = user;
    Store.localStorage.setString("user", jsonEncode(user));
  }

  static User? getUser() {
    if (u != null) {
      return u!;
    }
    String? userStr = Store.localStorage.getString("user");
    if (userStr != null && userStr.isNotEmpty) {
      u = User.fromJson(jsonDecode(userStr));
    }
    return u;
  }

  static String userName() {
    if (u != null) {
      return u!.name;
    }
    String? userStr = Store.localStorage.getString("user");
    if (userStr != null && userStr.isNotEmpty) {
      try {
        u = User.fromJson(jsonDecode(userStr));
        return u!.name;
      } catch (e) {}
    }
    return "";
  }

  static String userTelephone() {
    if (u != null && u!.telephone != null) {
      return u!.telephone!;
    }
    String? userStr = Store.localStorage.getString("user");
    if (userStr != null && userStr.isNotEmpty) {
      try {
        u = User.fromJson(jsonDecode(userStr));
        return u!.telephone!;
      } catch (e) {}
    }
    return "";
  }

  static String userEmail() {
    if (u != null) {
      return u!.email;
    }
    String? userStr = Store.localStorage.getString("user");
    if (userStr != null && userStr.isNotEmpty) {
      try {
        u = User.fromJson(jsonDecode(userStr));
        return u!.email;
      } catch (e) {}
    }
    return "";
  }

  static int get user {
    if (!isLogin()) {
      return -1;
    }
    var user = getUser();
    if (user != null) {
      return u!.id;
    }
    return -1;
  }

  static Future init() async {
    await Store.init();
    String? s = Store.localStorage.getString('server');
    if (s != null) {
      _server = s;
    } else {
      _server = TodoConfig.baseUri;
    }
    final dir = await getApplicationCacheDirectory();
    late File file;
    if (kIsWeb) {
      file = RWFile("${dir.path}/logs.txt");
    } else {
      file = File("${dir.path}/logs.txt");
    }
    log = Logger(filter: LoggerFilter(), output: TodoFileOutput(file));
  }

  static void offlineLogin() {
    Store.localStorage.setBool("offline", true);
  }

  static void offlineLoginAndGo() {
    Guard.offlineLogin();
    RouterProvider.offNamed(HomeRouter.nav);
  }

  static bool isDevMode() {
    return isOffline();
  }

  static bool isOffline() {
    if (isLogin()) {
      Store.localStorage.setBool("offline", false);
      return false;
    }
    final bool? offline = Store.localStorage.getBool('offline');
    if (offline == null) {
      return false;
    }
    return offline;
  }

  static bool isLogin() {
    final String? jwt = Store.localStorage.getString('jwt');
    if (jwt != null && jwt.isNotEmpty) {
      return true;
    }
    return false;
  }

  static void logIn(String jwt) {
    Store.localStorage.setString('jwt', jwt);
  }

  static void logInAndGo(String jwt) {
    Guard.logIn(jwt);
    userDetailRequest().then((v) {
      Guard.setUser(v);
    });
    RouterProvider.offNamed(HomeRouter.nav);
  }

  static void logOut() {
    Store.localStorage.setString('jwt', '');
  }

  static void logOutAndGo() {
    Guard.logOut();
    RouterProvider.offNamed(UserRouter.sign);
  }

  static bool isFirstVisit() {
    final bool? splash = Store.localStorage.getBool('visit');
    if (splash == null) {
      Store.localStorage.setBool('visit', true);
      return true;
    }
    return false;
  }

  static void isNotLoginAndReturn() {
    if (!Guard.isLogin()) {
      RouterProvider.offNamed(UserRouter.sign);
    }
  }

  static void setLanguage(String locale) {
    switch (locale) {
      case 'language_zhCN':
        _setLocale('zh', 'CN');
        language = locale;
        Get.updateLocale(const Locale('zh'));
      default:
        _setLocale('en', 'US');
        language = 'language_enUS';
        Get.updateLocale(const Locale('en'));
    }
  }

  static void resetLanguage() {
    Locale locale = getCurZone();
    _setLocale(locale.languageCode, locale.countryCode!);
  }

  static void _setLocale(String l, c) {
    Store.localStorage.setString('languageCode', l);
    Store.localStorage.setString('countryCode', c);
  }

  static Locale initLanguage() {
    String? languageCode = Store.localStorage.getString('languageCode');
    String? countryCode = Store.localStorage.getString('countryCode');
    late Locale locale;
    if (languageCode == null || countryCode == null) {
      locale = getCurZone();
    } else {
      locale = Locale(languageCode, countryCode);
    }
    language = "language_${locale.languageCode}${locale.countryCode}";
    return locale;
  }

  static void setServer(String s) {
    _server = s;
    HTTP.setBaseUrl(s);
    Store.localStorage.setString('server', s);
  }

  static String get server {
    return _server;
  }

  static String get jwt {
    String? token = Store.localStorage.getString("jwt");
    if (token != null) {
      return "Bearer $token";
    }
    return "";
  }

  static set jwt(String v) {
    Store.localStorage.setString("jwt", v);
  }
}
