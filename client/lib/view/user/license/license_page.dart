// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/theme/color.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({super.key});

  @override
  State<StatefulWidget> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        border: Border(
            bottom: BorderSide(
                color: themeData.brightness == Brightness.light
                    ? HexColor.fromInt(0xceced2)
                    : Colors.grey.withOpacity(0.8))),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        middle: Text(
          "user_license".tr,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: themeData.colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
          "license...",
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        ),
      ),
    );
  }
}
