// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/api/topic.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/container/bubble_container.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/hook/topic.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/view/add/component/form.dart';

class AddTopicPage extends StatefulWidget {
  const AddTopicPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            FormHeader(icon: Icons.drive_file_rename_outline, name: "name".tr),
            const SizedBox(height: 5),
            BubbleTextFormField(
              maxLines: 1,
              hintText: "name".tr,
              onChanged: (v) {
                nameController.text = v;
              },
            ),
            const SizedBox(height: 10),
            FormHeader(icon: Icons.description, name: "description".tr),
            const SizedBox(height: 5),
            BubbleTextFormField(
              minLines: 6,
              hintText: "desc".tr,
              onChanged: (v) {
                descController.text = v;
              },
            ),
            const SizedBox(
              height: 30,
            ),
            ShadowButton(
                text: "create".tr,
                size: const Size(200, 40),
                textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
                onTap: () async {
                  if (descController.text.isNotEmpty &&
                      nameController.text.isNotEmpty) {
                    createTopic(CreateTopicRequest(
                            nameController.text, descController.text))
                        .then((res) {
                      TopicHook.updateSnapshot(GetTopicDto(
                          0,
                          DateTime.timestamp(),
                          DateTime.timestamp(),
                          nameController.text,
                          descController.text,
                          ""));
                      showCopyableTipDialog(context,
                              content:
                                  "${"topic_created".tr} ${res.inviteCode}")
                          .then((value) {
                        Get.back();
                      });
                    }).onError((error, stackTrace) {});
                  }
                })
          ],
        ));
  }
}
