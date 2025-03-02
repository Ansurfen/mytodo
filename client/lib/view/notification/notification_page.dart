// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/notification/notification_controller.dart';
import 'package:my_todo/view/notification/notification_item.dart';
import 'package:my_todo/view/topic/snapshot/topic_page.dart'
    show SearchTextField;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationController controller = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return todoCupertinoScaffold(
      context: context,
      appBar: todoCupertinoNavBarWithBack(
        context,
        middle: Text(
          "notification".tr,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SearchTextField(fieldValue: (v) {}),
          ),
          refreshContainer(
            context: context,
            onLoad: () {},
            onRefresh: () {},
            child: FadeAnimatedBuilder(
              animation: controller.animationController,
              opacity: TodoAnimateStyle.fadeOutOpacity(
                controller.animationController,
              ),
              child: Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    // return NotificationItem(data: controller.notifications[index]);
                    return MailTile(mail: mails[index]);
                  },
                  itemCount: controller.notifications.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Divider(
                          color: ThemeProvider.contrastColor(
                            context,
                            light: Colors.grey,
                            dark: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Mail> mails = [
    Mail(
      sender: 'Medium',
      sub: 'Showcase View',
      msg: 'Check new showcase View',
      date: '1 May',
      isUnread: false,
    ),
    Mail(
      sender: 'Quora',
      sub: 'New Question for you',
      msg: 'Hi, There is new question for you',
      date: '2 May',
      isUnread: true,
    ),
    Mail(
      sender: 'Google',
      sub: 'Flutter 1.5',
      msg: 'We have launched Flutter 1.5',
      date: '3 May',
      isUnread: false,
    ),
    Mail(
      sender: 'Github',
      sub: 'Showcase View',
      msg: 'New star on your showcase view.',
      date: '4 May ',
      isUnread: true,
    ),
    Mail(
      sender: 'Simform',
      sub: 'Credit card Plugin',
      msg: 'Check out our credit card plugin',
      date: '5 May',
      isUnread: false,
    ),
    Mail(
      sender: 'Flutter',
      sub: 'Flutter is Future',
      msg: 'Flutter launched for Web',
      date: '6 May',
      isUnread: true,
    ),
    Mail(
      sender: 'Medium',
      sub: 'Showcase View',
      msg: 'Check new showcase View',
      date: '7 May ',
      isUnread: false,
    ),
    Mail(
      sender: 'Simform',
      sub: 'Credit card Plugin',
      msg: 'Check out our credit card plugin',
      date: '8 May',
      isUnread: true,
    ),
    Mail(
      sender: 'Flutter',
      sub: 'Flutter is Future',
      msg: 'Flutter launched for Web',
      date: '9 May',
      isUnread: false,
    ),
  ];
}
