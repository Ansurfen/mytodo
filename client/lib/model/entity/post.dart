// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';
import 'package:my_todo/utils/time.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  @JsonKey(name: "id", required: false)
  int id;

  @JsonKey(name: "user_id")
  int uid;

  @JsonKey(name: "username", defaultValue: "")
  String username;

  @JsonKey(name: "is_male", defaultValue: false)
  bool isMale;

  @JsonKey(name: "title")
  String title;

  @JsonKey(name: "text")
  List text;

  @JsonKey(name: "created_at", fromJson: string2DateTime)
  DateTime createAt;

  @JsonKey(name: "like_count", defaultValue: 0)
  int likeCount;

  @JsonKey(name: "comment_count", defaultValue: 0)
  int commentCount;

  @JsonKey(name: "visit_count", defaultValue: 0)
  int visitCount;

  @JsonKey(name: "is_favorite", defaultValue: false)
  bool isFavorite;

  Post(
    this.id,
    this.uid,
    this.username,
    this.isMale,
    this.title,
    this.text,
    this.createAt,
    this.likeCount,
    this.commentCount,
    this.visitCount,
    this.isFavorite,
  );

  factory Post.fromJson(JsonObject json) => _$PostFromJson(json);

  JsonObject toJson() => _$PostToJson(this);
}

@JsonSerializable()
class PostComment {
  @JsonKey(name: "id")
  int id;

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

  PostComment({
    this.id = 0,
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
    this.youFavorite = false,
  });

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
