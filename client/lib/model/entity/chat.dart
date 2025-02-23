// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  @JsonKey(name: "_id", defaultValue: '')
  String id;

  @JsonKey(name: "from")
  int from;

  @JsonKey(name: "to")
  int to;

  @JsonKey(name: "reply", defaultValue: '')
  String reply;

  @JsonKey(name: "reply_content", defaultValue: "")
  String replyContent;

  @JsonKey(name: "content")
  List<String> content;

  @JsonKey(name: "created_at", includeToJson: false, includeFromJson: true)
  DateTime? time;

  Chat(
      {this.id = '',
      required this.from,
      required this.to,
      this.reply = '',
      this.replyContent = "",
      required this.content,
      this.time});

  JsonObject toJson() => _$ChatToJson(this);

  factory Chat.fromJson(JsonObject json) => _$ChatFromJson(json);
}
