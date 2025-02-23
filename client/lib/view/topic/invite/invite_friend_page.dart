// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/mock/chat.dart';
import 'package:my_todo/theme/checkbox.dart';

class TopicInvitePage extends StatefulWidget {
  const TopicInvitePage({super.key});

  @override
  State<TopicInvitePage> createState() => _TopicInvitePageState();
}

class _TopicInvitePageState extends State<TopicInvitePage> {
  @override
  Widget build(BuildContext context) {
    return todoCupertinoScaffold(
        context: context,
        appBar: todoCupertinoNavBarWithBack(context,
            middle: Text(
              "invite_friend".tr,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            trailing: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.send,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ))),
        body: ListView.separated(
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
          itemCount: friends.length,
          itemBuilder: (BuildContext context, int index) {
            Map friend = friends[index];
            Rx<bool> selected = false.obs;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: Svg(
                    friend['dp'],
                  ),
                  radius: 25,
                ),
                contentPadding: const EdgeInsets.all(0),
                title: Text(friend['name']),
                subtitle: Text(friend['status']),
                trailing: Obx(() => Checkbox(
                      value: selected.value,
                      onChanged: (bool? value) {
                        selected.value = value!;
                      },
                      fillColor: CheckBoxStyle.fillColor(context),
                      shape: const CircleBorder(),
                    )),
              ),
            );
          },
        ));
  }
}
