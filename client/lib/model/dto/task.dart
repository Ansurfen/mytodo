// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class GetTaskDto {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "topic")
  String topic;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "desc")
  String desc;

  @JsonKey(name: "departure")
  DateTime departure;

  @JsonKey(name: "arrival")
  DateTime arrival;

  @JsonKey(name: "conds")
  List<int> conds;

  GetTaskDto(this.id, this.topic, this.name, this.desc, this.departure,
      this.arrival, this.conds);

  factory GetTaskDto.fromJson(Map<String, Object?> json) =>
      _$GetTaskDtoFromJson(json);
}

@JsonSerializable()
class InfoTaskDto {
  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "desc")
  String desc;

  @JsonKey(name: "departure")
  DateTime departure;

  @JsonKey(name: "arrival")
  DateTime arrival;

  @JsonKey(name: "conds")
  List<InfoTaskCondition> conds;

  InfoTaskDto(this.name, this.desc, this.departure, this.arrival, this.conds);

  factory InfoTaskDto.fromJson(Map<String, Object?> json) =>
      _$InfoTaskDtoFromJson(json);

  static empty() {}
}

@JsonSerializable()
class InfoTaskCondition {
  @JsonKey(name: "type")
  int type;

  @JsonKey(name: "want_params")
  List<String> wantParams;

  @JsonKey(name: "got_params", defaultValue: [], required: false)
  List<String> gotParams;

  InfoTaskCondition(this.type, this.wantParams, this.gotParams);

  factory InfoTaskCondition.fromJson(Map<String, Object?> json) =>
      _$InfoTaskConditionFromJson(json);
}
