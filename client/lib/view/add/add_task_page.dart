import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/radio.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/view/add/add_controller.dart';
import 'package:my_todo/view/add/popular_filter_list.dart';
import 'package:my_todo/view/map/select/place.dart';
import 'package:settings_ui/settings_ui.dart';

final List<String> animalAmphibian = ['assets/animal/amphibian/frog.svg'];

final List<String> animalBird = [
  'assets/animal/bird/baby_chick.svg',
  'assets/animal/bird/bird.svg',
  'assets/animal/bird/black_bird.svg',
  'assets/animal/bird/chicken.svg',
  'assets/animal/bird/dodo.svg',
  'assets/animal/bird/dove.svg',
  'assets/animal/bird/duck.svg',
  'assets/animal/bird/eagle.svg',
  'assets/animal/bird/feather.svg',
  'assets/animal/bird/flamingo.svg',
  'assets/animal/bird/front_facing_baby_chick.svg',
  'assets/animal/bird/goose.svg',
  'assets/animal/bird/hatching_chick.svg',
  'assets/animal/bird/owl.svg',
  'assets/animal/bird/parrot.svg',
  'assets/animal/bird/peacock.svg',
  'assets/animal/bird/penguin.svg',
  'assets/animal/bird/phoenix.svg',
  'assets/animal/bird/rooster.svg',
  'assets/animal/bird/swan.svg',
  'assets/animal/bird/turkey.svg',
  'assets/animal/bird/wing.svg',
];

final List<String> animalBug = [
  'assets/animal/bug/ant.svg',
  'assets/animal/bug/beetle.svg',
  'assets/animal/bug/bug.svg',
  'assets/animal/bug/butterfly.svg',
  'assets/animal/bug/cockroach.svg',
  'assets/animal/bug/cricket.svg',
  'assets/animal/bug/fly.svg',
  'assets/animal/bug/honeybee.svg',
  'assets/animal/bug/lady_beetle.svg',
  'assets/animal/bug/microbe.svg',
  'assets/animal/bug/mosquito.svg',
  'assets/animal/bug/scorpion.svg',
  'assets/animal/bug/snail.svg',
  'assets/animal/bug/spider.svg',
  'assets/animal/bug/spider_web.svg',
  'assets/animal/bug/worm.svg',
];

