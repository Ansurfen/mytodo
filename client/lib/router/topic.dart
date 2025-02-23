// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/view/topic/detail/topic_page.dart';
import 'package:my_todo/view/topic/invite/invite_friend_page.dart';
import 'package:my_todo/view/topic/detail/topic_binding.dart';
import 'package:my_todo/view/topic/member/topic_member_binding.dart';
import 'package:my_todo/view/topic/member/topic_member_page.dart';

class TopicRouter {
  static List<TodoPage> pages = [detail, invite, member];

  static String base(String pattern) => "/topic$pattern";

  static final detail = GetPage(
      name: base('/detail'),
      page: () => const TopicPage(),
      binding: TopicBinding());

  static final invite =
      GetPage(name: base('/invite'), page: () => const TopicInvitePage());

  static final member = GetPage(
      name: base('/member'),
      page: () => const TopicMemberPage(),
      binding: TopicMemberBinding());
}
