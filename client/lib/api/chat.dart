// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/api/response.dart';
import 'package:my_todo/model/dto/chat.dart';
import 'package:my_todo/model/entity/chat.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/json.dart';
import 'package:my_todo/utils/net.dart';

part 'chat.g.dart';

class AddChatRequest {
  Chat chat;

  AddChatRequest(this.chat);

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll(
      {
        'from': '${chat.from}',
        'to': '${chat.to}',
        'content': chat.content.isNotEmpty ? chat.content[0] : " ",
        "reply": chat.reply,
      }.entries,
    );
    return formData;
  }
}

Future addChat(AddChatRequest req) async {
  return await HTTP.post(
    '/chat/add',
    data: req.toFormData(),
    options: Options(headers: {'x-token': Guard.jwt}),
  );
}

Future chatFriend() async {
  return await HTTP.get(
    '/chat/friend',
    options: Options(headers: {'x-token': Guard.jwt}),
  );
}

@JsonSerializable()
class GetChatRequest {
  @JsonKey(name: "from")
  int from;

  @JsonKey(name: "to")
  int to;

  @JsonKey(name: "page")
  int page;

  @JsonKey(name: "pageSize")
  int pageSize;

  GetChatRequest({
    required this.from,
    required this.to,
    required this.page,
    required this.pageSize,
  });

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll(
      {
        'from': "$from",
        'to': "$to",
        'page': "$page",
        'pageSize': "$pageSize",
      }.entries,
    );
    return formData;
  }

  JsonObject toJson() => _$GetChatRequestToJson(this);
}

class GetChatResponse extends BaseResponse {
  List<Chat> chats = [];

  GetChatResponse() : super({});

  GetChatResponse.fromResponse(Response res) : super(res.data) {
    if (res.data["data"]["chats"] != null) {
      chats =
          (res.data["data"]["chats"] as List)
              .map((e) => Chat.fromJson(e))
              .toList();
    }
  }
}

Future<GetChatResponse> getChat(GetChatRequest req) async {
  return GetChatResponse.fromResponse(
    await HTTP.post(
      '/chat/get',
      data: jsonEncode(req),
      options: Options(headers: {'Authorization': Guard.jwt}),
    ),
  );
}

Future<List> chatSnapshotRequest() async {
  return (await HTTP.get(
    '/chat/snap',
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future chatNew({
  required bool isTopic,
  required int id,
  required String message,
  required String messageType,
  required int voiceDuration,
  required int replyId,
  required int replyBy,
  required int replyTo,
  required String replyType,
}) async {
  String url = "/chat/friend/new";
  if (isTopic) {
    url = "/chat/topic/new";
  }
  var data = {
    "message": message,
    "message_type": messageType,
    "voice_duration": voiceDuration,
    "reply_id": replyId,
    "reply_by": replyBy,
    "reply_to": replyTo,
    "reply_type": replyType,
  };
  if (isTopic) {
    data["topic_id"] = id;
  } else {
    data["friend_id"] = id;
  }
  return await HTTP.post(
    url,
    data: data,
    options: Options(headers: {'Authorization': Guard.jwt}),
  );
}

Future chatGet({
  required bool isTopic,
  required int id,
  required int page,
  required int pageSize,
}) async {
  String url = "/chat/friend/get";
  if (isTopic) {
    url = "/chat/topic/get";
  }
  var data = {"page": page, "page_size": pageSize};
  if (isTopic) {
    data["topic_id"] = id;
  } else {
    data["friend_id"] = id;
  }
  return (await HTTP.post(
    url,
    data: data,
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future chatFileUpload({
  required bool isTopic,
  required String id,
  required String replyId,
  required String replyBy,
  required String replyTo,
  required String replyType,
  required MultipartFile file,
  required int voiceDuration,
}) async {
  String url = "/chat/friend/upload";
  if (isTopic) {
    url = "/chat/topic/upload";
  }
  FormData formData = FormData();
  formData.files.add(MapEntry("file", file));
  formData.fields.addAll(
    {
      "reply_id": replyId,
      "reply_by": replyBy,
      "reply_to": replyTo,
      "reply_type": replyType,
      "voice_duration": voiceDuration.toString(),
    }.entries,
  );
  if (isTopic) {
    formData.fields.add(MapEntry("topic_id", id));
  } else {
    formData.fields.add(MapEntry("friend_id", id));
  }
  return await HTTP.post(
    url,
    data: formData,
    options: Options(headers: {'Authorization': Guard.jwt}),
  );
}

Future chatTopicReaction({
  required int messageId,
  required String emoji,
}) async {
  return await HTTP.post(
    '/chat/topic/reaction',
    data: {"message_id": messageId, "emoji": emoji},
    options: Options(headers: {'Authorization': Guard.jwt}),
  );
}

Future chatFriendReaction({
  required int messageId,
  required String emoji,
}) async {
  return await HTTP.post(
    '/chat/friend/reaction',
    data: {"message_id": messageId, "emoji": emoji},
    options: Options(headers: {'Authorization': Guard.jwt}),
  );
}

Future chatRead({
  required bool isTopic,
  required int id,
  required int lastMessageId,
}) async {
  var url = "/chat/friend/read";
  if (isTopic) {
    url = "/chat/topic/read";
  }
  var data = {"last_message_id": lastMessageId};
  if (isTopic) {
    data["topic_id"] = id;
  } else {
    data["friend_id"] = id;
  }
  return await HTTP.post(
    url,
    data: data,
    options: Options(headers: {'Authorization': Guard.jwt}),
  );
}
