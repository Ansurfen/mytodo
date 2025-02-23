// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:my_todo/config.dart';
import 'package:my_todo/utils/guard.dart';
import 'dart:io';

import 'package:my_todo/utils/picker.dart';

Image file2Image(TFile file, {BoxFit? fit, double? width, double? height}) {
  if (kIsWeb) {
    return Image.network(
      file.x.path,
      fit: fit,
      width: width,
      height: height,
    );
  } else {
    return Image.file(
      File(file.x.path),
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class TodoImage {
  static ImageProvider userProfile(int id) {
    // if (Guard.isOffline()) {
    //   return const Svg("assets/images/flutter.svg");
    // }
    return NetworkImage("${TodoConfig.baseUri}/user/profile/$id");
  }
}

Widget selectImagePicker({double size = 100}) {
  return Container(
    height: size,
    width: size,
    color: Colors.grey.withOpacity(0.5),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image,
            size: 50,
            color: Colors.white38,
          ),
          Text("select_image".tr)
        ],
      ),
    ),
  );
}
