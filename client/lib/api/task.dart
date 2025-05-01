// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/api/response.dart';
import 'package:my_todo/model/dao/task.dart';
import 'package:my_todo/model/dto/task.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/utils/picker.dart';

part 'task.g.dart';

Future taskNewRequest({
  required int id,
  required String icon,
  required String name,
  required String description,
  required DateTime startAt,
  required DateTime endAt,
  required List<TaskCondition> conditions,
}) async {
  return HTTP.post(
    '/task/new',
    data: {
      "topic_id": id,
      "icon": icon,
      "name": name,
      "description": description,
      "start_at": startAt.toIso8601String(),
      "end_at": endAt.toIso8601String(),
      "conditions": conditions,
    },
    options: Options(headers: {"Authorization": Guard.jwt}),
  );
}

Future taskCommitRequest({
  required int taskId,
  required int condId,
  required Map argument,
}) async {
  return HTTP.post(
    '/task/commit',
    data: {"task_id": taskId, "condition_id": condId, "argument": argument},
    options: Options(headers: {"Authorization": Guard.jwt}),
  );
}

Future<List> topicGetRequest({required int page, required int limit}) async {
  return (await HTTP.get(
        '/task/get',
        options: Options(headers: {"Authorization": Guard.jwt}),
      )).data["data"]
      as List;
}

class GetTaskRequest {
  int limit;
  int page;

  GetTaskRequest(this.page, this.limit);
}

class GetTaskResponse extends BaseResponse {
  List<GetTaskDto> tasks;

  GetTaskResponse(this.tasks) : super({});

  GetTaskResponse.fromResponse(Response res)
    : tasks =
          (res.data['data']['tasks'] as List)
              .map((e) => GetTaskDto.fromJson(e))
              .toList(),
      super(res.data);

  @override
  String toString() {
    return "${super.toString()}, ${tasks.toString()}";
  }
}

class InfoTaskRequest {
  int id;

  InfoTaskRequest(this.id);
}

class InfoTaskResponse extends BaseResponse {
  late InfoTaskDto task;

  InfoTaskResponse.fromResponse(Response res)
    : task = InfoTaskDto.fromJson(res.data["data"]),
      super(res.data);
}

Future<InfoTaskResponse> infoTask(InfoTaskRequest req) async {
  return InfoTaskResponse.fromResponse(
    await HTTP.get(
      "/task/info",
      queryParams: {'id': req.id},
      options: Options(headers: {"x-token": Guard.jwt}),
    ),
  );
}

@JsonSerializable()
class CommitTaskRequest {
  @JsonKey(name: "tid")
  int task;

  @JsonKey(name: "type")
  int type;

  @JsonKey(name: "param")
  String param;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<TFile>? files;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<TFile>? images;

  CommitTaskRequest(
    this.task,
    this.type,
    this.param, {
    this.files,
    this.images,
  });

  Map<String, Object?> toJson() => _$CommitTaskRequestToJson(this);

  Future<FormData> toFormData() async {
    FormData formData = FormData();
    formData.fields.addAll(
      {'tid': "$task", 'param': param, 'type': "$type"}.entries,
    );
    if (files != null) {
      for (TFile file in files!) {
        formData.files.add(MapEntry("files", await file.m));
      }
    }
    if (images != null) {
      for (TFile img in images!) {
        formData.files.add(MapEntry("files", await img.m));
      }
    }
    return formData;
  }
}

class CommitTaskResponse extends BaseResponse {
  String param;

  CommitTaskResponse.fromResponse(Response res)
    : param = res.data["data"]["param"],
      super(res.data);
}

Future<CommitTaskResponse> commitTask(CommitTaskRequest req) async {
  if (req.images != null || req.files != null) {
    return CommitTaskResponse.fromResponse(
      await HTTP.post(
        "/task/commit",
        data: await req.toFormData(),
        options: Options(headers: {"x-token": Guard.jwt}),
      ),
    );
  }
  return CommitTaskResponse.fromResponse(
    await HTTP.post(
      "/task/commit",
      data: jsonEncode(req),
      options: Options(headers: {"x-token": Guard.jwt}),
    ),
  );
}

@JsonSerializable()
class TaskHasPermRequest {
  @JsonKey(name: "tid")
  int tid;

  TaskHasPermRequest({required this.tid});

  factory TaskHasPermRequest.fromJson(Map<String, dynamic> json) =>
      _$TaskHasPermRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TaskHasPermRequestToJson(this);
}

class TaskHasPermResponse extends BaseResponse {
  bool has;

  TaskHasPermResponse.fromResponse(Response res)
    : has = res.data["data"]["has"],
      super(res.data);
}

Future<TaskHasPermResponse> taskHasPerm(TaskHasPermRequest req) async {
  return TaskHasPermResponse.fromResponse(
    await HTTP.post(
      '/task/perm_check',
      data: jsonEncode(req),
      options: Options(headers: {"x-token": Guard.jwt}),
    ),
  );
}
