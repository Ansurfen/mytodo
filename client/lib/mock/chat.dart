// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:my_todo/mock/provider.dart';

List friends = List.generate(
    13,
    (index) => {
          "name": Mock.username(),
          "dp": "assets/images/flutter.svg",
          "status": "Anything could be here",
          "isAccept": Mock.boolean(),
        });
