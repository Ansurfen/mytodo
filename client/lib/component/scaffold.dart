// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';

const todoUnderlineTextStyle = InputDecorationTheme();

class InputStyle {
  static InputDecoration underlineTextStyle(
    BuildContext context,
    String labelText, {
    String? hintText,
  }) {
    Color color = ThemeProvider.contrastColor(
      context,
      light: Colors.grey,
      dark: Colors.white,
    );
    return InputDecoration(
      labelStyle: const TextStyle(color: Colors.grey),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
      labelText: labelText,
      hintText: hintText,
    );
  }
}

CupertinoNavigationBar todoCupertinoNavBar(
  BuildContext context, {
  Widget? leading,
  Widget? middle,
  Widget? trailing,
}) {
  return CupertinoNavigationBar(
    leading: leading,
    middle: middle,
    trailing: trailing,
    border: Border(
      bottom: BorderSide(
        color: ThemeProvider.contrastColor(
          context,
          light: HexColor.fromInt(0xceced2),
          dark: Colors.grey.withOpacity(0.8),
        ),
      ),
    ),
    automaticBackgroundVisibility: false,
    backgroundColor: Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 255),
  );
}

CupertinoNavigationBar todoCupertinoNavBarWithBack(
  BuildContext context, {
  Widget? middle,
  Widget? trailing,
}) {
  ThemeData themeData = Theme.of(context);
  return todoCupertinoNavBar(
    context,
    leading: IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back_ios,
        size: 20,
        color:
            themeData.brightness == Brightness.light
                ? themeData.colorScheme.onPrimary
                : themeData.primaryColor,
      ),
    ),
    middle: middle,
    trailing: trailing,
  );
}

CupertinoPageScaffold todoCupertinoScaffold({
  required BuildContext context,
  required Widget body,
  ObstructingPreferredSizeWidget? appBar,
}) {
  return CupertinoPageScaffold(
    backgroundColor: ThemeProvider.contrastColor(
      context,
      light: HexColor.fromInt(0xF2F2F7),
    ),
    navigationBar: appBar,
    child: SafeArea(child: body),
  );
}

PreferredSizeWidget todoAppBar(
  BuildContext context, {
  double? titleSpacing,
  double? elevation,
  Widget? title,
  Widget? leading,
  List<Widget>? actions,
}) {
  return AppBar(
    title: title,
    titleSpacing: titleSpacing,
    leading: leading,
    actions: actions,
    elevation: elevation,
    backgroundColor: Theme.of(context).colorScheme.primary,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Container(
        color: ThemeProvider.contrastColor(
          context,
          light: HexColor.fromInt(0xceced2),
          dark: Colors.grey.withOpacity(0.8),
        ),
        height: 1.0,
      ),
    ),
  );
}

TabBar todoTabBar(
  BuildContext context, {
  TabController? controller,
  required List<Widget> tabs,
}) {
  return TabBar(
    tabs: tabs,
    controller: controller,
    labelColor: Theme.of(context).primaryColor,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Theme.of(context).primaryColor,
    isScrollable: true,
    indicatorSize: TabBarIndicatorSize.label,
  );
}

Scaffold todoScaffold(
  BuildContext context, {
  double actionSpacing = 20,
  double actionBorderSpacing = 10,
  Widget? body,
  AppBar? appBar,
}) {
  return Scaffold(
    appBar: todoAppBar(
      context,
      leading: appBar?.leading,
      title: appBar?.title,
      titleSpacing: appBar?.titleSpacing,
      elevation: appBar?.elevation,
      actions:
          appBar?.actions != null
              ? todoIconButtonActions(
                appBar!.actions!,
                spacing: actionBorderSpacing,
                borderSpacing: actionBorderSpacing,
              )
              : null,
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    body: body,
  );
}

List<Widget> todoIconButtonActions(
  List<Widget> buttons, {
  double spacing = 20,
  double borderSpacing = 10,
}) {
  List<Widget> actions = [];
  for (int i = 0; i < buttons.length; i++) {
    actions.add(buttons[i]);
    if (i + 1 < buttons.length) {
      actions.add(SizedBox(width: spacing));
    }
  }
  actions.add(SizedBox(width: borderSpacing));
  return actions;
}
