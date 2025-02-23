// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:my_todo/api/user.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';

class SignController extends GetxController {
  var loginFromKey = GlobalKey<FormState>();
  Rx<bool> acceptLicense = Rx(false);
  late String email;
  late String password;

  Future login(BuildContext context) async {
    if ((loginFromKey.currentState as FormState).validate()) {
      (loginFromKey.currentState as FormState).save();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('loading...')),
      // );
      userSign(UserSignRequest(email, password)).then((res) {
        if (res.code != 200) {
          showTipDialog(context, content: res.msg);
          return;
        } else if (res.jwt.isEmpty) {
          showTipDialog(context, content: "Invalid JWT");
          return;
        }
        Guard.jwt = res.jwt;
        userGet(UserGetRequest()).then((res) {
          Guard.setUser(res.user);
        }).onError((error, stackTrace) {
          showTipDialog(context, content: error.toString());
          return;
        });
        Guard.logInAndGo(res.jwt);
      }).onError((error, stackTrace) {
        showTipDialog(context, content: error.toString());
      });
    }
  }
}
