// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/view/chat/conversation/conversion_binding.dart';
import 'package:my_todo/view/chat/conversation/conversion_page.dart';
import 'package:my_todo/view/add/add_binding.dart';
import 'package:my_todo/view/add/add_page.dart';
import 'package:my_todo/view/home/log/log_binding.dart';
import 'package:my_todo/view/home/log/log_page.dart';
import 'package:my_todo/view/post/detail/post_detail_binding.dart';
import 'package:my_todo/view/post/detail/post_detail_page.dart';
import 'package:my_todo/view/setting/setting_binding.dart';
import 'package:my_todo/view/setting/setting_page.dart';
import 'package:my_todo/view/splash/splash_binding.dart';
import 'package:my_todo/view/splash/splash_page.dart';
// import 'package:my_todo/view/statistic/statistic_page.dart';
import 'package:my_todo/view/notification/notification_binding.dart';
import 'package:my_todo/view/notification/notification_page.dart';
import 'package:my_todo/view/photo/photo_page.dart';

class OtherRouter {
  static List<GetPage> pages = [
    splash,
    setting,
    // statistic,
    add,
    photo,
    notification,
    post,
    conversation,
    log
  ];

  static final log =
      GetPage(name: '/log', page: () => const LogPage(), binding: LogBinding());

  static final splash = GetPage(
      name: '/splash',
      page: () => const SplashPage(),
      binding: SplashBinding());

  static final setting = GetPage(
      name: '/setting',
      page: () => const SettingPage(),
      binding: SettingBinding());

  // static final statistic =
  //     GetPage(name: '/statistic', page: () => const StatisticPage());

  static final add =
      GetPage(name: '/add', page: () => const AddPage(), binding: AddBinding());

  static final photo = GetPage(name: '/photo', page: () => const PhotoPage());

  static final notification = GetPage(
      name: '/notification',
      page: () => const NotificationPage(),
      binding: NotificationBinding());

  static final post = GetPage(
      name: '/post',
      page: () => const PostDetailPage(),
      binding: PostDetailPageBinding());

  static final conversation = GetPage(
      name: '/conversation',
      page: () => const Conversation(),
      binding: ConversionBinding());
}