final List<String> animalMammal = [
  'assets/animal/mammal/badger.svg',
  'assets/animal/mammal/bat.svg',
  'assets/animal/mammal/bear.svg',
  'assets/animal/mammal/beaver.svg',
  'assets/animal/mammal/bison.svg',
  'assets/animal/mammal/black_cat.svg',
  'assets/animal/mammal/boar.svg',
  'assets/animal/mammal/camel.svg',
  'assets/animal/mammal/cat.svg',
  'assets/animal/mammal/cat_face.svg',
  'assets/animal/mammal/chipmunk.svg',
  'assets/animal/mammal/cow.svg',
  'assets/animal/mammal/cow_face.svg',
  'assets/animal/mammal/deer.svg',
  'assets/animal/mammal/dog.svg',
  'assets/animal/mammal/dog_face.svg',
  'assets/animal/mammal/donkey.svg',
  'assets/animal/mammal/elephant.svg',
  'assets/animal/mammal/ewe.svg',
  'assets/animal/mammal/fox.svg',
  'assets/animal/mammal/giraffe.svg',
  'assets/animal/mammal/goat.svg',
  'assets/animal/mammal/goldfish.svg',
  'assets/animal/mammal/gorilla.svg',
  'assets/animal/mammal/guide_dog.svg',
  'assets/animal/mammal/hamster.svg',
  'assets/animal/mammal/hedgehog.svg',
  'assets/animal/mammal/hippopotamus.svg',
  'assets/animal/mammal/horse.svg',
  'assets/animal/mammal/horse_face.svg',
  'assets/animal/mammal/kangaroo.svg',
  'assets/animal/mammal/koala.svg',
  'assets/animal/mammal/leopard.svg',
  'assets/animal/mammal/lion.svg',
  'assets/animal/mammal/llama.svg',
  'assets/animal/mammal/mammoth.svg',
  'assets/animal/mammal/monkey.svg',
  'assets/animal/mammal/monkey_face.svg',
  'assets/animal/mammal/moose.svg',
  'assets/animal/mammal/mouse.svg',
  'assets/animal/mammal/mouse_face.svg',
  'assets/animal/mammal/orangutan.svg',
  'assets/animal/mammal/otter.svg',
  'assets/animal/mammal/ox.svg',
  'assets/animal/mammal/panda.svg',
  'assets/animal/mammal/paw_prints.svg',
  'assets/animal/mammal/pig.svg',
  'assets/animal/mammal/pig_face.svg',
  'assets/animal/mammal/pig_nose.svg',
  'assets/animal/mammal/polar_bear.svg',
  'assets/animal/mammal/poodle.svg',
  'assets/animal/mammal/rabbit.svg',
  'assets/animal/mammal/rabbit_face.svg',
  'assets/animal/mammal/raccoon.svg',
  'assets/animal/mammal/ram.svg',
  'assets/animal/mammal/rat.svg',
  'assets/animal/mammal/rhinoceros.svg',
  'assets/animal/mammal/service_dog.svg',
  'assets/animal/mammal/skunk.svg',
  'assets/animal/mammal/sloth.svg',
  'assets/animal/mammal/tiger.svg',
  'assets/animal/mammal/tiger_face.svg',
  'assets/animal/mammal/two_hump_camel.svg',
  'assets/animal/mammal/unicorn.svg',
  'assets/animal/mammal/water_buffalo.svg',
  'assets/animal/mammal/wolf.svg',
  'assets/animal/mammal/zebra.svg',
];

final List<String> animalMarine = [
  'assets/animal/marine/blowfish.svg',
  'assets/animal/marine/coral.svg',
  'assets/animal/marine/dolphin.svg',
  'assets/animal/marine/fish.svg',
  'assets/animal/marine/jellyfish.svg',
  'assets/animal/marine/octopus.svg',
  'assets/animal/marine/seal.svg',
  'assets/animal/marine/shark.svg',
  'assets/animal/marine/spiral_shell.svg',
  'assets/animal/marine/spouting_whale.svg',
  'assets/animal/marine/tropical_fish.svg',
  'assets/animal/marine/whale.svg',
];

final List<String> animalReptile = [
  'assets/animal/reptile/crocodile.svg',
  'assets/animal/reptile/dragon.svg',
  'assets/animal/reptile/dragon_face.svg',
  'assets/animal/reptile/lizard.svg',
  'assets/animal/reptile/sauropod.svg',
  'assets/animal/reptile/snake.svg',
  'assets/animal/reptile/t_rex.svg',
  'assets/animal/reptile/turtle.svg',
];

final List<String> plantFlower = [
  'assets/plant/flower/blossom.svg',
  'assets/plant/flower/bouquet.svg',
  'assets/plant/flower/cherry_blossom.svg',
  'assets/plant/flower/hibiscus.svg',
  'assets/plant/flower/hyacinth.svg',
  'assets/plant/flower/lotus.svg',
  'assets/plant/flower/rose.svg',
  'assets/plant/flower/rosette.svg',
  'assets/plant/flower/sunflower.svg',
  'assets/plant/flower/tulip.svg',
  'assets/plant/flower/white_flower.svg',
  'assets/plant/flower/wilted_flower.svg',
];

final List<String> plantOther = [
  'assets/plant/other/cactus.svg',
  'assets/plant/other/deciduous_tree.svg',
  'assets/plant/other/empty_nest.svg',
  'assets/plant/other/evergreen_tree.svg',
  'assets/plant/other/fallen_leaf.svg',
  'assets/plant/other/four_leaf_clover.svg',
  'assets/plant/other/herb.svg',
  'assets/plant/other/leaf_fluttering_in_wind.svg',
  'assets/plant/other/maple_leaf.svg',
  'assets/plant/other/mushroom.svg',
  'assets/plant/other/nest_with_eggs.svg',
  'assets/plant/other/palm_tree.svg',
  'assets/plant/other/potted_plant.svg',
  'assets/plant/other/seedling.svg',
  'assets/plant/other/shamrock.svg',
  'assets/plant/other/sheaf_of_rice.svg',
];

