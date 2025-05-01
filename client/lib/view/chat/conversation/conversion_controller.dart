// Copyright 2025 The mytodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io' show File;
import 'package:chatview/chatview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' as getx;
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:video_player/video_player.dart';

class ConversionController extends getx.GetxController {
  Map<String, VideoPlayerController> videoplayers = {};
  late Chatsnapshot chatsnapshot;
  late ChatController chatController;

  @override
  void onInit() {
    super.onInit();
    chatsnapshot = getx.Get.arguments;
    chatController = ChatController(
      initialMessageList: [],
      scrollController: ScrollController(),
      otherUsers: [],
      currentUser: ChatUser(id: Guard.u!.id.toString(), name: Guard.u!.name),
    );
  }

  @override
  void dispose() {
    videoplayers.forEach((k, v) {
      v.dispose();
    });
    super.dispose();
  }

  Future sendMessage(Map<String, dynamic> jsonData) async {
    Map<String, dynamic> reply = jsonData["reply_message"];

    switch (jsonData['message_type']) {
      case 'text':
        chatNew(
          isTopic: chatsnapshot.isTopic,
          id: chatsnapshot.id,
          message: jsonData['message'],
          messageType: 'text',
          voiceDuration: 0,
          replyId: reply["id"] == "" ? 0 : int.parse(reply["id"]),
          replyBy: reply["replyTo"] == "" ? 0 : int.parse(reply["replyTo"]),
          replyTo: reply["replyBy"] == "" ? 0 : int.parse(reply["replyBy"]),
          replyType: reply["message_type"],
        );
      case 'image':
        try {
          final filePath = jsonData["message"];
          File file = File(filePath);
          if (!await file.exists()) {
            debugPrint("文件不存在");
            return;
          }
          MultipartFile fileToSend = await MultipartFile.fromFile(
            filePath,
            filename: 'img.png',
          );
          await chatImageUpload(
            file: fileToSend,
            isTopic: chatsnapshot.isTopic,
            id: chatsnapshot.id.toString(),
            replyId: reply["id"],
            replyBy: reply["replyTo"],
            replyTo: reply["replyBy"],
            replyType: reply["message_type"],
          );
        } catch (e) {
          debugPrint('上传时出错: $e');
        }
    }
  }
}
