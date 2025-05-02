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

Future topicNewRequest({
  required String icon,
  required String name,
  required String description,
  required bool isPublic,
  required List<String> tags,
}) async {
  return HTTP.post(
    "/topic/new",
    data: {
      "icon": icon,
      "name": name,
      "description": description,
      "is_public": isPublic,
      "tags": tags,
    },
    options: Options(headers: {"Authorization": Guard.jwt}),
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

Future<List?> topicGetRequest() async {
  return (await HTTP.get(
    "/topic/get",
    options: Options(headers: {"Authorization": Guard.jwt}),
  )).data["data"];
}

Future<List<Topic>> topicGetSelectableRequest() async {
  return ((await HTTP.get(
            "/topic/getSelectable",
            options: Options(headers: {"Authorization": Guard.jwt}),
          )).data["topic"]
          as List)
      .map((e) => Topic.fromJson(e))
      .toList();
}

Future<List> topicCalendarRequest({required int id}) async {
  return (await HTTP.post(
        '/topic/calendar',
        data: {'topic_id': id},
        options: Options(headers: {"Authorization": Guard.jwt}),
      )).data["data"]
      as List;
}

Future topicMemberGetRequest({required int id}) async {
  return (await HTTP.post(
        '/topic/member/get',
        data: {'topic_id': id},
        options: Options(headers: {"Authorization": Guard.jwt}),
      )).data["data"]
      as List;
}

Future topicFindRequest({required int page, required int pageSize}) async {
  return (await HTTP.post(
    '/topic/find',
    data: {'page': page, 'page_size': pageSize},
    options: Options(headers: {"Authorization": Guard.jwt}),
  )).data["data"];
}

Future topicApplyNew({required int topicId}) async {
  return (await HTTP.post(
    '/topic/apply/new',
    data: {'topic_id': topicId},
    options: Options(headers: {"Authorization": Guard.jwt}),
  )).data["msg"];
}

Future topicApplyCommit({
  required int notificationId,
  required bool pass,
}) async {
  return HTTP.post(
    '/topic/apply/commit',
    data: {'notification_id': notificationId, 'pass': pass},
    options: Options(headers: {"Authorization": Guard.jwt}),
  );
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
              e.description,
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
