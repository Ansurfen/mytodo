// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/api/response.dart';
import 'package:my_todo/model/entity/notify.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/net.dart';

@JsonSerializable()
class NotifyActionAddRequest {
  @JsonKey(name: "type")
  int type;

  @JsonKey(name: "id")
  int receiver;

  @JsonKey(name: "param", defaultValue: "")
  String param;

  NotifyActionAddRequest(
      {required this.type, required this.receiver, this.param = ""});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields
        .addAll({'id': '$receiver', 'type': '$type', 'param': param}.entries);
    return formData;
  }
}

Future notifyActionAdd(NotifyActionAddRequest req) async {
  return await HTTP.post('/notify/action/add',
      data: req.toFormData(),
      options: Options(headers: {'x-token': Guard.jwt}));
}

@JsonSerializable()
class NotifyActionCommitRequest {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "status")
  late int status;

  NotifyActionCommitRequest({required this.id, required NotifyStatus status}) {
    switch (status) {
      case NotifyStatus.unknown:
        this.status = NotifyStatus.unknown.index;
      case NotifyStatus.wait:
        this.status = NotifyStatus.wait.index;
      case NotifyStatus.confirm:
        this.status = NotifyStatus.confirm.index;
      case NotifyStatus.refuse:
        this.status = NotifyStatus.refuse.index;
    }
  }

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({'id': '$id', 'status': '$status'}.entries);
    return formData;
  }
}

Future notifyActionCommit(NotifyActionCommitRequest req) async {
  return await HTTP.post('/notify/action/add',
      data: req.toFormData(),
      options: Options(headers: {'x-token': Guard.jwt}));
}

class NotifyAllResponse extends BaseResponse {
  late final List<Notify> notifications;

  NotifyAllResponse() : super({});

  NotifyAllResponse.fromResponse(Response res)
      : notifications = (res.data["data"]["notify"] as List)
            .map((e) => Notify.fromJson(e))
            .toList(),
        super(res.data);
}

Future<NotifyAllResponse> notifyAll() async {
  if (Guard.isOffline()) {
    return NotifyAllResponse();
  }
  return NotifyAllResponse.fromResponse(await HTTP.get('/notify/all',
      options: Options(headers: {'x-token': Guard.jwt})));
}

class NotifyGetDetailRequest {
  int id;

  NotifyGetDetailRequest({required this.id});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({
      'id': "$id",
    }.entries);
    return formData;
  }
}

class NotifyGetDetailResponse extends BaseResponse {
  late Notify notify;

  NotifyGetDetailResponse() : super({});

  NotifyGetDetailResponse.fromResponse(Response res)
      : notify = Notify.fromJson(res.data["data"]["notify"]),
        super(res.data);
}

Future<NotifyGetDetailResponse> notifyGetDetail(
    NotifyGetDetailRequest req) async {
  if (Guard.isOffline()) {
    return NotifyGetDetailResponse();
  }
  return NotifyGetDetailResponse.fromResponse(
      await HTTP.post('/notify/detail', data: req.toFormData()));
}
