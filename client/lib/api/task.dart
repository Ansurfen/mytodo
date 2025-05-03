// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/api/response.dart';
import 'package:my_todo/model/dao/task.dart';
import 'package:my_todo/model/dto/task.dart';
import 'package:my_todo/model/entity/task.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

Future<Map<String, dynamic>> taskFileUploadRequest({
  required int taskId,
  required int condId,
  required TFile file,
}) async {
  FormData formData = FormData.fromMap({
    'task_id': taskId,
    'condition_id': condId,
  });

  formData.files.add(MapEntry("file", await file.m));

  return (await HTTP.post(
    '/task/file/upload',
    data: formData,
    options: Options(headers: {"Authorization": Guard.jwt}),
  )).data["data"];
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

@JsonSerializable()
class TaskDashboardStats {
  @JsonKey(name: "completed")
  int completed;

  @JsonKey(name: "overdue")
  int overdue;

  @JsonKey(name: "in_progress")
  int inProgress;

  @JsonKey(name: "daily_finished")
  int dailyFinished;

  @JsonKey(name: "daily_total")
  int dailyTotal;

  @JsonKey(name: "monthly_finished")
  int monthlyFinished;

  @JsonKey(name: "monthly_total")
  int monthlyTotal;

  @JsonKey(name: "yearly_finished")
  int yearlyFinished;

  @JsonKey(name: "yearly_total")
  int yearlyTotal;

  TaskDashboardStats({
    required this.completed,
    required this.overdue,
    required this.inProgress,
    required this.dailyFinished,
    required this.dailyTotal,
    required this.monthlyFinished,
    required this.monthlyTotal,
    required this.yearlyFinished,
    required this.yearlyTotal,
  });

  factory TaskDashboardStats.fromJson(Map<String, dynamic> json) =>
      _$TaskDashboardStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TaskDashboardStatsToJson(this);
}

Future<TaskDashboardStats> taskDashboard() async {
  return TaskDashboardStats.fromJson(
    (await HTTP.get(
      '/task/dashboard',
      options: Options(headers: {"Authorization": Guard.jwt}),
    )).data["data"],
  );
}

Future<Map<String, dynamic>> taskHeatMap() async {
  return (await HTTP.get(
        '/task/heatmap',
        options: Options(headers: {"Authorization": Guard.jwt}),
      )).data["data"]
      as Map<String, dynamic>;
}

Future<void> taskFileDeleteRequest(String filename) async {
  await HTTP.delete(
    '/task/file/$filename',
    options: Options(headers: {"Authorization": Guard.jwt}),
  );
}

Future<void> taskFileDownloadRequest(String filename) async {
  await HTTP.get(
    '/task/file/$filename',
    options: Options(headers: {"Authorization": Guard.jwt}),
  );
}

Future taskDetailRequest(int taskId) async {
  return (await HTTP.get(
    '/task/detail/$taskId',
    options: Options(headers: {"Authorization": Guard.jwt}),
  )).data["data"];
}

Future taskEditRequest({
  required int id,
  required String icon,
  required String name,
  required String description,
  required DateTime startAt,
  required DateTime endAt,
  required List<TaskCondition> conditions,
}) async {
  return await HTTP.post(
    '/task/edit',
    data: {
      "id": id,
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
