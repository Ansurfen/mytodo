// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/clipboard.dart';
import 'package:my_todo/utils/dialog.dart' as dialog;
import 'package:share_plus/share_plus.dart';

class TodoShare {
  static Future<dynamic> shareUri(BuildContext context, Uri uri) async {
    if (kIsWeb) {
      return webShareUri(context, uri);
    } else {
      return Share.shareUri(uri);
    }
  }

  static Future shareXFiles(
    List<XFile> files, {
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) {
    return Share.shareXFiles(
      files,
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  static Future<ShareResult> share(
    String text, {
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    return Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

Future webShareUri(BuildContext context, Uri uri) {
  Size size = MediaQuery.of(context).size;
  return dialog.showBottomSheet(context, [
    Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ThemeProvider.contrastColor(
                context,
                dark: Colors.black.withOpacity(0.5),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            width: 45,
            height: 45,
            child: const Icon(Icons.text_fields_sharp),
          ),
          const SizedBox(width: 15),
          SizedBox(
            width: size.width * 0.65,
            child: Text(
              uri.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          const SizedBox(width: 15),
          const SizedBox(
            width: 1,
            height: 14,
            child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
          ),
          const SizedBox(width: 15),
          IconButton(
            onPressed: () {
              TodoClipboard.set(uri.toString());
              Navigator.of(context).pop();
              Get.snackbar("clipboard".tr, "clipboard_tip".tr);
            },
            icon: const Icon(Icons.filter_none),
          ),
        ],
      ),
    ),
    const SizedBox(height: 30),
    Text(
      "",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 30,
        color: Colors.grey.withOpacity(0.9),
      ),
    ),
  ]);
}
