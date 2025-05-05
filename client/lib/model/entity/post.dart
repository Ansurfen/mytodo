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

  @JsonKey(name: "post_id")
  int postId;

  @JsonKey(name: "user_id")
  int userId;

  @JsonKey(name: "reply_id", defaultValue: 0)
  int replyId;

  @JsonKey(name: "username", defaultValue: '')
  String username;

  @JsonKey(name: "reply_name", defaultValue: "")
  String replyName;

  @JsonKey(name: "created_at")
  DateTime createdAt;

  @JsonKey(name: "text")
  String text;

  @JsonKey(name: "replies", defaultValue: [], required: false)
  List<PostComment> replies;

  @JsonKey(name: "reply_count", defaultValue: 0)
  int replyCount;

  @JsonKey(name: "like_count")
  int likeCount;

  @JsonKey(name: "is_favorite")
  bool isFavorite;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.replyId,
    required this.username,
    this.replyName = "",
    this.replyCount = 0,
    required this.createdAt,
    required this.text,
    required this.replies,
    required this.likeCount,
    required this.isFavorite,
  });

  factory PostComment.fromJson(JsonObject json) {
    var v = _$PostCommentFromJson(json);
    return v;
  }

  JsonObject toJson() => _$PostCommentToJson(this);
}
