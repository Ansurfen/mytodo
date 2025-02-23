// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/view/notification/notification_controller.dart';
import 'package:my_todo/view/notification/notification_item.dart';

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
        body: refreshContainer(
            context: context,
            onLoad: () {},
            onRefresh: () {},
            child: FadeAnimatedBuilder(
                animation: controller.animationController,
                opacity: TodoAnimateStyle.fadeOutOpacity(
                    controller.animationController),
                child: Obx(() => ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return NotificationItem(
                          data: controller.notifications.value[index],
                        );
                      },
                      itemCount: controller.notifications.value.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 0.5,
                            width: MediaQuery.of(context).size.width / 1.3,
                            child: const Divider(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(10),
                    )))));
  }
}
