// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
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
  final List<ContactInfo> _contacts = [];

  @override
  void initState() {
    super.initState();
    _contacts.addAll([
      ContactInfo(name: "a", tagIndex: "a"),
      ContactInfo(name: "b", tagIndex: "b"),
      ContactInfo(name: "aa", tagIndex: "a"),
    ]);
  }

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
        children: [chatView(context), friendView(context)],
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

  Widget friendView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: CupertinoSearchTextField(),
        ),
        ListTile(
          leading: Text("新朋友", style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.arrow_forward_ios_sharp),
        ),
        AzListView(
          data: _contacts,
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            if (index == 0) return _buildHeader();
            return _buildListItem(_contacts[index]);
          },
          physics: BouncingScrollPhysics(),
          indexBarData: SuspensionUtil.getTagIndexList(_contacts),
          indexHintBuilder: (context, hint) {
            return Container(
              alignment: Alignment.center,
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: Colors.blue[700]!.withAlpha(200),
                shape: BoxShape.circle,
              ),
              child: Text(
                hint,
                style: TextStyle(color: Colors.white, fontSize: 30.0),
              ),
            );
          },
          indexBarMargin: EdgeInsets.all(10),
          indexBarOptions: IndexBarOptions(
            needRebuild: true,
            decoration: getIndexBarDecoration(Colors.grey[50]!),
            downDecoration: getIndexBarDecoration(Colors.grey[200]!),
          ),
        ),
      ],
    );
  }

  Decoration getIndexBarDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20.0),
      border: Border.all(color: Colors.grey[300]!, width: .5),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(child: SvgPicture.asset("assets/logo.svg", width: 80.0)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("远行", textScaleFactor: 1.2),
          ),
          Text("+86 182-286-44678"),
        ],
      ),
    );
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: 40,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text('$susTag', textScaleFactor: 1.2),
          Expanded(child: Divider(height: .0, indent: 10.0)),
        ],
      ),
    );
  }

  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[700],
            child: Text(model.name[0], style: TextStyle(color: Colors.white)),
          ),
          title: Text(model.name),
          onTap: () {
            print("OnItemClick: $model");
            Navigator.pop(context, model);
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ContactInfo extends ISuspensionBean {
  String name;
  String? tagIndex;
  String? namePinyin;

  Color? bgColor;
  IconData? iconData;

  String? img;
  String? id;
  String? firstletter;

  ContactInfo({
    required this.name,
    this.tagIndex,
    this.namePinyin,
    this.bgColor,
    this.iconData,
    this.img,
    this.id,
    this.firstletter,
  });

  ContactInfo.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      img = json['img'],
      id = json['id']?.toString(),
      firstletter = json['firstletter'];

  Map<String, dynamic> toJson() => {
    //        'id': id,
    'name': name,
    'img': img,
    //        'firstletter': firstletter,
    //        'tagIndex': tagIndex,
    //        'namePinyin': namePinyin,
    //        'isShowSuspension': isShowSuspension
  };

  @override
  String getSuspensionTag() => tagIndex!;

  @override
  String toString() => json.encode(this);
}
