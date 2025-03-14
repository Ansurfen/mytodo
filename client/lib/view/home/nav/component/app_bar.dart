// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'package:badges/badges.dart' as badges;
import 'package:barcode_scan2/model/scan_options.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:my_todo/i18n/exception.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/permission.dart';
import 'package:permission_handler/permission_handler.dart';

Widget notificationWidget(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 0),
      badgeAnimation: const badges.BadgeAnimation.slide(
        disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
        curve: Curves.easeInCubic,
      ),
      showBadge: true,
      badgeStyle: badges.BadgeStyle(badgeColor: Theme.of(context).primaryColor),
      badgeContent: Text(
        Mock.number(min: 1, max: 100).toString(),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          RouterProvider.viewNotification();
          // grantPermission(context, Permission.notification, allowWeb: true)
          //     .then((ok) {
          //   if (ok) {
          //     TNotification.sendJson("新消息", "....", params: {});
          //   }
          // });
        },
      ),
    ),
  );
}

Widget settingWidget() {
  return const IconButton(
    onPressed: RouterProvider.viewSetting,
    icon: Icon(Icons.settings),
  );
}

Widget multiWidget(BuildContext context) {
  return DropdownButtonHideUnderline(
    child: DropdownButton2(
      customButton: const Icon(Icons.more_vert),
      items: [
        ...MenuItems.firstItems.map(
          (item) => DropdownMenuItem<MenuItem>(
            value: item,
            child: MenuItems.buildItem(context, item),
          ),
        ),
        const DropdownMenuItem<Divider>(enabled: false, child: Divider()),
        ...MenuItems.secondItems.map(
          (item) => DropdownMenuItem<MenuItem>(
            value: item,
            child: MenuItems.buildItem(context, item),
          ),
        ),
      ],
      onChanged: (value) {
        MenuItems.onChanged(context, value! as MenuItem);
      },
      dropdownStyleData: DropdownStyleData(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).colorScheme.primary,
        ),
        offset: const Offset(0, 8),
      ),
      menuItemStyleData: MenuItemStyleData(
        customHeights: [
          ...List<double>.filled(MenuItems.firstItems.length, 48),
          8,
          ...List<double>.filled(MenuItems.secondItems.length, 48),
        ],
        padding: const EdgeInsets.only(left: 16, right: 16),
      ),
    ),
  );
}

class MenuItem {
  const MenuItem({required this.text, required this.icon});

  final String text;
  final IconData icon;
}

abstract class MenuItems {
  static List<MenuItem> firstItems = [qr, share, settings];
  static const List<MenuItem> secondItems = [logout];

  static MenuItem qr = MenuItem(
    text: 'scan_qr'.tr,
    icon: Icons.qr_code_rounded,
  );
  static const share = MenuItem(text: 'Share', icon: Icons.share);
  static const settings = MenuItem(text: 'Settings', icon: Icons.settings);
  static const logout = MenuItem(text: 'Log Out', icon: Icons.logout);

  static Widget buildItem(BuildContext context, MenuItem item) {
    return Row(
      children: [
        Icon(
          item.icon,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.text,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  static Future<void> onChanged(BuildContext context, MenuItem item) async {
    if (identical(item, MenuItems.qr)) {
      await openQRScanner(context).then((value) {
        if (value.isNotEmpty) {
          EasyLoading.showSuccess(value);
        }
      });
    } else if (identical(item, MenuItems.settings)) {
      try {
        await test(context);
      } catch (e) {
        if (e is MissingPluginException) {
          showTipDialog(context, content: "请使用其他平台");
        }
      }
    } else if (identical(item, MenuItems.share)) {
      // 处理分享逻辑
    } else if (identical(item, MenuItems.logout)) {
      // 处理退出逻辑
    }
  }
}

Future<String> openQRScanner(BuildContext context) async {
  Completer<String> completer = Completer();
  try {
    ScanOptions options = ScanOptions(
      strings: {
        'cancel': 'cancel'.tr,
        'flash_on': 'flash_on'.tr,
        'flash_off': 'flash_off'.tr,
      },
    );
    if (await grantPermission(context, Permission.camera)) {
      var result = await BarcodeScanner.scan(options: options);
      if (!completer.isCompleted) {
        completer.complete(result.rawContent);
      }
    } else {
      if (!completer.isCompleted) {
        completer.complete("");
      }
    }
  } catch (e) {
    if (e is UnsupportedError) {
      showError(e.tr);
    } else if (e is MissingPluginException) {
      showError(e.tr);
    } else if (e is PlatformException) {}
    if (!completer.isCompleted) {
      completer.complete("");
    }
  }
  return completer.future;
}
