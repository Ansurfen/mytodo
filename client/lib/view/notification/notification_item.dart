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
  late VoidCallback onTap;

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
          userInfo(int.parse(widget.data.param)).then((res) {
            dialog.showTextDialog(context,
                title: "application_notify".tr,
                content: Row(children: [
                  TextButton(
                      onPressed: () {
                        RouterProvider.viewUserProfile(widget.data.id);
                      },
                      child: Text(res.name,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.8)))),
                  Text("friend_request".tr)
                ]),
                onCancel: Get.back, onConfirm: () {
              if (widget.data.status != NotifyStatus.confirm.index) {
                notifyActionCommit(NotifyActionCommitRequest(
                        id: widget.data.id, status: NotifyStatus.confirm))
                    .then((value) {})
                    .onError((error, stackTrace) {
                  dialog.showError(error.toString());
                });
              }
              Get.back();
            });
          }).onError((error, stackTrace) {
            dialog.showError(error.toString());
          });
        };
      case NotifyType.text:
        typeText = "general_notify".tr;
        iconData = Icons.volume_up;
        onTap = () {
          notifyGetDetail(NotifyGetDetailRequest(id: widget.data.id))
              .then((res) {
            dialog.showBottomSheet(context, [
              Text(res.notify.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            typeText,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              Text(
                formatTimeDifference(widget.data.createdAt),
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ));
  }
}
