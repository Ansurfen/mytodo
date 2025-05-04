// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/component/icon.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/component/refresh.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/mock/chat.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/model/topic.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/view/topic/member/topic_member_controller.dart';

class TopicMemberPage extends StatefulWidget {
  const TopicMemberPage({super.key});

  @override
  State<TopicMemberPage> createState() => _TopicMemberPageState();
}

class _TopicMemberPageState extends State<TopicMemberPage> {
  TopicMemberController controller = Get.find<TopicMemberController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: todoAppBar(
        context,
        leading: todoLeadingIconButton(
          context,
          onPressed: Get.back,
          icon: Icons.arrow_back_ios,
        ),
        title: Text("member".tr),
        elevation: 0,
        actions: [
          notificationWidget(context, controller.unreadCount.value),
          const SizedBox(width: 15),
          settingWidget(),
          const SizedBox(width: 15),
          IconButton(
            onPressed: () {
              RouterProvider.viewTopicInvite(controller.id);
            },
            icon: const Icon(Icons.share),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: refreshContainer(
        context: context,
        onRefresh: () {},
        onLoad: () {},
        child: Obx(
          () => ListView.separated(
            padding: const EdgeInsets.all(10),
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
            itemCount: controller.members.value.length,
            itemBuilder: (BuildContext context, int index) {
              Map friend = friends[index];
              TopicMember member = controller.members.value[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: TodoImage.userProfile(member.id),
                    radius: 25,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    member.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(friend['status']),
                  trailing: IconButton(
                    onPressed:
                        () => userActions(
                          TopicRole.values[member.role],
                          member.id,
                        ),
                    icon: const Icon(Icons.more_vert),
                  ),
                  onTap: () {
                    RouterProvider.toUserProfile(member.id);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _addFriend(int memberId) {
    userFriendNewRequest(
      friendId: memberId,
    ).then((v) => Get.snackbar("add_friend".tr, "success_add_friend".tr));
    Get.back();
  }

  void userActions(TopicRole perm, int memberId) {
    final currentUserId = Guard.u!.id;
    final isSelf = currentUserId == memberId;
    final currentUserRole = controller.role.value;

    List<Widget> actions = [];
    if (!isSelf) {
      actions.add(
        dialogAction(
          icon: Icons.add,
          text: "add_friend".tr,
          onTap: () => _addFriend(memberId),
        ),
      );
    }

    switch (currentUserRole) {
      case TopicRole.owner:
        if (isSelf) {
          // 所有者解散频道
          actions.addAll([
            dialogAction(
              icon: Icons.delete_forever,
              text: "disband_topic".tr,
              onTap: () {
                Navigator.of(context).pop();
                showAlert(
                  context,
                  title: "disband_topic".tr,
                  content: "disband_topic_desc".tr,
                  onConfirm: () {
                    topicDisbandRequest(topicId: controller.id).then((v) {
                      Get.snackbar(
                        "disband_topic".tr,
                        "success_disband_topic".tr,
                      );
                      Get.back();
                      Get.back();
                    });
                  },
                );
              },
            ),
          ]);
        } else {
          // 所有者对其他成员的操作
          actions.addAll([
            if (perm == TopicRole.member) ...[
              const Divider(),
              dialogAction(
                icon: Icons.admin_panel_settings,
                text: "grant_admin".tr,
                onTap: () {
                  Navigator.of(context).pop();
                  topicMemberGrantAdminRequest(
                    topicId: controller.id,
                    userId: memberId,
                  ).then((v) {
                    Get.snackbar("grant_admin".tr, "success_grant_admin".tr);
                    controller.fetchMembers();
                  });
                },
              ),
            ] else if (perm == TopicRole.admin) ...[
              const Divider(),
              dialogAction(
                icon: Icons.admin_panel_settings,
                text: "revoke_admin".tr,
                onTap: () {
                  Navigator.of(context).pop();
                  topicMemberRevokeAdminRequest(
                    topicId: controller.id,
                    userId: memberId,
                  ).then((v) {
                    Get.snackbar("revoke_admin".tr, "success_revoke_admin".tr);
                    controller.fetchMembers();
                  });
                },
              ),
            ],
            const Divider(),
            dialogAction(
              icon: Icons.delete,
              text: "remove_member".tr,
              onTap: () {
                Navigator.of(context).pop();
                showAlert(
                  context,
                  title: "remove_member".tr,
                  content: "remove_member_desc".tr,
                  onConfirm: () {
                    topicMemberRemoveRequest(
                      topicId: controller.id,
                      userId: memberId,
                    ).then((v) {
                      Get.snackbar(
                        "remove_member".tr,
                        "success_remove_member".tr,
                      );
                      controller.fetchMembers();
                    });
                  },
                );
              },
            ),
          ]);
        }
        break;
      case TopicRole.admin:
        if (!isSelf && perm == TopicRole.member) {
          // 管理员可以移除普通成员
          actions.addAll([
            const Divider(),
            dialogAction(
              icon: Icons.delete,
              text: "remove_member".tr,
              onTap: () {
                Navigator.of(context).pop();
                showAlert(
                  context,
                  title: "remove_member".tr,
                  content: "remove_member_desc".tr,
                  onConfirm: () {
                    topicMemberRemoveRequest(
                      topicId: controller.id,
                      userId: memberId,
                    ).then((v) {
                      Get.snackbar(
                        "remove_member".tr,
                        "success_remove_member".tr,
                      );
                      controller.fetchMembers();
                    });
                  },
                );
              },
            ),
          ]);
        } else {
          // 管理员对自己或其他管理员的操作
        }
        break;
      case TopicRole.member:
        // 普通成员只能添加好友和退出频道
        if (isSelf) {
          actions = [
            dialogAction(
              icon: Icons.exit_to_app,
              text: "exit_topic".tr,
              onTap: () {
                Navigator.of(context).pop();
                showAlert(
                  context,
                  title: "exit_topic".tr,
                  content: "exit_topic_desc".tr,
                  onConfirm: () {
                    topicExitRequest(topicId: controller.id).then((v) {
                      Get.back();
                      Get.snackbar("exit_topic".tr, "success_exit_topic".tr);
                    });
                  },
                );
              },
            ),
          ];
        }
        break;
    }

    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            message: Column(mainAxisSize: MainAxisSize.min, children: actions),
          ),
    );
  }
}
