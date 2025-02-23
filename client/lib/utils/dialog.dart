// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_picker/picker.dart';
import 'package:get/get.dart';
import 'package:my_todo/i18n/exception.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/clipboard.dart';

Future showTipDialog(BuildContext context,
    {String? content, void Function()? onPressed}) {
  return showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'tip'.tr,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        content: Text(content ?? ""),
        actions: [
          TextButton(
            onPressed: onPressed ??
                () {
                  Navigator.of(context).pop();
                },
            child: Text(
              'confirm'.tr,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      );
    },
  );
}

Future showCopyableTipDialog(BuildContext context,
    {String? content, void Function()? onPressed}) {
  return showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'tip'.tr,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        content: Text(content ?? ""),
        actions: [
          TextButton(
            onPressed: onPressed ??
                () {
                  TodoClipboard.set(content ?? "");
                  Navigator.of(context).pop();
                },
            child: Text(
              'copy'.tr,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      );
    },
  );
}

Future showBottomSheet(BuildContext context, List<Widget> widgets,
    {BoxConstraints? constraints}) {
  Size size = MediaQuery.of(context).size;
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: constraints,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF2F3F8)
                : HexColor.fromInt(0x1c1c1e),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: size.height / 2.0,
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 50,
                  minWidth: 10,
                ),
                child: const Divider(
                  height: 25,
                  thickness: 3,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ...widgets
            ],
          ),
        );
      });
}

void showDateTimePicker(BuildContext context, String title,
    {ValueChanged<String>? onConfirm, void Function()? onCancel}) {
  int year = DateTime.now().year;
  ThemeData themeData = Theme.of(context);
  Picker(
      adapter: DateTimePickerAdapter(
        type: PickerDateTimeType.kMDYHM,
        isNumberMonth: true,
        yearSuffix: "year".tr,
        monthSuffix: "month".tr,
        daySuffix: "day".tr,
        hourSuffix: "hour".tr,
        minuteSuffix: "minute".tr,
        secondSuffix: "second".tr,
        minHour: 0,
        maxHour: 23,
        yearBegin: year,
        yearEnd: year + 100,
      ),
      backgroundColor: themeData.brightness == Brightness.light
          ? Colors.white
          : HexColor.fromInt(0x1c1c1e),
      selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
      textStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      headerColor: Theme.of(context).brightness == Brightness.light
          ? HexColor.fromInt(0xf5f5f5)
          : HexColor.fromInt(0x1c1c1e),
      cancelTextStyle: const TextStyle(color: Colors.grey),
      confirmTextStyle: const TextStyle(color: Colors.grey),
      // headerColor: Theme.of(context).primaryColor.withOpacity(0.9),
      title: Text(
        title.tr,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      onCancel: onCancel,
      onConfirm: (Picker picker, List value) {
        if (onConfirm != null) {
          onConfirm(picker.adapter.getText());
        }
      }).showBottomSheet(context);
}

void showError(String msg,
    {EasyLoadingMaskType maskType = EasyLoadingMaskType.none}) {
  EasyLoading.showError(msg, maskType: maskType, dismissOnTap: true);
}

void showException(Exception e,
    {EasyLoadingMaskType maskType = EasyLoadingMaskType.none}) {
  EasyLoading.showError(e.tr, maskType: maskType, dismissOnTap: true);
}

void showLoading({EasyLoadingMaskType maskType = EasyLoadingMaskType.clear}) {
  EasyLoading.show(status: "loading".tr, maskType: maskType);
}

void showTextDialog(BuildContext context,
    {required String title,
    required Widget content,
    VoidCallback? onCancel,
    VoidCallback? onConfirm}) {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: content,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: onCancel,
          child: Text(
            'cancel'.tr,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: onConfirm,
          child: Text(
            'confirm'.tr,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        )
      ],
    ),
  );
}

void showSingleTextField(BuildContext context,
    {TextEditingController? controller,
    required String title,
    String? hintText,
    VoidCallback? onCancel,
    VoidCallback? onConfirm}) {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: onCancel,
          child: Text(
            'cancel'.tr,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: onConfirm,
          child: Text(
            'confirm'.tr,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        )
      ],
    ),
  );
}

Widget dialogAction(
    {void Function()? onTap, required IconData icon, required String text}) {
  return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.grey))
        ],
      ));
}

void showAlert(BuildContext context,
    {String title = "",
    String content = "",
    VoidCallback? onCancel,
    VoidCallback? onConfirm}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          isDefaultAction: true,
          onPressed: () {
            if (onCancel != null) {
              onCancel();
            }
            Navigator.pop(context);
          },
          child: Text(
            'No'.tr,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            if (onConfirm != null) {
              onConfirm();
            }
            Navigator.pop(context);
          },
          child: Text('Yes'.tr),
        ),
      ],
    ),
  );
}
