// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';

class CheckBoxStyle {
  static WidgetStateProperty<Color?> fillColor(
    BuildContext context, {
    Color? color,
  }) {
    ThemeData themeData = Theme.of(context);
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.contains(WidgetState.disabled)) {
        return ThemeData.from(
          colorScheme: const ColorScheme.light(),
        ).disabledColor;
      }
      if (states.contains(WidgetState.selected)) {
        return color ?? themeData.primaryColor;
      }
      if (states.any(interactiveStates.contains)) {
        return color ?? themeData.primaryColor;
      }
      return color ?? themeData.primaryColor;
    });
  }
}
