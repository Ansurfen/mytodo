// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_todo/api/topic.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/container/bubble_container.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/hook/topic.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/model/dto/topic.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:my_todo/view/add/component/form.dart';
import 'package:settings_ui/settings_ui.dart';

class AddTopicPage extends StatefulWidget {
  const AddTopicPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddTopicPageState();
}

class _AddTopicPageState extends State<AddTopicPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  final Rx<int> _selectedIndex = 0.obs;

  Rx<String> profile = "".obs;

  bool isPublic = false;

  @override
  void initState() {
    profile.value = animalMammal[Mock.number(max: animalMammal.length - 1)];
    super.initState();
  }

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

    return Column(
      children: [
        Container(height: 20),
        InkWell(
          child: Obx(
            () => CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColorLight,
              backgroundImage: null, // Remove backgroundImage
              child: SvgPicture.asset(
                profile.value,
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
                                color: Theme.of(context).colorScheme.onPrimary,
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
                            child: Obx(() => candidates[_selectedIndex.value]),
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
          applicationType: ApplicationType.cupertino,
          platform: DevicePlatform.iOS,
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.switchTile(
                  leading: Icon(Icons.visibility),
                  activeSwitchColor: Theme.of(context).primaryColor,
                  initialValue: isPublic,
                  onToggle: (v) {
                    setState(() {
                      isPublic = v;
                    });
                  },
                  title: Text("task_is_public".tr),
                ),
                SettingsTile.navigation(
                  onPressed: (context) {
                    showTextDialog(
                      context,
                      title: "name",
                      content: TextField(controller: nameController),
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
                  value: Text(nameController.text),
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
              Text("描述", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 10),
              TextField(
                controller: descController,
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
                    borderSide: BorderSide.none, // Remove focused border color
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
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          FormHeader(icon: Icons.drive_file_rename_outline, name: "name".tr),
          const SizedBox(height: 5),
          BubbleTextFormField(
            maxLines: 1,
            hintText: "name".tr,
            onChanged: (v) {
              nameController.text = v;
            },
          ),
          const SizedBox(height: 10),
          FormHeader(icon: Icons.description, name: "description".tr),
          const SizedBox(height: 5),
          BubbleTextFormField(
            minLines: 6,
            hintText: "desc".tr,
            onChanged: (v) {
              descController.text = v;
            },
          ),
          const SizedBox(height: 30),
          ShadowButton(
            text: "create".tr,
            size: const Size(200, 40),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            onTap: () async {
              if (descController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                createTopic(
                      CreateTopicRequest(
                        nameController.text,
                        descController.text,
                      ),
                    )
                    .then((res) {
                      TopicHook.updateSnapshot(
                        GetTopicDto(
                          0,
                          DateTime.timestamp(),
                          DateTime.timestamp(),
                          nameController.text,
                          descController.text,
                          "",
                          "",
                        ),
                      );
                      showCopyableTipDialog(
                        context,
                        content: "${"topic_created".tr} ${res.inviteCode}",
                      ).then((value) {
                        Get.back();
                      });
                    })
                    .onError((error, stackTrace) {});
              }
            },
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
            profile.value = icons[index];
            Get.back();
          },
          child: SvgPicture.asset(icons[index], width: 30, height: 30),
        );
      },
    );
  }
}
