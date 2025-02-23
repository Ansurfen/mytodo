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

@JsonSerializable()
class CreateTaskRequest {
  @JsonKey(name: "topic")
  int topic;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "desc")
  String desc;

  // String cron;

  @JsonKey(name: "departure")
  DateTime departure;

  @JsonKey(name: "arrival")
  DateTime arrival;

  @JsonKey(name: "conds", fromJson: TaskCondition.conditionsFromJson)
  List<TaskCondition> conds;

  CreateTaskRequest(this.topic, this.name, this.desc, this.departure,
      this.arrival, this.conds);

  Map<String, Object?> toJson() => _$CreateTaskRequestToJson(this);
}

class CreateTaskResponse extends BaseResponse {
  CreateTaskResponse() : super({});

  CreateTaskResponse.fromResponse(Response res) : super(res.data);
}

Future<CreateTaskResponse> createTask(CreateTaskRequest req) async {
  if (Guard.isOffline()) {
    TaskDao.create(Task(
        req.name,
        req.desc,
        DateTime.now().microsecondsSinceEpoch,
        DateTime.now().microsecondsSinceEpoch,
        user: Guard.user));
    return CreateTaskResponse();
  }
  return CreateTaskResponse.fromResponse(await HTTP.post("/task/add",
      data: jsonEncode(req),
      options: Options(headers: {
        "x-token": Guard.jwt,
      })));
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
      : tasks = (res.data['data']['tasks'] as List)
            .map((e) => GetTaskDto.fromJson(e))
            .toList(),
        super(res.data);

  @override
  String toString() {
    return "${super.toString()}, ${tasks.toString()}";
  }
}

Future<GetTaskResponse> getTask(GetTaskRequest req) async {
  if (Guard.isOffline()) {
    List<GetTaskDto> tasks = [];
    (await TaskDao.findMany()).map((e) => tasks.add(GetTaskDto(
        e.id!,
        "",
        e.name,
        e.desc,
        DateTime.fromMicrosecondsSinceEpoch(e.startAt),
        DateTime.fromMicrosecondsSinceEpoch(e.endAt), [])));
    return GetTaskResponse(tasks);
  }
  return GetTaskResponse.fromResponse(await HTTP.post("/task/get",
      queryParams: {
        'page': req.page,
        'limit': req.limit,
      },
      options: Options(headers: {
        "x-token": Guard.jwt,
      })));
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
  return InfoTaskResponse.fromResponse(await HTTP.get("/task/info",
      queryParams: {
        'id': req.id,
      },
      options: Options(headers: {
        "x-token": Guard.jwt,
      })));
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

  CommitTaskRequest(this.task, this.type, this.param,
      {this.files, this.images});

  Map<String, Object?> toJson() => _$CommitTaskRequestToJson(this);

  Future<FormData> toFormData() async {
    FormData formData = FormData();
    formData.fields.addAll({
      'tid': "$task",
      'param': param,
      'type': "$type",
    }.entries);
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
    return CommitTaskResponse.fromResponse(await HTTP.post("/task/commit",
        data: await req.toFormData(),
        options: Options(headers: {
          "x-token": Guard.jwt,
        })));
  }
  return CommitTaskResponse.fromResponse(await HTTP.post("/task/commit",
      data: jsonEncode(req),
      options: Options(headers: {
        "x-token": Guard.jwt,
      })));
}

@JsonSerializable()
class TaskHasPermRequest {
  @JsonKey(name: "tid")
  int tid;

  TaskHasPermRequest({
    required this.tid,
  });

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
  return TaskHasPermResponse.fromResponse(await HTTP.post('/task/perm_check',
      data: jsonEncode(req),
      options: Options(headers: {
        "x-token": Guard.jwt,
      })));
}
