// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
class BaseResponse {
  final int? code;
  final String? msg;

  BaseResponse(Map<String, dynamic> json)
      : code = json['code'],
        msg = json['msg'];

  @override
  String toString() {
    return "code: $code, msg: $msg";
  }
}
