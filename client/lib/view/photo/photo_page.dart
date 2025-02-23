// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  late String netWorkImage;
  late bool isSvg;
  bool isNetwork = false;

  @override
  void initState() {
    super.initState();
    isSvg = Get.parameters["type"] == "svg" ? true : false;
    try {
      Uri.parse(Get.parameters["url"]!);
      isNetwork = true;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> img;
    String url = Get.parameters["url"]!;
    if (isSvg) {
      img = Svg(url);
    } else if (isNetwork) {
      img = NetworkImage(url);
    } else {
      img = AssetImage(url);
    }
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: todoAppBar(context,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: themeData.brightness == Brightness.light
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).primaryColor,
          ),
          actions: [
            settingWidget(),
          ]),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: GestureDetector(
          onLongPress: () {
            if (isNetwork) {
              TodoShare.shareUri(context, Uri.parse(url));
            }
          },
          child: PhotoView(
            imageProvider: img,
          )),
    );
  }
}
