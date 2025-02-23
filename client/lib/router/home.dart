// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/view/home/about/about_binding.dart';
import 'package:my_todo/view/home/feedback/feedback_binding.dart';
import 'package:my_todo/view/home/home_binding.dart';
import 'package:my_todo/view/home/home_page.dart';

class HomeRouter {
  static List<TodoPage> pages = [nav, feedback, about];

  static String base(String pattern) => "/home$pattern";

  static final nav = GetPage(
      name: base('/nav'),
      page: () => const HomePage(),
      binding: HomeNavBinding());

  // static final help = GetPage(
  //     name: base('/help'),
  //     page: () => const HomePage(),
  //     binding: HelpBinding());

  static final feedback = GetPage(
      name: base('/feedback'),
      page: () => const HomePage(),
      binding: FeedbackBinding());

  static final about = GetPage(
      name: base('/about'),
      page: () => const HomePage(),
      binding: AboutBinding());
}
