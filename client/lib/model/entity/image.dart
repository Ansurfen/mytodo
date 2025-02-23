// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';

part 'image.g.dart';

@JsonSerializable()
class MImage {
  @JsonKey(name: "name", defaultValue: "")
  String name;

  @JsonKey(name: "path", defaultValue: "")
  String path;

  MImage(this.name, this.path);

  factory MImage.fromJson(JsonObject json) => _$MImageFromJson(json);

  JsonObject toJson() => _$MImageToJson(this);

  static imagesFromJson(List? images) {
    if (images == null) {
      return null;
    }
    return images.map((e) => MImage.fromJson(e)).toList();
  }
}
