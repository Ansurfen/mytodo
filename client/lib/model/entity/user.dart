// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: "id")
  late final int id;

  @JsonKey(name: "name")
  late final String name;

  @JsonKey(name: "email")
  late final String email;

  @JsonKey(name: "telephone", defaultValue: "")
  String? telephone;

  @JsonKey(name: "isMale", defaultValue: true)
  bool isMale = true;

  User(this.id, this.name, this.email, {this.telephone});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, Object?> toJson() => _$UserToJson(this);
}
