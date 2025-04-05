// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_todo/abc/utils.dart';
import 'package:get/get.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/add/add_controller.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:badges/badges.dart' as badges;

class AddTopicPage extends StatefulWidget {
  const AddTopicPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage>
    with AutomaticKeepAliveClientMixin {
  final Rx<int> _selectedIndex = 0.obs;
  AddController controller = Get.find<AddController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final candidates = [
      _buildGridView(animalAmphibian),
      _buildGridView(animalBird),
      _buildGridView(animalBug),
      _buildGridView(animalMammal),
      _buildGridView(animalMarine),
      _buildGridView(animalReptile),
      _buildGridView(plantFlower),
      _buildGridView(plantOther),
      _buildGridView(foods),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(height: 20),
          InkWell(
            child: Obx(
              () => CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).primaryColorLight,
                backgroundImage: null, // Remove backgroundImage
                child: SvgPicture.asset(
                  controller.topicIcon.value,
                  width: 100, // Ensure it's large enough to avoid blurriness
                  height: 100, // Same as above
                  fit: BoxFit.contain, // Keep the aspect ratio intact
                ),
              ),
            ),
            onTap: () {
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
                      minHeight: MediaQuery.sizeOf(context).height - 180,
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
                    child: SingleChildScrollView(
                      child: Column(
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
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                "select_icon".tr,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Obx(
                                    () => RoundedButtonRow(
                                      labels: [
                                        "animal_amphibian".tr,
                                        "animal_bird".tr,
                                        "animal_bug".tr,
                                        "animal_mammal".tr,
                                        "animal_marine".tr,
                                        "animal_reptile".tr,
                                        "plant_flower".tr,
                                        "plant_other".tr,
                                        "food".tr,
                                      ],
                                      onTap: (index) {
                                        Guard.log.i(index);
                                        _selectedIndex.value = index;
                                      },
                                      selectedIndex: _selectedIndex.value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: ThemeProvider.contrastColor(
                                  context,
                                  light: Colors.white,
                                  dark: CupertinoColors.darkBackgroundGray,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Obx(
                                () => candidates[_selectedIndex.value],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SettingsList(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            applicationType: ApplicationType.cupertino,
            platform: DevicePlatform.iOS,
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.switchTile(
                    leading: Icon(Icons.visibility),
                    activeSwitchColor: Theme.of(context).primaryColor,
                    initialValue: controller.topicIsPublic,
                    onToggle: (v) {
                      setState(() {
                        controller.topicIsPublic = v;
                      });
                    },
                    title: Text("topic_is_public".tr),
                  ),
                  SettingsTile.navigation(
                    onPressed: (context) {
                      showTextDialog(
                        context,
                        title: "name".tr,
                        content: TextField(controller: controller.topicName),
                        onConfirm: () {
                          setState(() {
                            Get.back();
                          });
                        },
                        onCancel: () => Get.back(),
                      );
                    },
                    title: Text('name'.tr),
                    leading: Icon(Icons.drive_file_rename_outline_outlined),
                    value: Text(controller.topicName.text),
                  ),
                  SettingsTile.navigation(
                    onPressed: (context) => showTagsPicker(context),
                    title: Text("topic_tag".tr),
                    leading: Icon(FontAwesomeIcons.tag),
                    trailing: Obx(
                      () =>
                          controller.topicTags.isNotEmpty
                              ? badges.Badge(
                                badgeContent: Text(
                                  controller.topicTags.length.toString(),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                badgeStyle: badges.BadgeStyle(
                                  badgeColor: Theme.of(context).primaryColor,
                                ),
                                badgeAnimation:
                                    badges.BadgeAnimation.rotation(),
                              )
                              : Container(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("desc".tr, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                TextField(
                  controller: controller.topicDesc,
                  minLines: 5,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'just_say_something'.tr,
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: ThemeProvider.contrastColor(
                      context,
                      light: Colors.white,
                      dark: CupertinoColors.darkBackgroundGray,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide.none, // Remove focused border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildGridView(List<String> icons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            controller.topicIcon.value = icons[index];
            Get.back();
          },
          child: SvgPicture.asset(icons[index], width: 30, height: 30),
        );
      },
    );
  }

  void showTagsPicker(BuildContext context) {
    TextEditingController tagController = TextEditingController();
    showSheetBottom(
      context,
      title: "topic_tag".tr,
      right: Row(
        children: [
          IconButton(
            onPressed: () {
              showTextDialog(
                context,
                title: "add".tr,
                content: Column(
                  children: [
                    TextField(
                      controller: tagController,
                      decoration: InputDecoration(
                        labelText: "name".tr,
                        filled: true,
                        fillColor: Theme.of(context).primaryColorLight,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.drive_file_rename_outline_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                onConfirm: () {
                  if (tagController.text.isEmpty) {
                    showSnack(context, "The tag's name is empty!");
                    return;
                  }
                  controller.topicTags.add(tagController.text);
                  tagController.clear();
                  Get.back();
                },
                onCancel: () {
                  Get.back();
                },
              );
            },
            icon: Icon(
              Icons.add,
              color: ThemeProvider.contrastColor(
                context,
                light: Colors.black,
                dark: Colors.white,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("name".tr, style: TextStyle(color: Colors.grey)),
          Container(height: 8),
          Obx(() {
            List<Widget> widgets = [];
            for (var i = 0; i < controller.topicTags.length; i++) {
              String v = controller.topicTags[i];
              widgets.add(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        v.tr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          controller.topicTags.removeAt(i);
                        },
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Wrap(spacing: 8.0, children: widgets);
          }),
        ],
      ),
    );
  }
}
