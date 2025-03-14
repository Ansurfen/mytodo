// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "email")
  String email;

  @JsonKey(name: "telephone", defaultValue: "")
  String? telephone;

  @JsonKey(name: "is_male", defaultValue: true)
  bool isMale = true;

  User(this.id, this.name, this.email, {this.telephone});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, Object?> toJson() => _$UserToJson(this);
}
