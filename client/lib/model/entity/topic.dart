// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic {
  @JsonKey(name: "icon")
  String icon;

  @JsonKey(name: "id", required: false)
  int id;

  @JsonKey(name: "creator")
  int creator;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "description")
  String description;

  @JsonKey(name: "tags", defaultValue: [])
  List<String>? tags;

  @JsonKey(name: "invite_code")
  String inviteCode;

  // @JsonKey(name: "createdAt")
  // DateTime

  Topic(
    this.icon,
    this.id,
    this.creator,
    this.name,
    this.description,
    this.tags,
    this.inviteCode,
  );

  factory Topic.fromJson(JsonObject json) => _$TopicFromJson(json);

  JsonObject toJson() => _$TopicToJson(this);
}

@JsonSerializable()
class TopicMember {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "is_male")
  bool isMale;

  @JsonKey(name: "role", defaultValue: 0)
  int role;

  TopicMember(this.id, this.name, this.isMale, this.role);

  factory TopicMember.fromJson(JsonObject json) => _$TopicMemberFromJson(json);

  JsonObject toJson() => _$TopicMemberToJson(this);
}
