// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/color.dart';

class BoxStyle {
  static Color backgroundColor1(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black;
  }

  static Color backgroundColor2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? HexColor.fromInt(0xf5f5f5)
        : HexColor.fromInt(0x1c1c1e);
  }
}
