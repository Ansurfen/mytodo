// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/model/entity/user.dart';
import 'package:my_todo/router/home.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/utils/guard.dart';

class EditController extends GetxController {
  Image? _profileImage;
  TFile? tFile;
  TextEditingController nameController = TextEditingController(
    text: Guard.u?.name,
  );
  TextEditingController emailController = TextEditingController(
    text: Guard.u?.email,
  );
  TextEditingController telephoneController = TextEditingController(
    text: Guard.u?.telephone,
  );
  TextEditingController aboutController = TextEditingController(
    text: Guard.u?.about,
  );
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  ImageProvider<Object>? profileImage() {
    if (Guard.isLogin() && _profileImage == null) {
      if (Guard.u != null) {
        _profileImage = userProfile(Guard.u!.id);
      }
      return _profileImage?.image;
    }
    return _profileImage?.image;
  }

  Future<bool> pickProfileImage() async {
    bool res = false;
    await imagePicker().then((file) {
      if (file != null) {
        tFile = file;
        _profileImage = file2Image(file);
        res = true;
      }
    });
    return res;
  }

  void commit(BuildContext context) {
    if (!Guard.isLogin()) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('tip'.tr),
            content: Text('commit_not_login'.tr),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    RouterProvider.to(HomeRouter.nav);
                  }
                },
                child: Text('confirm'.tr),
              ),
            ],
          );
        },
      );
      return;
    }
    User user = Guard.u!;
    user.name = nameController.text;
    user.telephone = telephoneController.text;
    user.email = emailController.text;
    user.about = aboutController.text;

    userEditRequest(u: user, profile: tFile)
        .then((v) {
          userDetailRequest().then((v) {
            Guard.setUser(v);
          });
        })
        .onError((error, stackTrace) {
          showTipDialog(context, content: error.toString());
        });
  }

  void editPassword(BuildContext context) {
    userEditPasswordRequest(password: passwordController.text)
        .then((v) {
          showTipDialog(context, content: 'password_edited'.tr);
        })
        .onError((error, stackTrace) {
          showTipDialog(context, content: error.toString());
        });
  }
}
