// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/component/animate/fade_out_slow_in_container.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/animate.dart';
import 'package:my_todo/theme/provider.dart';
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
  List<ContactInfo> contacts = [];
  RxList<ContactInfo> filteredItems = <ContactInfo>[].obs;

  @override
  void initState() {
    super.initState();
    userContactsRequest().then((res) {
      for (var user in res) {
        contacts.add(
          ContactInfo(
            id: user["id"].toString(),
            name: user["name"],
            about: user["about"] ?? "",
          ),
        );
      }
      _handleList(contacts);
      filteredItems.value = List.from(contacts);
    });
    // contacts.addAll(
    //   List.generate(Mock.number(min: 5), (idx) {
    //     return ContactInfo(name: Mock.username(), about: Mock.text());
    //   }),
    // );
  }

  void _handleList(List<ContactInfo> list) {
    if (list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(contacts);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(contacts);

    setState(() {});
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: CupertinoSearchTextField(
            placeholder: "search".tr,
            style: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
            onChanged: (v) {
              controller.searchQuery = v;
              if (v.isEmpty) {
                controller.updateFilteredList("");
              } else {
                controller.updateFilteredList(v);
              }
            },
          ),
        ),
        Expanded(
          child: refreshContainer(
            context: context,
            onRefresh: controller.refreshItems,
            onLoad: () {},
            child: FadeAnimatedBuilder(
              opacity: TodoAnimateStyle.fadeOutOpacity(
                controller.animationController,
              ),
              animation: controller.animationController,
              child: Obx(
                () => ListView.separated(
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
                  itemCount:
                      controller.filteredSnapItems.length +
                      controller.pinnedItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    Chatsnapshot chat;
                    bool isPinned = false;
                    if (index < controller.pinnedItems.length) {
                      chat = controller.pinnedItems[index];
                      isPinned = true;
                    } else {
                      chat =
                          controller.filteredSnapItems[index -
                              controller.pinnedItems.length];
                    }
                    return Slidable(
                      key: ValueKey(index),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        // TODO
                        // dismissible: DismissiblePane(
                        //   onDismissed: () {
                        //     controller.removeItem(chat);
                        //   },
                        // ),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              controller.removeItem(chat);
                            },
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'delete'.tr,
                          ),
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              TodoShare.share(
                                controller.filteredSnapItems[index].name,
                              );
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
                            onPressed: (BuildContext context) {
                              chatRead(
                                isTopic: chat.isTopic,
                                id: chat.id,
                                lastMessageId: chat.lastMsgId,
                              ).then((_) {
                                chat.unreaded = 0;
                                if (controller.pinnedItems.contains(chat)) {
                                  controller.pinnedItems[index] = chat;
                                } else {
                                  controller.filteredSnapItems[index -
                                          controller.pinnedItems.length] =
                                      chat;
                                }
                              });
                            },
                            backgroundColor: const Color(0xFF7BC043),
                            foregroundColor: Colors.white,
                            icon: Icons.archive,
                            label: 'readed'.tr,
                          ),
                          SlidableAction(
                            flex: isPinned ? 2 : 1,
                            backgroundColor: const Color(0xFF0392CF),
                            foregroundColor: Colors.white,
                            icon:
                                isPinned ? Icons.download : Icons.upload_sharp,
                            label: isPinned ? 'down'.tr : 'top'.tr,
                            onPressed: (BuildContext context) {
                              if (!controller.pinnedItems.contains(chat)) {
                                controller.pinnedItems.add(chat);
                                controller.allItems.remove(chat);
                                controller.updateFilteredList(
                                  controller.searchQuery,
                                );
                              } else {
                                controller.pinnedItems.remove(chat);
                                controller.allItems.insert(0, chat);
                                controller.updateFilteredList(
                                  controller.searchQuery,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      child:
                          isPinned
                              ? Container(
                                color: ThemeProvider.contrastColor(
                                  context,
                                  light: Colors.grey.shade100,
                                  dark: CupertinoColors.darkBackgroundGray,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: ChatItem(
                                  icon: chat.icon,
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
                              )
                              : Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: ChatItem(
                                  uid: chat.id,
                                  icon: chat.icon,
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
                              ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 65,
          decoration: BoxDecoration(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget friendView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: CupertinoSearchTextField(
            placeholder: "search".tr,
            style: TextStyle(
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
            onChanged: (v) {
              if (v.isEmpty) {
                filteredItems.value = List.from(contacts);
              } else {
                filteredItems.clear();
                for (var item in contacts) {
                  if (item.name.contains(v)) {
                    filteredItems.add(item);
                  }
                }
              }
            },
          ),
        ),
        ListTile(
          leading: Text("new_friend".tr, style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.arrow_forward_ios_sharp),
        ),
        Expanded(
          child: Obx(
            () => AzListView(
              data: filteredItems,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return _buildListItem(filteredItems[index]);
              },
              physics: BouncingScrollPhysics(),
              indexBarData: SuspensionUtil.getTagIndexList(filteredItems),
              indexHintBuilder: (context, hint) {
                return Container(
                  alignment: Alignment.center,
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(200),
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
                decoration: getIndexBarDecoration(
                  ThemeProvider.contrastColor(
                    context,
                    light: Colors.white,
                    dark: Color(0xFF090912),
                  ),
                ),
                downDecoration: getIndexBarDecoration(
                  ThemeProvider.contrastColor(
                    context,
                    light: Colors.white,
                    dark: Color(0xFF090912),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 65,
          decoration: BoxDecoration(color: Colors.transparent),
        ),
      ],
    );
  }

  Decoration getIndexBarDecoration(Color color) {
    return BoxDecoration(color: color);
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: 40,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(susTag, textScaleFactor: 1.2),
          Expanded(child: Divider(height: .0, indent: 10.0)),
        ],
      ),
    );
  }

  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    var id = int.parse(model.id!);
    return Column(
      children: [
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: TodoImage.userProfile(id),
            radius: 25,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.name),
              Container(height: 5),
              Text(model.about, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          onTap: () {
            RouterProvider.toUserProfile(id);
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
  String about;
  String? tagIndex;
  String? namePinyin;

  Color? bgColor;
  IconData? iconData;

  String? img;
  String? id;
  String? firstletter;

  ContactInfo({
    required this.name,
    this.about = "",
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
      about = json['about'],
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
