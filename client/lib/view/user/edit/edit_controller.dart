// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/component/image.dart';
import 'package:my_todo/router/home.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/picker.dart';
import 'package:my_todo/utils/guard.dart';

class EditController extends GetxController {
  Image? _profileImage;
  TFile? tFile;
  TextEditingController userController = TextEditingController(
    text: Guard.u?.name,
  );
  TextEditingController emailController = TextEditingController(
    text: Guard.u?.email,
  );
  TextEditingController telephoneController = TextEditingController(
    text: Guard.u?.telephone,
  );

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

  Future Function() commit(BuildContext context) {
    return () async {
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
      userEdit(
            UserEditRequest(
              userController.text,
              emailController.text,
              telephone: telephoneController.text,
              profile: tFile,
            ),
          )
          .then((value) {
            userGet(UserGetRequest())
                .then((res) {
                  Guard.setUser(res.user);
                })
                .onError((error, stackTrace) {
                  print(error);
                });
          })
          .onError((error, stackTrace) {
            showTipDialog(context, content: error.toString());
          });
    };
  }
}
