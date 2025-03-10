// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:my_todo/api/response.dart';
import 'package:my_todo/model/dao/topic.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/model/entity/topic.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/json.dart';
import 'package:my_todo/utils/net.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic.g.dart';

Future topicNew({
  required bool isPublic,
  required String name,
  required List<String> tags,
  required String description,
}) async {
  return await HTTP.post(
    '/topic/new',
    options: Options(headers: {"Authorization": "Bearer ${Guard.jwt}"}),
    data: {
      "is_public": isPublic,
      "name": name,
      "tags": tags,
      "description": description,
    },
  );
}

class GetTopicRequest {
  GetTopicRequest();
}

class GetTopicResponse extends BaseResponse {
  late final List<GetTopicDto> topics;

  GetTopicResponse(this.topics) : super({});

  GetTopicResponse.fromResponse(Response res) : super(res.data) {
    if (res.data["data"]["topics"] != null) {
      topics =
          (res.data["data"]["topics"] as List)
              .map((e) => GetTopicDto.fromJson(e))
              .toList();
    } else {
      topics = [];
    }
  }
}

Future<GetTopicResponse> getTopic(GetTopicRequest req) async {
  if (Guard.isOffline()) {
    return GetTopicResponse(
      (await TopicDao.findMany())
          .map(
            (e) => GetTopicDto(
              e.id ?? 0,
              DateTime.timestamp(),
              DateTime.timestamp(),
              e.name,
              e.desc,
              "",
              "",
            ),
          )
          .toList(),
    );
  }
  return GetTopicResponse.fromResponse(
    await HTTP.get(
      '/topic/get',
      options: Options(headers: {"x-token": Guard.jwt}),
    ),
  );
}

@JsonSerializable()
class CreateTopicRequest {
  @JsonKey(name: "name", defaultValue: "")
  String name;

  @JsonKey(name: "desc", defaultValue: "")
  String desc;

  CreateTopicRequest(this.name, this.desc);

  Map<String, Object?> toJson() => _$CreateTopicRequestToJson(this);
}

class CreateTopicResponse extends BaseResponse {
  String inviteCode = "";

  CreateTopicResponse() : super({});

  CreateTopicResponse.fromResponse(Response res)
    : inviteCode = res.data["data"]["invite_code"],
      super(res.data);
}

Future<CreateTopicResponse> createTopic(CreateTopicRequest req) async {
  if (Guard.isOffline()) {
    var res = await TopicDao.findOne(
      where: "user = ? and name = ?",
      whereArgs: [Guard.user, req.name],
    );
    if (res == null) {
      Topic t = Topic(Guard.user, req.name, req.desc);
      await TopicDao.create(t);
      Guard.eventBus.fire(t);
    } else {
      print("你已经创建了");
    }
    return CreateTopicResponse();
  }
  return CreateTopicResponse.fromResponse(
    await HTTP.post(
      '/topic/add',
      data: jsonEncode(req),
      options: Options(headers: {"x-token": Guard.jwt}),
    ),
  );
}

@JsonSerializable()
class SubscribeTopicRequest {
  @JsonKey(name: "invite_code")
  String code;

  SubscribeTopicRequest({required this.code});

  Map<String, Object?> toJson() => _$SubscribeTopicRequestToJson(this);
}

Future subscribeTopic(SubscribeTopicRequest req) {
  return HTTP.post(
    "/topic/sub",
    data: jsonEncode(req),
    options: Options(headers: {"x-token": Guard.jwt}),
  );
}

@JsonSerializable()
class GetSubscribedMemberRequest {
  @JsonKey(name: "id")
  int id;

  GetSubscribedMemberRequest({required this.id});

  JsonObject toJson() => _$GetSubscribedMemberRequestToJson(this);
}

class GetSubscribedMemberResponse extends BaseResponse {
  List<TopicMember> members = [];

  GetSubscribedMemberResponse() : super({});

  GetSubscribedMemberResponse.fromResponse(Response res) : super(res.data) {
    for (var e in (res.data["data"]["member"] as List)) {
      members.add(TopicMember.fromJson(e));
    }
  }
}

Future<GetSubscribedMemberResponse> getSubscribedMember(
  GetSubscribedMemberRequest req,
) async {
  return GetSubscribedMemberResponse.fromResponse(
    await HTTP.get('/topic/member/${req.id}'),
  );
}