class LocaleItem {
  double lng;
  double lat;
  int radius;

  LocaleItem({required this.lng, required this.lat, this.radius = 30});
}

final List<String> foods = ['assets/food/grapes.svg'];

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController startController = TextEditingController();
  final BoardMultiDateTimeController controller =
      BoardMultiDateTimeController();
  final ValueNotifier<DateTime> start = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> end = ValueNotifier(
    DateTime.now().add(const Duration(days: 7)),
  );
  final DateTimePickerType pickerType = DateTimePickerType.datetime;

  final Rx<int> _selectedIndex = 0.obs;
  AddController addController = Get.find<AddController>();
  Rx<String> profile = "".obs;
  RxList<LocaleItem> localeItems = <LocaleItem>[].obs;

  @override
  bool get wantKeepAlive => true;

  final TextEditingController nameController = TextEditingController();

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
                  profile.value,
                  width: 100, // Ensure it's large enough to avoid blurriness
                  height: 100, // Same as above
                  fit: BoxFit.contain, // Keep the aspect ratio intact
                ),
              ),
            ),
            onTap: () {
              // showCupertinoModalPopup(
              //   context: context,
              //   builder: (context) {
              //     return CupertinoActionSheet(
              //       title: Text('Choose an option'),
              //       message: Text('Choose one of the options below.'),
              //       actions: <CupertinoActionSheetAction>[
              //         CupertinoActionSheetAction(
              //           child: Text('Option 1'),
              //           onPressed: () {
              //             Navigator.pop(context);
              //           },
              //         ),
              //         CupertinoActionSheetAction(
              //           child: Text('Option 2'),
              //           onPressed: () {
              //             Navigator.pop(context);
              //           },
              //         ),
              //       ],
              //     );
              //   },
              // );
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
                    onPressed: (context) {
                      if (addController.topics.isEmpty) {
                        showTipDialog(
                          context,
                          content: "topic_not_found".tr,
                          onPressed: () {
                            addController.switchToTab(1);
                            Get.back();
                          },
                        );
                      } else {
                        showCupertinoModalPopup<void>(
                          context: context,
                          builder:
                              (context) => CupertinoActionSheet(
                                title: Text(
                                  'topic'.tr,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                message: Column(
                                  children:
                                      addController.topics
                                          .map(
                                            (e) => Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  e.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                ColorfulRadio(
                                                  value: e.name,
                                                  groupValue:
                                                      addController
                                                          .selectedTopic
                                                          .value,
                                                  onChanged: (v) {
                                                    addController
                                                        .selectedTopic
                                                        .value = v!;
                                                    Get.back();
                                                  },
                                                  backgroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                        );
                      }
                    },
                    title: Text('topic'.tr),
                    leading: Icon(Icons.topic),
                    value: Obx(() => Text(addController.selectedTopic.value)),
                  ),
                  SettingsTile.navigation(
                    title: Text('name'.tr),
                    leading: Icon(Icons.drive_file_rename_outline_outlined),
                    onPressed: (context) {
                      showTextDialog(
                        context,
                        title: "name".tr,
                        content: TextField(controller: nameController),
                        onConfirm: () {
                          setState(() {
                            Get.back();
                          });
                        },
                        onCancel: () => Get.back(),
                      );
                    },
                    value: Text(nameController.text),
                  ),
                  SettingsTile.navigation(
                    onPressed: (ctx) async {
                      final result = await showBoardDateTimeMultiPicker(
                        context: context,
                        controller: controller,
                        pickerType: pickerType,
                        // minimumDate: DateTime.now().add(const Duration(days: 1)),
                        startDate: start.value,
                        endDate: end.value,
                        options: const BoardDateTimeOptions(
                          languages: BoardPickerLanguages.en(),
                          startDayOfWeek: DateTime.sunday,
                          pickerFormat: PickerFormat.ymd,
                          useAmpm: false,
                          // topMargin: 0,
                          // allowRetroactiveTime: true,
                        ),
                        // customCloseButtonBuilder: customCloseButtonBuilder,
                        // headerWidget: Container(
                        //   height: 60,
                        //   margin: const EdgeInsets.all((8)),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     border: Border.all(color: Colors.red, width: 4),
                        //     borderRadius: BorderRadius.circular(24),
                        //   ),
                        //   alignment: Alignment.center,
                        //   child: Text(
                        //     'Header Widget',
                        //     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.red,
                        //         ),
                        //   ),
                        // ),
                        // onTopActionBuilder: (context) {
                        //   return const SizedBox();
                        // },
                        // multiSelectionMaxDateBuilder: (selectedDate) {
                        //   return selectedDate.add(const Duration(days: 3));
                        // },
                      );
                      if (result != null) {
                        start.value = result.start;
                        end.value = result.end;
                      }
                      setState(() {});
                      print('result: ${start.value} - ${end.value}');
                    },
                    title: Text('schedule'.tr),
                    leading: Icon(Icons.calendar_month),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: start,
                          builder: (context, data, _) {
                            return Text(
                              BoardDateFormat('yyyy/MM/dd HH:mm').format(data),
                              // style: TextStyle(
                              //   color: ThemeProvider.contrastColor(
                              //     context,
                              //     light: Colors.grey,
                              //     dark: Colors.white,
                              //   ),
                              // ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder(
                          valueListenable: end,
                          builder: (context, data, _) {
                            return Text(
                              '~ ${BoardDateFormat('yyyy/MM/dd HH:mm').format(data)}',
                              // style: TextStyle(
                              //   color: ThemeProvider.contrastColor(
                              //     context,
                              //     light: Colors.grey,
                              //     dark: Colors.white,
                              //   ),
                              // ),
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
                    initialValue: addController.taskCondClick,
                    onToggle: (v) {
                      setState(() {
                        addController.taskCondClick = v;
                      });
                    },
                    activeSwitchColor: Theme.of(context).primaryColor,
                    leading: Icon(Icons.ads_click),
                    title: Text("condition_click".tr),
                  ),
                  SettingsTile.switchTile(
                    initialValue: addController.taskCondQR,
                    onToggle: (v) {
                      setState(() {
                        addController.taskCondQR = v;
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
                                    value: addController.taskCondFile.value,
                                    onChanged: (bool v) {
                                      addController.taskCondFile.value = v;
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
                                    value: addController.taskCondText.value,
                                    onChanged: (bool v) {
                                      addController.taskCondText.value = v;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            contentLimit(context),
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
                                    localeItems.add(v);
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
                                  localeItems.add(
                                    LocaleItem(lng: v.lng, lat: v.lat),
                                  );
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
                                itemCount: localeItems.length,
                                itemBuilder: (ctx, idx) {
                                  return localeBar(
                                    ctx,
                                    localeItems[idx],
                                    edit: () {
                                      localeEditor(
                                        ctx,
                                        cb: (v) {
                                          localeItems[idx] = v;
                                        },
                                        item: localeItems[idx],
                                      );
                                    },
                                    remove: () {
                                      localeItems.removeAt(idx);
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
                          localeItems.isNotEmpty
                              ? badges.Badge(
                                badgeContent: Text(
                                  localeItems.length.toString(),
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
                  child: Text("描述", style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(height: 10),
                TextField(
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
                      borderRadius: BorderRadius.circular(
                        15,
                      ), // Keep rounded corners when focused
                      borderSide:
                          BorderSide.none, // Remove focused border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ), // Keep rounded corners when enabled
                      borderSide:
                          BorderSide.none, // Remove enabled border color
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
            profile.value = icons[index];
            Get.back();
          },
          child: SvgPicture.asset(icons[index], width: 30, height: 30),
        );
      },
    );
  }
}

void showSheetBottom(
  BuildContext context, {
  required String title,
  Widget? right,
  List<Widget>? actions,
  EdgeInsetsGeometry childPadding = const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 20,
  ),
  required Widget child,
}) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  right != null
                      ? Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: right,
                      )
                      : Container(),
                ],
              ),
              Padding(padding: childPadding, child: child),
            ],
          ),
        ),
      );
    },
  );
}

void localeEditor(
  BuildContext context, {
  LocaleItem? item,
  required void Function(LocaleItem v) cb,
}) {
  TextEditingController lngController = TextEditingController(
    text: item?.lng.toString(),
  );
  TextEditingController latController = TextEditingController(
    text: item?.lat.toString(),
  );
  TextEditingController radiusController = TextEditingController(
    text: item?.radius.toString(),
  );
  showTextDialog(
    context,
    title: "add",
    content: Column(
      children: [
        TextField(
          controller: lngController,
          decoration: InputDecoration(
            labelText: "longitude".tr,
            filled: true,
            fillColor: Theme.of(context).primaryColorLight,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            prefixIcon: Icon(Icons.explore, color: Colors.grey),
          ),
          style: TextStyle(color: Colors.black),
        ),
        Container(height: 20),
        TextField(
          controller: latController,
          decoration: InputDecoration(
            labelText: "latitude".tr,
            filled: true,
            fillColor: Theme.of(context).primaryColorLight,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            prefixIcon: Icon(Icons.explore_outlined, color: Colors.grey),
          ),
          style: TextStyle(color: Colors.black),
        ),
        Container(height: 20),
        TextField(
          controller: radiusController,
          decoration: InputDecoration(
            labelText: "radius".tr,
            filled: true,
            fillColor: Theme.of(context).primaryColorLight,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            prefixIcon: Icon(Icons.circle_outlined, color: Colors.grey),
          ),
          style: TextStyle(color: Colors.black),
        ),
      ],
    ),
    onCancel: () {
      Get.back();
    },
    onConfirm: () {
      cb(
        LocaleItem(
          lng: double.parse(lngController.text),
          lat: double.parse(latController.text),
          radius: int.parse(radiusController.text),
        ),
      );
      Get.back();
    },
  );
}

Widget localeBar(
  BuildContext context,
  LocaleItem item, {
  required void Function()? edit,
  required void Function()? remove,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.2),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text("${item.lng}, ${item.lat}, ${item.radius}"),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: edit,
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            IconButton(
              onPressed: remove,
              icon: Icon(
                Icons.remove,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class RoundedButtonRow extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<int> onTap;
  final int selectedIndex;

  const RoundedButtonRow({
    super.key,
    required this.labels,
    required this.onTap,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        bool isSelected = index == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: index < labels.length - 1 ? 10 : 0),
          child: TextButton(
            onPressed: () => onTap(index),
            style: TextButton.styleFrom(
              backgroundColor:
                  isSelected
                      ? Theme.of(context).primaryColor
                      : ThemeProvider.contrastColor(
                        context,
                        light: Colors.white,
                        dark: CupertinoColors.darkBackgroundGray,
                      ),
              foregroundColor:
                  isSelected
                      ? Colors.white
                      : ThemeProvider.contrastColor(
                        context,
                        light: Colors.black,
                        dark: Colors.white,
                      ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(labels[index]),
          ),
        );
      }),
    );
  }
}

class LocationRow extends StatelessWidget {
  final String locationText;
  final VoidCallback onEditPressed;
  final VoidCallback onRemovePressed;

  const LocationRow({
    super.key,
    required this.locationText,
    required this.onEditPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(locationText),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEditPressed,
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              IconButton(
                onPressed: onRemovePressed,
                icon: Icon(
                  Icons.remove,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
