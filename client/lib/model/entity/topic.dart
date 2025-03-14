// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic {
  @JsonKey(name: "id", required: false)
  int? id;

  @JsonKey(name: "creator")
  int creator;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "description")
  String description;

  @JsonKey(name: "tags")
  List<String>? tags;

  // @JsonKey(name: "createdAt")
  // DateTime 

  Topic(this.creator, this.name, this.description, {this.tags});

  factory Topic.fromJson(JsonObject json) => _$TopicFromJson(json);

  JsonObject toJson() => _$TopicToJson(this);
}

@JsonSerializable()
class TopicMember {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "name")
  String name;

  TopicMember({required this.id, required this.name});

  factory TopicMember.fromJson(JsonObject json) => _$TopicMemberFromJson(json);

  JsonObject toJson() => _$TopicMemberToJson(this);
}
