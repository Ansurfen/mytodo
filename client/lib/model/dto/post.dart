// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/model/entity/image.dart';
import 'package:my_todo/utils/time.dart';

part 'post.g.dart';

@JsonSerializable()
class GetPostDto {
  @JsonKey(name: "id", defaultValue: 0)
  int id;

  @JsonKey(name: "uid", defaultValue: 0)
  int uid;

  @JsonKey(name: "username", defaultValue: "")
  String username;

  @JsonKey(name: "isMale", defaultValue: true)
  bool isMale;

  @JsonKey(name: "created_at", fromJson: string2DateTime)
  DateTime createAt;

  @JsonKey(name: "content", defaultValue: "")
  String content;

  @JsonKey(name: "image", defaultValue: [], fromJson: MImage.imagesFromJson)
  late List<MImage> images;

  @JsonKey(name: "fc", defaultValue: 0)
  int favoriteCnt;

  @JsonKey(name: "cc", defaultValue: 0)
  int commentCnt;

  @JsonKey(name: "is_favorite", defaultValue: false)
  bool isFavorite;

  GetPostDto(
      this.id,
      this.uid,
      this.username,
      this.isMale,
      this.createAt,
      this.content,
      this.images,
      this.favoriteCnt,
      this.commentCnt,
      this.isFavorite);

  Map<String, dynamic> toJson() => _$GetPostDtoToJson(this);

  factory GetPostDto.fromJson(Map<String, dynamic> json) =>
      _$GetPostDtoFromJson(json);
}
