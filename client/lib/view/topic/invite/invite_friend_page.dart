// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/theme/checkbox.dart';
import 'package:my_todo/view/chat/snapshot/chat_page.dart';
import 'package:my_todo/view/topic/invite/invite_friend_controller.dart';

class TopicInvitePage extends StatefulWidget {
  const TopicInvitePage({super.key});

  @override
  State<TopicInvitePage> createState() => _TopicInvitePageState();
}

class _TopicInvitePageState extends State<TopicInvitePage> {
  TopicInviteController controller = Get.find<TopicInviteController>();

  @override
  Widget build(BuildContext context) {
    return todoCupertinoScaffold(
      context: context,
      appBar: todoCupertinoNavBarWithBack(
        context,
        middle: Text(
          "invite_friend".tr,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        trailing: IconButton(
          onPressed: () {
            final selectedContacts =
                controller.contacts
                    .where((c) => controller.selectedContactIds.contains(c.id))
                    .toList();

            topicMemberInviteRequest(
              topicId: controller.id,
              userIds: selectedContacts.map((e) => int.parse(e.id!)).toList(),
            ).then((res) {
              Get.back();
            });
          },
          icon: Icon(
            Icons.send,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: Obx(
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
          itemCount: controller.contacts.length,
          itemBuilder: (BuildContext context, int index) {
            ContactInfo friend = controller.contacts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: TodoImage.userProfile(int.parse(friend.id!)),
                  radius: 25,
                ),
                contentPadding: const EdgeInsets.all(0),
                title: Text(friend.name),
                subtitle: Text(friend.about),
                trailing: Obx(() {
                  final isSelected = controller.selectedContactIds.contains(
                    friend.id,
                  );
                  return Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      controller.toggleSelection(friend.id!);
                    },
                    fillColor: CheckBoxStyle.fillColor(context),
                    shape: const CircleBorder(),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
