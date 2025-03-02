// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/model/dto/chat.dart';
import 'package:my_todo/model/entity/user.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/utils/time.dart';
import 'package:my_todo/view/chat/snapshot/chat_controller.dart';
import 'package:my_todo/view/chat/snapshot/chat_item.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/component/refresh.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  ChatController controller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 40),
          child: TabBar(
            controller: controller.tabController,
            labelColor: themeData.colorScheme.onPrimary,
            unselectedLabelColor: themeData.colorScheme.onTertiary,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: themeData.colorScheme.onPrimary,
              ),
            ),
            isScrollable: true,
            tabs: [Tab(text: "chat_msg".tr), Tab(text: "chat_friend".tr)],
          ),
        ),
        actions: [
          notificationWidget(context),
          const SizedBox(width: 30),
          settingWidget(),
          const SizedBox(width: 20),
          multiWidget(context),
          const SizedBox(width: 10),
        ],
        backgroundColor: themeData.colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: TabBarView(
        controller: controller.tabController,
        children: [chatView(context), Container()],
      ),
    );
  }

  Widget chatView(BuildContext context) {
    return refreshContainer(
      context: context,
      onRefresh: () {},
      onLoad: () {},
      child: FadeAnimatedBuilder(
        opacity: TodoAnimateStyle.fadeOutOpacity(
          controller.animationController,
        ),
        animation: controller.animationController,
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
            itemCount: controller.data.value.length,
            itemBuilder: (BuildContext context, int index) {
              Chatsnapshot chat = controller.data.value[index];
              return Slidable(
                key: ValueKey(index),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dismissible: DismissiblePane(onDismissed: () {}),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) {},
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'delete'.tr,
                    ),
                    SlidableAction(
                      onPressed: (BuildContext context) {
                        TodoShare.share(controller.data.value[index].name);
                      },
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      label: 'share'.tr,
                    ),
                  ],
                ),

                // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      // An action can be bigger than the others.
                      flex: 2,
                      onPressed: (BuildContext context) {},
                      backgroundColor: const Color(0xFF7BC043),
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: 'readed'.tr,
                    ),
                    SlidableAction(
                      backgroundColor: const Color(0xFF0392CF),
                      foregroundColor: Colors.white,
                      icon: Icons.toc,
                      label: 'top'.tr,
                      onPressed: (BuildContext context) {},
                    ),
                  ],
                ),
                child: ChatItem(
                  uid: chat.id,
                  name: chat.name,
                  isOnline: chat.isOnline,
                  counter: chat.unreaded,
                  msg: chat.lastMsg,
                  time: formatTimeDifference(chat.lastAt),
                  isTopic: chat.isTopic,
                  onTap: () {
                    RouterProvider.viewChatConversation(chat);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
