// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/form/form_input_field.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/view/user/edit/edit_controller.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:settings_ui/settings_ui.dart';

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
        trailing: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.cloud_upload,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 30), child: userProfile()),
            SettingsList(
              shrinkWrap: true,
              applicationType: ApplicationType.cupertino,
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(
                  title: Text("common".tr),
                  tiles: [
                    SettingsTile(title: Text("username".tr)),
                    SettingsTile(title: Text("phone_number".tr)),
                    SettingsTile(title: Text("email".tr)),
                  ],
                ),
                SettingsSection(
                  title: Text("security".tr),
                  tiles: [
                    SettingsTile.navigation(
                      title: Text("edit_password"),
                      onPressed: (ctx) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          constraints: BoxConstraints(
                            minWidth: double.infinity,
                            minHeight: MediaQuery.sizeOf(context).height - 180,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height / 2,
                              clipBehavior: Clip.antiAlias,
                              constraints: BoxConstraints(
                                minWidth: double.infinity,
                                minHeight:
                                    MediaQuery.sizeOf(context).height - 180,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeProvider.contrastColor(
                                  context,
                                  light: HexColor.fromInt(0xf5f5f5),
                                  dark: HexColor.fromInt(0x1c1c1e),
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                            ),
                                          ),
                                          Text(
                                            "edit_password".tr,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: TextButton(
                                          onPressed: _submit,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: lighten(
                                                Theme.of(context).primaryColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ), 
                                            ),
                                            child: Text(
                                              "save".tr,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary, 
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 20,
                                    ),
                                    child: Column(
                                      children: [
                                        PasswordTextField(
                                          controller: _passwordController,
                                          labelText: "新密码",
                                        ),
                                        SizedBox(height: 15),
                                        PasswordTextField(
                                          controller:
                                              _confirmPasswordController,
                                          labelText: "确认密码",
                                        ),
                                        if (_errorText != null) // 显示错误信息
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              _errorText!,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      context: context,
    );
  }

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _errorText;

  void _submit() {
    Get.back();
  }

  void _validatePasswords() {
    setState(() {
      if (_passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _errorText = "密码不能为空";
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _errorText = "两次输入的密码不一致";
      } else {
        _errorText = null; // 校验通过
      }
    });
  }

  Widget userProfile() {
    return SizedBox(
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
                      showTipDialog(context, content: "upload_image_err".tr);
                    }
                  });
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : HexColor.fromInt(0x1c1c1e),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.camera_alt_sharp,
                    color:
                        Theme.of(context).brightness == Brightness.light
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

      // FormInputField(
      //   bgColor: Colors.transparent,
      //   labelText: 'username'.tr,
      //   hintText: 'username.tip'.tr,
      //   validator: (v) {
      //     if (v == null || v.isEmpty) {
      //       return 'username.required'.tr;
      //     }
      //     return null;
      //   },
      //   value: Guard.userName(),
      //   onSaved: (v) {
      //     controller.emailController.text = v!;
      //   },
      // ),
      // const SizedBox(height: 15),
      // FormInputField(
      //   bgColor: Colors.transparent,
      //   labelText: 'telephone'.tr,
      //   hintText: 'telephone.tip'.tr,
      //   validator: (v) {
      //     if (v == null || v.isEmpty) {
      //       return 'telephone.required'.tr;
      //     }
      //     return null;
      //   },
      //   value: Guard.userTelephone(),
      //   onSaved: (v) {
      //     controller.emailController.text = v!;
      //   },
      // ),
      // const SizedBox(height: 15),
      // FormInputField(
      //   bgColor: Colors.transparent,
      //   labelText: 'email'.tr,
      //   hintText: 'email.tip'.tr,
      //   validator: (textValue) {
      //     if (textValue == null || textValue.isEmpty) {
      //       return 'email.required'.tr;
      //     }
      //     if (!EmailValidator.validate(textValue)) {
      //       return 'email.valid'.tr;
      //     }
      //     return null;
      //   },
      //   value: Guard.userEmail(),
      //   onSaved: (v) {
      //     controller.emailController.text = v!;
      //   },
      // ),
      // const SizedBox(height: 30),
      // ShadowButton(onTap: controller.commit(context), text: 'save'.tr),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true; // 控制密码显示/隐藏

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelText,
        filled: true, // 填充背景
        fillColor: Theme.of(context).primaryColorLight, // 默认填充色
        contentPadding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ), // 让输入框更舒适
        // 🟢 默认状态边框
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none, // 默认去掉边框
        ),
        floatingLabelStyle: TextStyle(color: Colors.black),

        // 🔴 Focused 状态边框（选中时外层高亮颜色）
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ), // 外层高亮颜色
        ),

        // 🔑 左侧 prefix 图标
        prefixIcon: Icon(Icons.lock, color: Colors.grey),

        // 👁 右侧“眼睛”按钮
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      style: TextStyle(color: Colors.black), // 让输入文字不会变白色
    );
  }
}
