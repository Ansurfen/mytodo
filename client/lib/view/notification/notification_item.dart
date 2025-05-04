// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/model/entity/notify.dart';
import 'package:my_todo/utils/time.dart';

class NotificationItemModel {
  NotificationItemModel({
    required this.id,
    required this.sender,
    required this.sub,
    required this.msg,
    required this.date,
    required this.readed,
    required this.type,
    required this.uid,
  });

  int id;
  String sender;
  String sub;
  String msg;
  DateTime date;
  bool readed;
  int type;
  int uid;
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    required this.model,
    this.showCaseDetail = false,
    this.showCaseKey,
    super.key,
  });
  final bool showCaseDetail;
  final GlobalKey<State<StatefulWidget>>? showCaseKey;
  final NotificationItemModel model;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        List<Widget> actions = [];
        String message = "${model.sender} 申请添加你为好友";
        switch (NotifyType.values[model.type]) {
          case NotifyType.unknown:
            throw UnimplementedError();
          case NotifyType.addFriend:
            actions =
                actions = <CupertinoActionSheetAction>[
                  CupertinoActionSheetAction(
                    isDefaultAction: true,
                    onPressed: () {
                      userFriendCommit(
                        notificationId: model.id,
                        pass: true,
                      ).then((_) => Get.back());
                    },
                    child: Text(
                      'confirm'.tr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      userFriendCommit(
                        notificationId: model.id,
                        pass: false,
                      ).then((_) => Get.back());
                    },
                    child: Text('reject'.tr),
                  ),
                ];
          case NotifyType.inviteFriend:
            message = "${model.sender} 邀请你加入 ${model.msg} 频道";
            actions = <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  topicMemberCommitRequest(
                    notificationId: model.id,
                    pass: true,
                  ).then((_) => Get.back());
                },
                child: Text(
                  'confirm'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  topicMemberCommitRequest(
                    notificationId: model.id,
                    pass: false,
                  ).then((_) => Get.back());
                },
                child: Text('reject'.tr),
              ),
            ];
          case NotifyType.text:
            throw UnimplementedError();
          case NotifyType.topicApply:
            message = "${model.sender} 申请加入 ${model.msg} 频道";
            actions = <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  topicApplyCommitRequest(
                    notificationId: model.id,
                    pass: true,
                  ).then((_) => Get.back());
                },
                child: Text(
                  'confirm'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  topicApplyCommitRequest(
                    notificationId: model.id,
                    pass: false,
                  ).then((_) => Get.back());
                },
                child: Text('reject'.tr),
              ),
            ];
        }
        if (model.readed) {
          Get.snackbar(
            'notification_commit'.tr,
            'notification_commit_finish'.tr,
          );
        } else {
          showCupertinoModalPopup<void>(
            context: context,
            builder:
                (BuildContext context) => CupertinoActionSheet(
                  title: Text(model.sub),
                  message: Text(message),
                  actions: actions,
                ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 16, top: 8, bottom: 8),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SAvatarExampleChild(id: model.uid),
                  const Padding(padding: EdgeInsets.only(left: 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.sender,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                model.readed
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          model.sub,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          model.msg,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color:
                                model.readed
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    formatTimeDifference(model.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.task_alt,
                    color: model.readed ? const Color(0xffFBC800) : Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SAvatarExampleChild extends StatelessWidget {
  final int id;
  const SAvatarExampleChild({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: TodoImage.userProfile(id),
      ),
    );
  }
}
