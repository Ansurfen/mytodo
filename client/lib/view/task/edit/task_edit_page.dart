import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/add/add_task_page.dart';
import 'package:my_todo/view/map/select/place.dart';
import 'package:my_todo/view/task/edit/task_edit_controller.dart';
import 'package:settings_ui/settings_ui.dart';

class TaskEditPage extends StatefulWidget {
  const TaskEditPage({super.key});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final Rx<int> _selectedIndex = 0.obs;
  TaskEditController controller = Get.find<TaskEditController>();

  @override
  Widget build(BuildContext context) {
    return todoCupertinoScaffold(
      context: context,
      appBar: todoCupertinoNavBar(
        context,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            // TODO: 实现保存功能
            Get.back();
          },
          icon: Icon(
            Icons.cloud_upload,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: Container(color: Colors.transparent, child: taskEditView()),
    );
  }

  Widget taskEditView() {
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
                child: SvgPicture.asset(
                  controller.taskIcon.value,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
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
                title: Text("common".tr),
                tiles: [
                  SettingsTile.navigation(
                    title: Text('name'.tr),
                    leading: Icon(Icons.drive_file_rename_outline_outlined),
                    onPressed: (context) {
                      showTextDialog(
                        context,
                        title: "name".tr,
                        content: TextField(
                          controller: TextEditingController(
                            text: controller.taskName.value,
                          ),
                          onChanged:
                              (value) => controller.taskName.value = value,
                        ),
                        onConfirm: () {
                          setState(() {
                            Get.back();
                          });
                        },
                        onCancel: () => Get.back(),
                      );
                    },
                    value: Obx(() => Text(controller.taskName.value)),
                  ),
                  SettingsTile.navigation(
                    onPressed: (ctx) async {
                      final result = await showBoardDateTimeMultiPicker(
                        context: context,
                        controller: BoardMultiDateTimeController(),
                        pickerType: DateTimePickerType.datetime,
                        startDate: controller.taskStart.value,
                        endDate: controller.taskEnd.value,
                        options: const BoardDateTimeOptions(
                          languages: BoardPickerLanguages.en(),
                          startDayOfWeek: DateTime.sunday,
                          pickerFormat: PickerFormat.ymd,
                          useAmpm: false,
                        ),
                      );
                      if (result != null) {
                        controller.taskStart.value = result.start;
                        controller.taskEnd.value = result.end;
                      }
                      setState(() {});
                    },
                    title: Text('schedule'.tr),
                    leading: Icon(Icons.calendar_month),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: controller.taskStart,
                          builder: (context, data, _) {
                            return Text(
                              BoardDateFormat('yyyy/MM/dd HH:mm').format(data),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder(
                          valueListenable: controller.taskEnd,
                          builder: (context, data, _) {
                            return Text(
                              '~ ${BoardDateFormat('yyyy/MM/dd HH:mm').format(data)}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: Text("condition".tr),
                tiles: [
                  SettingsTile.switchTile(
                    initialValue: controller.taskCondClick.value,
                    onToggle: (v) {
                      setState(() {
                        controller.taskCondClick.value = v;
                      });
                    },
                    activeSwitchColor: Theme.of(context).primaryColor,
                    leading: Icon(Icons.ads_click),
                    title: Text("condition_click".tr),
                  ),
                  SettingsTile.switchTile(
                    initialValue: controller.taskCondQR.value,
                    onToggle: (v) {
                      setState(() {
                        controller.taskCondQR.value = v;
                      });
                    },
                    activeSwitchColor: Theme.of(context).primaryColor,
                    leading: Icon(Icons.qr_code),
                    title: Text("condition_qr".tr),
                  ),
                  SettingsTile.navigation(
                    onPressed: (context) {
                      showSheetBottom(
                        context,
                        title: "condition_file".tr,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("enable".tr),
                                Obx(
                                  () => CupertinoSwitch(
                                    activeTrackColor:
                                        Theme.of(context).primaryColor,
                                    value: controller.taskCondFile.value,
                                    onChanged: (bool v) {
                                      controller.taskCondFile.value = v;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Icon(Icons.drive_folder_upload),
                    title: Text("condition_file".tr),
                  ),
                  SettingsTile.navigation(
                    onPressed: (context) {
                      showSheetBottom(
                        context,
                        title: "condition_text".tr,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("enable".tr),
                                Obx(
                                  () => CupertinoSwitch(
                                    activeTrackColor:
                                        Theme.of(context).primaryColor,
                                    value: controller.taskCondText.value,
                                    onChanged: (bool v) {
                                      controller.taskCondText.value = v;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Icon(Icons.abc),
                    title: Text("condition_text".tr),
                  ),
                  SettingsTile(
                    onPressed: (ctx) {
                      showSheetBottom(
                        ctx,
                        title: "condition_locale".tr,
                        right: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                localeEditor(
                                  context,
                                  cb: (v) {
                                    controller.localeItems.add({
                                      'latitude': v.lat,
                                      'longitude': v.lng,
                                      'radius': 30,
                                    });
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.drive_file_rename_outline_outlined,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                for (var v
                                    in (await RouterProvider.toMapSelect()
                                        as List<Place>)) {
                                  controller.localeItems.add({
                                    'latitude': v.lat,
                                    'longitude': v.lng,
                                    'radius': 30,
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.add,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "lat_lng_rds".tr,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Container(height: 8),
                            Obx(
                              () => ListView.separated(
                                shrinkWrap: true,
                                itemCount: controller.localeItems.length,
                                itemBuilder: (ctx, idx) {
                                  final item = controller.localeItems[idx];
                                  return localeBar(
                                    ctx,
                                    LocaleItem(
                                      lat: item['latitude'],
                                      lng: item['longitude'],
                                    ),
                                    edit: () {
                                      localeEditor(
                                        ctx,
                                        cb: (v) {
                                          controller.localeItems[idx] = {
                                            'latitude': v.lat,
                                            'longitude': v.lng,
                                            'radius': 30,
                                          };
                                        },
                                        item: LocaleItem(
                                          lat: item['latitude'],
                                          lng: item['longitude'],
                                        ),
                                      );
                                    },
                                    remove: () {
                                      controller.localeItems.removeAt(idx);
                                    },
                                  );
                                },
                                separatorBuilder: (
                                  BuildContext context,
                                  int index,
                                ) {
                                  return Container(height: 10);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Icon(Icons.location_on),
                    title: Text("condition_locale".tr),
                    trailing: Obx(
                      () =>
                          controller.localeItems.isNotEmpty
                              ? badges.Badge(
                                badgeContent: Text(
                                  controller.localeItems.length.toString(),
                                ),
                                badgeStyle: badges.BadgeStyle(
                                  badgeColor:
                                      Theme.of(context).primaryColorLight,
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
                Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text("desc".tr, style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(
                    text: controller.taskDesc.value,
                  ),
                  onChanged: (value) => controller.taskDesc.value = value,
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
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Container(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            controller.taskIcon.value = icons[index];
            Get.back();
          },
          child: SvgPicture.asset(icons[index], width: 30, height: 30),
        );
      },
    );
  }
}
