// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:my_todo/router/provider.dart';

class ImageView {
  static Widget svg(String path, {double? width, double? height}) {
    return GestureDetector(
        onTap: () {
          RouterProvider.viewPhoto(type: PhotoType.svg, url: path);
        },
        child: Image(
          image: Svg(path),
          width: width,
          height: height,
        ));
  }

  static Widget network(String path,
      {BoxFit? fit, double? width, double? height}) {
    return GestureDetector(
        onTap: () {
          RouterProvider.viewPhoto(type: PhotoType.img, url: path);
        },
        child: Image(
          image: NetworkImage(path),
          width: width,
          height: height,
          fit: fit,
        ));
  }

  static Widget asset(String path,
      {BoxFit? fit, double? width, double? height}) {
    return GestureDetector(
        onTap: () {
          RouterProvider.viewPhoto(type: PhotoType.img, url: path);
        },
        child: Image(
          image: AssetImage(path),
          width: width,
          height: height,
          fit: fit,
        ));
  }
}
