// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/utils/guard.dart';

class TopicHook {
  static StreamSubscription<GetTopicDto> subscribeSnapshot(
      {ValueChanged<GetTopicDto>? onData}) {
    return Guard.eventBus.on<GetTopicDto>().listen(onData);
  }

  static void updateSnapshot(GetTopicDto v) {
    Guard.eventBus.fire(v);
  }
}
