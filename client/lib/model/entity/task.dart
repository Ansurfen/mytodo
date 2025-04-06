// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/time.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  @JsonKey(name: "id", defaultValue: 0, required: false)
  int id;

  @JsonKey(name: "user", defaultValue: 0, required: false)
  int? user;

  @JsonKey(name: "name", defaultValue: "", required: true)
  String name;

  @JsonKey(name: "description", defaultValue: "", required: true)
  String description;

  @JsonKey(name: "start_at", fromJson: string2DateTime, required: true)
  DateTime startAt;

  @JsonKey(name: "end_at", fromJson: string2DateTime, required: true)
  DateTime endAt;

  Task(
    this.id,
    this.name,
    this.description,
    this.startAt,
    this.endAt, {
    this.user,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

class TaskCondition {
  String type;

  Map<String, dynamic> param;

  TaskCondition({required this.type, required this.param});

  Map<String, dynamic> toJson() {
    return {'type': type, 'param': param};
  }
}

enum TaskCondType { hand, timer, locale, file, image, content, qr }
