// Copyright 2025 The mytodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io' show File;
import 'package:chatview/chatview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' as getx;
import 'package:my_todo/api/chat.dart';
import 'package:my_todo/api/topic.dart';
import 'package:my_todo/config.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/model/user.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:video_player/video_player.dart';

class ConversionController extends getx.GetxController {
  Map<String, VideoPlayerController> videoplayers = {};
  late Chatsnapshot chatsnapshot;
  late ChatController chatController;
  getx.Rx<int> onlineCount = 0.obs;

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
    Future.delayed(Duration.zero, () {
      if (chatsnapshot.isTopic) {
        chatTopicOnlineCount(topicId: chatsnapshot.id).then((v) {
          onlineCount.value = v["count"];
        });
        topicMemberGetRequest(id: chatsnapshot.id).then((v) {
          List<ChatUser> chatusers = [];
          for (var e in v) {
            var u = TopicMember.fromJson(e);
            chatusers.add(
              ChatUser(
                id: u.id.toString(),
                name: u.name,
                profilePhoto: '${TodoConfig.baseUri}/user/profile/${u.id}',
              ),
            );
          }
          chatController.otherUsers = chatusers;
        });
      } else {
        var id = chatsnapshot.id;
        if (Guard.u!.id != chatsnapshot.id) {
          chatController.otherUsers = [
            ChatUser(
              id: id.toString(),
              name: chatsnapshot.name,
              profilePhoto: '${TodoConfig.baseUri}/user/profile/$id',
            ),
          ];
        }
      }
    });
    // 标记已读
    chatRead(
      isTopic: chatsnapshot.isTopic,
      id: chatsnapshot.id,
      lastMessageId: chatsnapshot.lastMsgId,
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
          await chatFileUpload(
            file: fileToSend,
            isTopic: chatsnapshot.isTopic,
            id: chatsnapshot.id.toString(),
            replyId: reply["id"],
            replyBy: reply["replyTo"],
            replyTo: reply["replyBy"],
            replyType: reply["message_type"],
            voiceDuration: 0,
          );
        } catch (e) {
          debugPrint('上传时出错: $e');
        }
      case 'voice':
        try {
          Guard.log.i(jsonData);
          final filePath = jsonData["message"];
          File file = File(filePath);
          if (!await file.exists()) {
            debugPrint("文件不存在");
            return;
          }
          MultipartFile fileToSend = await MultipartFile.fromFile(
            filePath,
            filename: 'voice.m4a',
          );
          await chatFileUpload(
            file: fileToSend,
            isTopic: chatsnapshot.isTopic,
            id: chatsnapshot.id.toString(),
            replyId: reply["id"],
            replyBy: reply["replyTo"],
            replyTo: reply["replyBy"],
            replyType: reply["message_type"],
            voiceDuration: 0,
          );
        } catch (e) {
          debugPrint('上传时出错: $e');
        }
    }
  }
}
