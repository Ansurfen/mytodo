import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:my_todo/dashboard_screen.dart';
import 'package:my_todo/login_screen.dart';
import 'package:my_todo/main5.dart';
import 'package:my_todo/router/provider.dart' show RouterProvider;
import 'package:my_todo/theme/provider.dart' show ThemeProvider, TodoThemeData;
import 'package:my_todo/transition_route_observer.dart';
import 'package:my_todo/utils/db.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/notification.dart';
import 'package:my_todo/view/splash/splash_page.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Locale systemLocale = Get.deviceLocale ?? const Locale('en', 'US');
    return GetMaterialApp(
      title: 'my todo',
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      translations: I18N(),
      locale: systemLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.orange,
        ),
        // fontFamily: 'SourceSansPro',
        textTheme: TextTheme(
          displaySmall: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 45.0,
            // fontWeight: FontWeight.w400,
            color: Colors.orange,
          ),
          labelLarge: const TextStyle(
            // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
            fontFamily: 'OpenSans',
          ),
          bodySmall: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: Colors.deepPurple[300],
          ),
          displayLarge: const TextStyle(fontFamily: 'Quicksand'),
          displayMedium: const TextStyle(fontFamily: 'Quicksand'),
          headlineMedium: const TextStyle(fontFamily: 'Quicksand'),
          headlineSmall: const TextStyle(fontFamily: 'NotoSans'),
          titleLarge: const TextStyle(fontFamily: 'NotoSans'),
          titleMedium: const TextStyle(fontFamily: 'NotoSans'),
          bodyLarge: const TextStyle(fontFamily: 'NotoSans'),
          bodyMedium: const TextStyle(fontFamily: 'NotoSans'),
          titleSmall: const TextStyle(fontFamily: 'NotoSans'),
          labelSmall: const TextStyle(fontFamily: 'NotoSans'),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(secondary: Colors.orange),
      ),
      navigatorObservers: [TransitionRouteObserver()],
      initialRoute: "/auth",
      routes: {
        "splash": (context) => const SplashPage(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const HomePage(),
      },
    );
  }
}
