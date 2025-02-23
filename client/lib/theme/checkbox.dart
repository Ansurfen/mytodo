// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class CheckBoxStyle {
  static MaterialStateProperty<Color?> fillColor(BuildContext context,
      {Color? color}) {
    ThemeData themeData = Theme.of(context);
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.contains(MaterialState.disabled)) {
        return ThemeData.from(colorScheme: const ColorScheme.light())
            .disabledColor;
      }
      if (states.contains(MaterialState.selected)) {
        return color ?? themeData.primaryColor;
      }
      if (states.any(interactiveStates.contains)) {
        return color ?? themeData.primaryColor;
      }
      return color ?? themeData.primaryColor;
    });
  }
}
