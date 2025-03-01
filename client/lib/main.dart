import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:my_todo/router/provider.dart' show RouterProvider;
import 'package:my_todo/theme/provider.dart' show ThemeProvider, TodoThemeData;
import 'package:my_todo/utils/db.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/notification.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n/i18n.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  runApp(await myTodo());
}

Future<Widget> myTodo() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Guard.init();
  await Future.wait([
    DBProvider.init(),
    NotifyProvider.init(),
    Future(() => ThemeProvider.init()),
  ]);

  return OKToast(
    child: GetMaterialApp(
      title: "My Todo",
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      translations: I18N(),
      locale: Guard.initLanguage(),
      fallbackLocale: const Locale('en', 'US'),
      theme: TodoThemeData.lightTheme(),
      darkTheme: TodoThemeData.darkTheme(),
      themeMode: ThemeMode.light,
      initialRoute: RouterProvider.initialRoute(),
      getPages: RouterProvider.pages,
      defaultTransition: Transition.fade,
      unknownRoute: RouterProvider.notFoundPage,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    ),
  );
}
