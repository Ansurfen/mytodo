// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';

part 'notify.g.dart';

@JsonSerializable()
class Notify {
  @JsonKey(name: "id", defaultValue: 0)
  int id;

  @JsonKey(name: "type", defaultValue: 0)
  int type;

  @JsonKey(name: "status", defaultValue: 0)
  int status;

  @JsonKey(name: "created_at")
  DateTime createdAt;

  @JsonKey(name: "param", defaultValue: '')
  String param;

  @JsonKey(name: "title", defaultValue: '')
  String title;

  @JsonKey(name: "content", defaultValue: '')
  String content;

  Notify(
      {required this.id,
      required this.type,
      required this.status,
      required this.createdAt,
      this.param = '',
      this.title = '',
      this.content = ''});

  factory Notify.fromJson(JsonObject json) => _$NotifyFromJson(json);
}

enum NotifyType {
  unknown(0),
  addFriend(1),
  inviteFriend(2),
  text(3);

  const NotifyType(this.value);
  final int value;

  static NotifyType getType(int v) {
    switch (v) {
      case 1:
        return NotifyType.addFriend;
      case 2:
        return NotifyType.inviteFriend;
      case 3:
        return NotifyType.text;
    }
    return NotifyType.unknown;
  }
}

enum NotifyStatus { unknown, wait, confirm, refuse }
