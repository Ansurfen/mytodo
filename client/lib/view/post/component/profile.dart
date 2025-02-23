// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/router/provider.dart';

Widget genderBadge(bool isMale) {
  return Container(
    decoration: BoxDecoration(
      color: isMale ? Colors.blue : Colors.pink,
      borderRadius: BorderRadius.circular(8),
    ),
    height: 15,
    width: 15,
    child: Center(
      child: Icon(
        isMale ? Icons.male : Icons.female,
        color: Colors.white70,
        size: 13,
      ),
    ),
  );
}

Widget userProfile({required bool isMale, required int id}) {
  return Stack(
    children: [
      GestureDetector(
        onTap: () {
          RouterProvider.viewUserProfile(id);
        },
        child: CircleAvatar(
          backgroundImage: TodoImage.userProfile(id),
          radius: 25,
        ),
      ),
      Positioned(bottom: 0.0, right: 5.0, child: genderBadge(isMale))
    ],
  );
}
