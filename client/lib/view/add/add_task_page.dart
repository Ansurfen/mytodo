import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg_provider;
import 'package:get/get.dart';
import 'package:my_todo/component/radio.dart';
import 'package:my_todo/mock/provider.dart';
import 'package:my_todo/theme/color.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:my_todo/utils/guard.dart';
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

  Rx<String> profile = "".obs;

  @override
  bool get wantKeepAlive => true;

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
                              "选择图标",
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
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Obx(() => candidates[_selectedIndex.value]),
                          ),
                        ),
                      ],
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
                title: Text("common".tr),
                tiles: [
                  SettingsTile.navigation(
                    onPressed: (context) {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder:
                            (context) => CupertinoActionSheet(
                              title: Text(
                                'topic'.tr,
                                style: const TextStyle(fontSize: 20),
                              ),
                              message: Column(
                                children: [
                                  ColorfulRadio(
                                    value: Mock.username(),
                                    groupValue: Mock.username(),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    onChanged: (v) {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
                    title: Text('topic'.tr),
                    leading: Icon(Icons.topic),
                    value: Text("高三一班"),
                  ),
                  SettingsTile(
                    title: Text('name'.tr),
                    leading: Icon(Icons.drive_file_rename_outline_outlined),
                    // value: Text("高三一班"),
                    trailing: Text("高三一班"),
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
                    title: Text('schedule'),
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
                    initialValue: false,
                    onToggle: (v) {},
                    leading: Icon(Icons.ads_click),
                    title: Text("click"),
                  ),
                  SettingsTile.switchTile(
                    initialValue: false,
                    onToggle: (v) {},
                    leading: Icon(Icons.qr_code),
                    title: Text("Scan QR"),
                  ),
                  SettingsTile.navigation(
                    leading: Icon(Icons.drive_folder_upload),
                    title: Text("file upload"),
                  ),
                  SettingsTile.navigation(
                    leading: Icon(Icons.abc),
                    title: Text("text submit"),
                  ),
                  SettingsTile(
                    onPressed: (ctx) {
                      showSheetBottom(
                        ctx,
                        title: "locale".tr,
                        child: Column(children: [
                          
                        ]),
                      );
                    },
                    leading: Icon(Icons.location_on),
                    title: Text("locale"),
                    trailing: badges.Badge(
                      badgeContent: Text('3'),
                      badgeStyle: badges.BadgeStyle(
                        badgeColor: Theme.of(context).primaryColorLight,
                      ),
                      badgeAnimation: badges.BadgeAnimation.rotation(),
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
                    hintText: '随便说点啥吧~', // Hint text
                    hintStyle: TextStyle(color: Colors.grey), // Hint text color
                    filled: true, // Fill the background
                    fillColor:
                        Colors.white, // Set the background color to white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ), // Rounded corners
                      borderSide:
                          BorderSide.none, // Remove border color (optional)
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showSheetBottom(
    BuildContext context, {
    required String title,
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
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<String> icons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
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
                  isSelected ? Theme.of(context).primaryColor : Colors.white,
              foregroundColor: isSelected ? Colors.white : Colors.black,
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
