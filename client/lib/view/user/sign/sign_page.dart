// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/component/form/form_title.dart';
import 'package:my_todo/component/icon.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/checkbox.dart';
import 'package:my_todo/view/user/sign/sign_controller.dart';
import 'package:get/get.dart';
import 'package:my_todo/utils/guard.dart';
import '../../../component/form/form_button.dart';
import '../../../component/form/form_input_field.dart';

class SignPage extends StatefulWidget {
  const SignPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  SignController controller = Get.find<SignController>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: _signTitle()),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: controller.loginFromKey,
                  child: Column(
                    children: [
                      FormInputField(
                        bgColor: Colors.transparent,
                        labelText: 'email'.tr,
                        hintText: 'email.tip'.tr,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'email.required'.tr;
                          }
                          if (!EmailValidator.validate(textValue)) {
                            return 'email.valid'.tr;
                          }
                          return null;
                        },
                        onSaved: (v) {
                          controller.email = v!;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      FormInputField(
                        bgColor: Colors.transparent,
                        labelText: 'password'.tr,
                        hintText: 'password.tip'.tr,
                        obscureText: true,
                        suffixIcon: true,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'password.required'.tr;
                          }
                          return null;
                        },
                        onSaved: (v) {
                          controller.password = v!;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        width: size.width * 0.80,
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: RouterProvider.viewUserForget,
                          child: Text(
                            'forget_password'.tr,
                            style: const TextStyle(
                              color: Color(0xff939393),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Obx(() => FormButton(
                            innerText: 'sign_up'.tr,
                            onPressed: () async {
                              await controller.login(context);
                            },
                            selectable: controller.acceptLicense.value,
                          )),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        width: size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: controller.acceptLicense.value,
                              onChanged: (value) {
                                setState(() {
                                  controller.acceptLicense.value =
                                      !controller.acceptLicense.value;
                                });
                              },
                              fillColor: CheckBoxStyle.fillColor(context),
                              shape: const CircleBorder(),
                            ),
                            Text(
                              "read_license".tr,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff939393),
                                  fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: RouterProvider.viewUserLicense,
                              child: Text(
                                'user_license'.tr,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.height * 0.3, left: size.width * 0.7),
                        child: TextButton(
                            onPressed: () {
                              Guard.offlineLoginAndGo();
                            },
                            child: Row(
                              children: [
                                Text('offline_mode'.tr,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signTitle() {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormTitle(
              title: "sign_up".tr,
              // left: size.width * 0.08,
              right: size.width * 0.2,
              top: size.height * 0.03,
            ),
            FormTitle(
              title: "sign_up.tip".tr,
              fontSize: 15,
              // left: size.width * 0.08,
              top: size.height * 0.01,
              bottom: size.height * 0.03,
            ),
          ],
        ),
        todoTextIconButton(context,
            onPressed: RouterProvider.viewSetting,
            icon: Icons.settings,
            size: 50),
      ],
    );
  }
}
