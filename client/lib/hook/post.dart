// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/utils/guard.dart';

class PostHook {
  static StreamSubscription<Post> subscribeSnapshot(
      {ValueChanged<Post>? onData}) {
    return Guard.eventBus.on<Post>().listen(onData);
  }

  static void updateSnapshot(Post v) {
    Guard.eventBus.fire(v);
  }
}
