// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/net.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController with GetTickerProviderStateMixin {
  late TabController tabController;
  late final AnimationController animationController;
  List<Chatsnapshot> allItems = [];
  RxList<Chatsnapshot> pinnedItems = <Chatsnapshot>[].obs;
  RxList<Chatsnapshot> filteredSnapItems = <Chatsnapshot>[].obs;
  WebSocketChannel? chatChannel;

  String searchQuery = "";
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    refreshItems();
    webSocketListen();
    Future.delayed(const Duration(milliseconds: 100), () {
      animationController.forward();
    });
  }

  @override
  void onClose() {
    chatChannel?.sink.close();
    super.onClose();
  }

  void refreshItems() {
    allItems.clear();
    Future.delayed(Duration.zero, () {
      if (Guard.isDevMode()) {
        allItems = Chatsnapshot.randomList();
        updateFilteredList("");
      } else {
        chatSnapshotRequest().then((res) {
          for (var item in res) {
            var v = Chatsnapshot.fromJson(item);
            if (v.isTopic) {
              v.lastMsg = "${v.lastSenderName}: ${v.lastMsg}";
            }
            allItems.add(v);
          }
          updateFilteredList("");
        });
      }
    });
  }

  void updateFilteredList(String query) {
    filteredSnapItems.value =
        allItems
            .where(
              (item) =>
                  !pinnedItems.contains(item) &&
                  item.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
  }

  void removeItem(Chatsnapshot item) {
    if (pinnedItems.contains(item)) {
      pinnedItems.remove(item);
    } else {
      allItems.remove(item);
      filteredSnapItems.remove(item);
    }
    updateFilteredList(searchQuery);
  }

  void webSocketListen() {
    chatChannel = WS.listen(
      "/chat/ws",
      callback: (v) {
        try {
          // 将消息转换为字符串，然后解析为 JSON
          final String messageStr = v.toString();
          final data = jsonDecode(messageStr) as Map<String, dynamic>;
          final type = data['type'] as String;
          final message = data['message'] as Map<String, dynamic>;

          switch (type) {
            case 'topic':
              handleTopicMessage(message);
              break;
            case 'friend':
              handleFriendMessage(message);
              break;
          }
        } catch (e) {
          Guard.log.e(e);
        }
      },
    );
  }

  void handleTopicMessage(Map<String, dynamic> message) {
    final topicId = message['topic_id'] as int;
    final lastMessage = message['message'] as String;
    final lastSenderName = message['sender_name'] as String;
    final lastAt = DateTime.parse(message['created_at'] as String);

    // 更新或添加新的聊天快照
    final index = allItems.indexWhere(
      (item) => item.isTopic && item.id == topicId,
    );
    if (index != -1) {
      final item = allItems[index];
      item.lastMsg = "$lastSenderName: $lastMessage";
      item.lastAt = lastAt;
      allItems.removeAt(index);
      allItems.insert(0, item);
    } else {
      // 如果是新的聊天，需要重新获取快照列表
      refreshItems();
    }

    updateFilteredList(searchQuery);
  }

  void handleFriendMessage(Map<String, dynamic> message) {
    final friendId = message['friend_id'] as int;
    final lastMessage = message['message'] as String;
    final lastSenderName = message['sender_name'] as String;
    final lastAt = DateTime.parse(message['created_at'] as String);

    // 更新或添加新的聊天快照
    final index = allItems.indexWhere(
      (item) => !item.isTopic && item.id == friendId,
    );
    if (index != -1) {
      final item = allItems[index];
      item.lastMsg = lastMessage;
      item.lastSenderName = lastSenderName;
      item.lastAt = lastAt;
      allItems.removeAt(index);
      allItems.insert(0, item);
    } else {
      // 如果是新的聊天，需要重新获取快照列表
      refreshItems();
    }

    updateFilteredList(searchQuery);
  }
}
