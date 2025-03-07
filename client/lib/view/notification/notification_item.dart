// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/notify.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/entity/notify.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/time.dart';
import 'package:my_todo/utils/dialog.dart' as dialog;

class NotificationItem extends StatefulWidget {
  final Notify data;

  const NotificationItem({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  late String typeText;
  late IconData iconData;
  VoidCallback onTap = () {};

  @override
  void initState() {
    super.initState();
    switch (NotifyType.getType(widget.data.type)) {
      case NotifyType.unknown:
        typeText = "unknown_notify".tr;
        iconData = Icons.volume_up;
      case NotifyType.inviteFriend:
        typeText = "invite_notify".tr;
        iconData = Icons.share;
      case NotifyType.addFriend:
        typeText = "application_notify".tr;
        iconData = Icons.group;
        onTap = () {
          userInfo(int.parse(widget.data.param))
              .then((res) {
                dialog.showTextDialog(
                  context,
                  title: "application_notify".tr,
                  content: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          RouterProvider.toUserProfile(widget.data.id);
                        },
                        child: Text(
                          res.name,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Text("friend_request".tr),
                    ],
                  ),
                  onCancel: Get.back,
                  onConfirm: () {
                    if (widget.data.status != NotifyStatus.confirm.index) {
                      notifyActionCommit(
                        NotifyActionCommitRequest(
                          id: widget.data.id,
                          status: NotifyStatus.confirm,
                        ),
                      ).then((value) {}).onError((error, stackTrace) {
                        dialog.showError(error.toString());
                      });
                    }
                    Get.back();
                  },
                );
              })
              .onError((error, stackTrace) {
                dialog.showError(error.toString());
              });
        };
      case NotifyType.text:
        typeText = "general_notify".tr;
        iconData = Icons.volume_up;
        onTap = () {
          notifyGetDetail(NotifyGetDetailRequest(id: widget.data.id)).then((
            res,
          ) {
            dialog.showBottomSheet(context, [
              Text(
                res.notify.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(res.notify.content),
                ),
              ),
            ]);
          });
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(0),
        leading: badges.Badge(
          position: badges.BadgePosition.topEnd(top: -3, end: -3),
          showBadge: widget.data.status != NotifyStatus.confirm.index,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              height: 40.0,
              width: 40.0,
              color: Mock.color(),
              child: Icon(iconData, color: Colors.white, size: 32.0),
            ),
          ),
        ),
        title: const Text(
          "",
          maxLines: 1,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(typeText, overflow: TextOverflow.ellipsis, maxLines: 2),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 10),
            Text(
              formatTimeDifference(widget.data.createdAt),
              style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class Mail {
  Mail({
    required this.sender,
    required this.sub,
    required this.msg,
    required this.date,
    required this.isUnread,
  });

  String sender;
  String sub;
  String msg;
  String date;
  bool isUnread;
}

class MailTile extends StatelessWidget {
  const MailTile({
    required this.mail,
    this.showCaseDetail = false,
    this.showCaseKey,
    super.key,
  });
  final bool showCaseDetail;
  final GlobalKey<State<StatefulWidget>>? showCaseKey;
  final Mail mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 16, top: 8, bottom: 8),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SAvatarExampleChild(),
                const Padding(padding: EdgeInsets.only(left: 8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mail.sender,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              mail.isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        mail.sub,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        mail.msg,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color:
                              mail.isUnread
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
                  mail.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Icon(
                  Icons.task_alt,
                  color: mail.isUnread ? const Color(0xffFBC800) : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SAvatarExampleChild extends StatelessWidget {
  const SAvatarExampleChild({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lighten(Theme.of(context).primaryColorLight),
        ),
        child: Center(
          child: Text(
            'S',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
