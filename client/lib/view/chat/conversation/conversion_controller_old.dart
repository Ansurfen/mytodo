// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/component/input.dart';
import 'package:my_todo/model/entity/chat.dart';
import 'package:my_todo/model/entity/user.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/pagination.dart';

class ConversionController extends GetxController {
  User user = User(0, "", "");
  Pagination<Chat> pagination = Pagination();
  Rx<bool> show = false.obs;
  String replyID = '';
  TodoInputController todoInputController =
      TodoInputController(TextEditingController(), TextEditingController());

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is User) {
      user = Get.arguments;
      fetchChats().then((res) {
        // chats.value = res.chats;
        pagination.setData(res.chats);
      });
    } else {
      userInfo(int.parse(Get.parameters["id"]!)).then((res) {
        user = res;
        fetchChats().then((res) {
          // chats.value = res.chats;
          pagination.setData(res.chats);
        });
      });
    }
  }

  @override
  void dispose() {
    todoInputController.dispose();
    super.dispose();
  }

  Future<GetChatResponse> fetchChats() {
    pagination.inc();
    return getChat(GetChatRequest(
        from: Guard.user, to: user.id, page: pagination.index(), pageSize: 10));
  }

  Future sendMessage(String v) {
    Chat msg = Chat(from: Guard.user, to: user.id, content: [v]);
    if (show.value) {
      msg.reply = replyID;
      replyID = "0";
    }
    return addChat(AddChatRequest(msg)).then((_) {
      if (show.value) {
        show.value = false;
      }
      for (String e in msg.content) {
        msg.content = ["0001$e"];
      }
      msg.time = DateTime.now();
      // chats.value.insert(0, msg);
      // chats.refresh();
      pagination.data.value.insert(0, msg);
      pagination.refresh();
    }).onError((error, stackTrace) {
      showError(error.toString());
    });
  }

  Future requestHistory() {
    pagination.inc();
    return getChat(GetChatRequest(
            from: Guard.user,
            to: user.id,
            page: pagination.index(),
            pageSize: 10))
        .then((res) {
      if (res.chats.isNotEmpty) {
        // chats.value.addAll(res.chats);
        // chats.refresh();
        pagination.data.value.addAll(res.chats);
        pagination.refresh();
      } else {
        pagination.dec();
        showError("no_more".tr);
      }
    });
  }
}
