// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/form/form_title.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/user.dart';
import 'package:my_todo/view/user/forget/forget_controller.dart';
import '../../../component/form/form_button.dart';
import '../../../component/form/form_input_field.dart';

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForgetPage();
}

class _ForgetPage extends State<ForgetPage> {
  ForgetController controller = Get.find<ForgetController>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: Column(
        children: [
          // const PageHeader(),
          Expanded(
            child: Container(
              // decoration: BoxDecoration(
              //   color: HexColor("#1e2434"),
              //   borderRadius: const BorderRadius.vertical(
              //     top: Radius.circular(20),
              //   ),
              // ),
              color: Theme.of(context).colorScheme.primary,
              child: SingleChildScrollView(
                child: Form(
                  key: controller.forgetPasswordFormKey,
                  child: Column(
                    children: [
                      FormTitle(
                        title: 'forgot_password'.tr,
                        left: size.width * 0.08,
                        right: size.width * 0.08,
                        top: 60,
                        bottom: 60,
                      ),
                      FormInputField(
                        labelText: 'email'.tr,
                        hintText: 'email.tip'.tr,
                        isDense: true,
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
                        height: 20,
                      ),
                      FormButton(
                        innerText: 'submit'.tr,
                        onPressed: controller.sendCaptcha,
                        selectable: true,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => RouterProvider.offNamed(UserRouter.sign),
                          child: Text(
                            'back_to_login'.tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff939393),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
}
