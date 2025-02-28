// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/component/radio.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/view/setting/setting_controller.dart';
import 'package:get/get.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  SettingController controller = Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    return todoCupertinoScaffold(
      context: context,
      appBar: todoCupertinoNavBarWithBack(
        context,
        middle: Text(
          "setting".tr,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: SettingsList(
          shrinkWrap: true,
          applicationType: ApplicationType.cupertino,
          platform: DevicePlatform.iOS,
          sections: [_commonSection(), _networkSection(), _internalSection()],
        ),
      ),
    );
  }

  SettingsSection _commonSection() {
    return SettingsSection(
      title: Text('common'.tr),
      tiles: [
        SettingsTile.navigation(
          title: Text('language'.tr),
          value: Text(controller.currentLanguage.tr),
          onPressed: _switchLanguage,
        ),
        SettingsTile.switchTile(
          onToggle: (value) {
            setState(() {
              controller.isDark = !controller.isDark;
              controller.setDarkMode();
            });
          },
          activeSwitchColor: Theme.of(context).primaryColor,
          initialValue: controller.isDark,
          title: Text('dark_mode'.tr),
        ),
        SettingsTile.navigation(
          title: Text('style'.tr),
          trailing: Icon(
            Icons.format_paint,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: _switchStyle,
        ),
      ],
    );
  }

  void _switchLanguage(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: Text('language'.tr, style: const TextStyle(fontSize: 20)),
            message: Column(
              children:
                  controller.languages
                      .map(
                        (e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.tr, style: const TextStyle(fontSize: 18)),
                            ColorfulRadio(
                              value: e,
                              groupValue: controller.currentLanguage,
                              onChanged: (v) {
                                controller.currentLanguage = v!;
                                Guard.setLanguage(v);
                                Get.back();
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _switchStyle(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: Text('language'.tr, style: const TextStyle(fontSize: 20)),
            message: Column(
              children:
                  ThemeStyleName.values
                      .map(
                        (e) => styleRow(
                          e.value.tr,
                          e.value,
                          controller.style,
                          ThemeProvider.themeData(e.value)!.normal(),
                          onChanged: (value) {
                            controller.style = value!;
                            controller.setTheme();
                            Get.back();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  SettingsSection _networkSection() {
    return SettingsSection(
      title: Text('network'.tr),
      tiles: [
        SettingsTile.navigation(
          onPressed: (_) {
            showSingleTextField(
              context,
              title: 'server_address'.tr,
              controller: controller.serverAddressController,
              onCancel: () {
                controller.unsetServer();
                Navigator.pop(context);
              },
              onConfirm: () {
                controller.setServer();
                Get.back();
                setState(() {});
              },
            );
          },
          title: Text('server'.tr),
          value: Container(
            alignment: Alignment.centerRight,
            width: MediaQuery.sizeOf(context).width / 2,
            child: Text(
              controller.serverAddressController.text,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          description: Text('server_set_tip'.tr),
        ),
      ],
    );
  }

  SettingsSection _internalSection() {
    return SettingsSection(
      title: Text("internal".tr),
      tiles: [
        SettingsTile.switchTile(
          title: Text("logger".tr),
          description: Text("logger_set_tip".tr),
          initialValue: true,
          activeSwitchColor: Theme.of(context).primaryColor,
          onToggle: (bool value) {},
        ),
        // TODO: reset, import configuration
      ],
    );
  }

  Widget styleRow(
    String name,
    String value,
    String group,
    Color bgColor, {
    required void Function(String?)? onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(fontSize: 18)),
        ColorfulRadio(
          value: value,
          groupValue: group,
          backgroundColor: bgColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
