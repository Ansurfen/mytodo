// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';
import 'package:my_todo/utils/time.dart';

import 'image.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  @JsonKey(name: "id", required: false)
  int? id;

  @JsonKey(name: "uid")
  int uid;

  @JsonKey(name: "content")
  String content;

  @JsonKey(name: "created_at", fromJson: dateTimeString2Int)
  int createAt;

  @JsonKey(name: "deleted_at", defaultValue: 0)
  int deleteAt;

  @JsonKey(
      name: "image",
      defaultValue: null,
      required: false,
      fromJson: MImage.imagesFromJson)
  List<MImage>? images;

  Post(this.uid, this.content, this.createAt, this.deleteAt, this.images);

  factory Post.fromMap(JsonObject json) => _$PostFromJson(json);

  JsonObject toJson() => _$PostToJson(this);
}

@JsonSerializable()
class PostComment {
  @JsonKey(name: "_id", defaultValue: '')
  String id;

  @JsonKey(name: "pid")
  int pid;

  @JsonKey(name: "uid")
  int uid;

  @JsonKey(name: "reply", defaultValue: 0)
  int reply;

  @JsonKey(name: "username", defaultValue: '')
  String username;

  @JsonKey(name: "reply_name", defaultValue: "")
  String replyName;

  @JsonKey(name: "created_at")
  DateTime createdAt;

  @JsonKey(name: "content")
  List<String> content;

  @JsonKey(name: "replies", defaultValue: [], required: false)
  List<PostComment> replies;

  @JsonKey(name: "favorite", defaultValue: 0)
  int favorite;

  @JsonKey(name: "images", defaultValue: [])
  List<String> images;

  @JsonKey(name: "you_favorite", defaultValue: false)
  bool youFavorite;

  PostComment(
      {this.id = '',
      this.pid = 0,
      this.uid = 0,
      this.reply = 0,
      required this.username,
      this.replyName = "",
      required this.createdAt,
      required this.content,
      required this.replies,
      required this.images,
      this.favorite = 0,
      this.youFavorite = false});

  factory PostComment.fromJson(JsonObject json) {
    var v = _$PostCommentFromJson(json);
    v.images = [];
    return v;
  }

  JsonObject toJson() => _$PostCommentToJson(this);

  @override
  String toString() {
    return "id: $id, pid: $pid, uid: $uid, reply: $reply, replyName: $replyName, created: $createdAt, content: $content, replies: $replies, favorite: $favorite";
  }
}
