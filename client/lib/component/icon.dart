// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/theme/provider.dart';

Icon todoTextIcon(BuildContext context, {IconData? icon, double? size}) {
  return Icon(
    icon,
    size: size,
    color: Theme.of(context).colorScheme.onPrimary,
  );
}

Icon todoLeadingIcon(BuildContext context, {IconData? icon, double? size}) {
  return Icon(
    icon,
    size: size,
    color: ThemeProvider.contrastColor(context,
        light: Theme.of(context).colorScheme.onPrimary,
        dark: Theme.of(context).primaryColor),
  );
}

IconButton todoTextIconButton(BuildContext context,
    {required VoidCallback? onPressed, IconData? icon, double? size}) {
  return IconButton(
      onPressed: onPressed,
      iconSize: size,
      icon: todoTextIcon(context, icon: icon, size: size));
}

IconButton todoLeadingIconButton(BuildContext context,
    {required VoidCallback? onPressed, IconData? icon, double? size}) {
  return IconButton(
      onPressed: onPressed,
      iconSize: size,
      icon: todoLeadingIcon(context, icon: icon, size: size));
}

class TodoIcon {
  static plain(BuildContext context, {IconData? icon, double? size}) {
    return Icon(
      icon,
      size: size,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
