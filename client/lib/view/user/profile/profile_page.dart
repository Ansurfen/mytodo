// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/icon.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/view/post/snapshot/post_card.dart';
import 'package:my_todo/view/user/profile/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: todoAppBar(
        context,
        leading: todoLeadingIconButton(
          context,
          onPressed: Get.back,
          icon: Icons.arrow_back_ios,
        ),
        elevation: 0,
        actions: [
          notificationWidget(context),
          const SizedBox(width: 30),
          settingWidget(),
          const SizedBox(width: 20),
          multiWidget(context),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                backgroundImage: TodoImage.userProfile(controller.id),
                radius: 50,
              ),
              const SizedBox(height: 10),
              Obx(
                () => Text(
                  controller.user.value.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(controller.user.value.description, style: TextStyle()),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      RouterProvider.viewChatConversation(
                        Chatsnapshot(
                          unreaded: 0,
                          lastAt: DateTime.now(),
                          lastMsg: "",
                          name: controller.user.value.name,
                          id: controller.id,
                          isOnline: true,
                          isTopic: false,
                        ),
                      );
                    },
                    child: const Icon(Icons.message, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "follow",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => _buildCategory(
                        "post_count".tr,
                        controller.user.value.postCount,
                      ),
                    ),
                    Obx(
                      () => _buildCategory(
                        "follower_count".tr,
                        controller.user.value.followerCount,
                      ),
                    ),
                    Obx(
                      () => _buildCategory(
                        "topic_count".tr,
                        controller.user.value.topicCount,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, idx) {
                  return PostCard(
                    model: Post(
                      1,
                      1,
                      Mock.username(),
                      Mock.boolean(),
                      "",
                      [],
                      Mock.dateTime(),
                      Mock.number(),
                      Mock.number(),
                      Mock.number(),
                      Mock.boolean(),
                    ),
                    more: () {},
                  );
                },
                separatorBuilder: (context, idx) {
                  return Divider();
                },
                itemCount: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle()),
      ],
    );
  }
}
