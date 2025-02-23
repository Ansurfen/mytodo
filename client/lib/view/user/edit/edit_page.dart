// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/form/form_input_field.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/view/user/edit/edit_controller.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  EditController controller = Get.find<EditController>();

  @override
  Widget build(BuildContext context) {
    return todoCupertinoScaffold(
        appBar: todoCupertinoNavBarWithBack(
          context,
          middle: Text(
            "edit".tr,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: controller.profileImage(),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            controller.pickProfileImage().then((ok) {
                              if (ok) {
                                setState(() {});
                              } else {
                                showTipDialog(context,
                                    content: "upload_image_err".tr);
                              }
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : HexColor.fromInt(0x1c1c1e),
                                  width: 3),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              Icons.camera_alt_sharp,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : HexColor.fromInt(0x1c1c1e),
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FormInputField(
                bgColor: Colors.transparent,
                labelText: 'username'.tr,
                hintText: 'username.tip'.tr,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'username.required'.tr;
                  }
                  return null;
                },
                value: Guard.userName(),
                onSaved: (v) {
                  controller.emailController.text = v!;
                },
              ),
              const SizedBox(height: 15),
              FormInputField(
                bgColor: Colors.transparent,
                labelText: 'telephone'.tr,
                hintText: 'telephone.tip'.tr,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'telephone.required'.tr;
                  }
                  return null;
                },
                value: Guard.userTelephone(),
                onSaved: (v) {
                  controller.emailController.text = v!;
                },
              ),
              const SizedBox(height: 15),
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
                value: Guard.userEmail(),
                onSaved: (v) {
                  controller.emailController.text = v!;
                },
              ),
              const SizedBox(height: 30),
              ShadowButton(
                onTap: controller.commit(context),
                text: 'save'.tr,
              )
            ],
          ),
        ),
        context: context);
  }
}
