// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatSnapshotDTO {
  @JsonKey(name: "count", defaultValue: 0)
  int count;

  @JsonKey(name: "lastAt")
  DateTime lastAt;

  @JsonKey(name: "lastMsg")
  List<String> lastMsg;

  @JsonKey(name: "username")
  String username;

  @JsonKey(name: "uid")
  int uid;

  ChatSnapshotDTO(
      {this.count = 0,
      required this.lastAt,
      required this.lastMsg,
      required this.username,
      required this.uid});
}
