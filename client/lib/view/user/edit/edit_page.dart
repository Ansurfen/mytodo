// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/user/edit/edit_controller.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/utils/dialog.dart';
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
          onPressed: () {
            controller.commit(context);
          },
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
                    SettingsTile.navigation(
                      title: Text("username".tr),
                      onPressed: (context) {
                        showTextDialog(
                          context,
                          title: "username".tr,
                          content: TextField(
                            controller: controller.nameController,
                          ),
                          onConfirm: () {
                            setState(() {
                              Get.back();
                            });
                          },
                          onCancel: () => Get.back(),
                        );
                      },
                      value: Text(controller.nameController.text),
                    ),
                    SettingsTile.navigation(
                      title: Text("about".tr),
                      onPressed: (context) {
                        showTextDialog(
                          context,
                          title: "about".tr,
                          content: TextField(
                            controller: controller.aboutController,
                          ),
                          onConfirm: () {
                            setState(() {
                              Get.back();
                            });
                          },
                          onCancel: () => Get.back(),
                        );
                      },
                      value: Text(controller.aboutController.text),
                    ),
                    SettingsTile.navigation(
                      title: Text("phone_number".tr),
                      onPressed: (context) {
                        showTextDialog(
                          context,
                          title: "phone_number".tr,
                          content: TextField(
                            controller: controller.telephoneController,
                          ),
                          onConfirm: () {
                            setState(() {
                              Get.back();
                            });
                          },
                          onCancel: () => Get.back(),
                        );
                      },
                      value: Text(controller.telephoneController.text),
                    ),
                    SettingsTile.navigation(
                      title: Text("email".tr),
                      onPressed: (context) {
                        showTextDialog(
                          context,
                          title: "email".tr,
                          content: TextField(
                            controller: controller.emailController,
                          ),
                          onConfirm: () {
                            setState(() {
                              Get.back();
                            });
                          },
                          onCancel: () => Get.back(),
                        );
                      },
                      value: Text(controller.emailController.text),
                    ),
                    SettingsTile.switchTile(
                      initialValue: Guard.u?.isMale,
                      onToggle: (v) {
                        Guard.u?.isMale = v;
                        setState(() {});
                      },
                      activeSwitchColor: Theme.of(context).primaryColor,
                      title: Text("is_male".tr),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text("security".tr),
                  tiles: [
                    SettingsTile.navigation(
                      title: Text("edit_password".tr),
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
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              "save".tr,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
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
                                          controller: controller.passwordController,
                                          labelText: "edit_new_password".tr,
                                        ),
                                        SizedBox(height: 15),
                                        PasswordTextField(
                                          controller:
                                              controller.confirmPasswordController,
                                          labelText: "edit_confirm_password".tr,
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


  String? _errorText;

  void _submit() {
    _validatePasswords();
    if (_errorText != null) {
      return;
    }
     controller.editPassword(context);
  }

  void _validatePasswords() {
    setState(() {
      if (controller.passwordController.text.isEmpty ||
          controller.confirmPasswordController.text.isEmpty) {
        _errorText = "password_required".tr;
      } else if (controller.passwordController.text !=
          controller.confirmPasswordController.text) {
        _errorText = "password_not_match".tr;
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
