// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:my_todo/component/container/bubble_container.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/model/dao/topic.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/view/add/add_controller.dart';
import 'package:my_todo/view/add/add_post_page.dart';
import 'package:my_todo/view/add/text_option.dart';
import 'package:my_todo/utils/dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/view/add/popular_filter_list.dart';
import 'package:my_todo/view/map/select/place.dart';
import 'add_topic_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin {
  AddController controller = Get.find<AddController>();

  String? selectedValue = "Item4";
  Map<int, String> topics = {};
  @override
  void initState() {
    super.initState();
    controller.tabController = TabController(length: 3, vsync: this);
    Future.delayed(const Duration(seconds: 0), () async {
      for (var element in (await TopicDao.findMany())) {
        topics[element.id!] = element.name;
      }
      setState(() {});
    });
  }

  Rx<double> distValue = 50.0.obs;
  Rx<String> locales = Rx("e");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          elevation: 3,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.drafts))
          ],
          // backgroundColor: Theme.of(context).primaryColor,
          title: TabBar(
            controller: controller.tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onTertiary,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
            tabs: [
              Tab(
                text: "task".tr,
              ),
              Tab(
                text: "topic".tr,
              ),
              Tab(
                text: "post".tr,
              )
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: TabBarView(
          controller: controller.tabController,
          children: [
            newVersion(),
            const AddTopicPage(),
            const AddPostPage(),
          ],
        ));
  }

  final _formKey = GlobalKey<FormState>();

  Widget _icon(IconData icon) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Theme.of(context).primaryColorLight.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 8)
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 32,
          width: 32,
          color: Theme.of(context).primaryColorLight.withOpacity(0.4),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _title(IconData icon, String name) {
    return Row(
      children: [
        _icon(icon),
        const SizedBox(width: 10),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget newVersion() {
    return Builder(
        builder: (ctx) => SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _title(Icons.topic, "Topic"),
                    SizedBox(width: MediaQuery.sizeOf(context).width / 3),
                    const SizedBox(width: 20),
                    _title(Icons.sync, "Synchronous"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Form(
                      key: _formKey,
                      child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width / 2,
                          ),
                          child: DropdownButtonFormField2<int>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              // Add Horizontal padding using menuItemStyleData.padding so it matches
                              // the menu padding when button's width is not specified.
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              // Add more decoration..
                            ),
                            hint: const Text(
                              'Select the topic to task',
                              style: TextStyle(fontSize: 14),
                            ),
                            items: topics.entries
                                .map((item) => DropdownMenuItem<int>(
                                      value: item.key,
                                      child: Text(
                                        item.value,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select topic';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              controller.selectedTopic = value;
                            },
                            onSaved: (value) {
                              selectedValue = value.toString();
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.only(right: 8),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 24,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          )),
                    ),
                    const SizedBox(width: 20),
                    CupertinoSwitch(
                      value: controller.sync,
                      activeColor: controller.sync
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.6),
                      onChanged: (bool value) {
                        setState(() {
                          controller.sync = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _title(Icons.drive_file_rename_outline, "Name"),
                const SizedBox(height: 5),
                BubbleTextFormField(
                  maxLines: 1,
                  hintText: "name".tr,
                  controller: controller.nameController,
                ),
                const SizedBox(height: 10),
                _title(Icons.description, "Description"),
                const SizedBox(height: 5),
                BubbleTextFormField(
                  hintText: "description".tr,
                  minLines: 3,
                  maxLines: null,
                  controller: controller.descController,
                ),
                const SizedBox(height: 10),
                _title(Icons.alarm, "Cron expression"),
                const SizedBox(height: 5),
                BubbleTextFormField(
                  maxLines: 1,
                  hintText: "cron".tr,
                ),
                const SizedBox(height: 10),
                _title(Icons.flight, "Start at"),
                const SizedBox(height: 5),
                BubbleDropdown(
                  onTap: () {
                    showDateTimePicker(ctx, "Start At", onConfirm: (v) {
                      controller.sendController.text = v;
                      setState(() {});
                    });
                  },
                  child: controller.sendController.text.isNotEmpty
                      ? Text(DateFormat('yyyy/MM/dd HH:mm:ss').format(
                          DateTime.parse(controller.sendController.text)))
                      : Container(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _title(Icons.flight_takeoff_outlined, "Departure"),
                    SizedBox(width: MediaQuery.sizeOf(context).width / 3.5),
                    _title(Icons.flight_land, "Arrival"),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: BubbleDropdown(
                        onTap: () {
                          showDateTimePicker(ctx, "Departure", onConfirm: (v) {
                            controller.departureController.text = v;
                            setState(() {});
                          });
                        },
                        child: controller.departureController.text.isNotEmpty
                            ? Text(DateFormat('yyyy/MM/dd HH:mm:ss').format(
                                DateTime.parse(
                                    controller.departureController.text)))
                            : Container(),
                      ),
                    ),
                    const SizedBox(width: 35),
                    Expanded(
                      child: BubbleDropdown(
                        onTap: () {
                          showDateTimePicker(ctx, "Arrival", onConfirm: (v) {
                            controller.arrivalController.text = v;
                            setState(() {});
                          });
                        },
                        child: controller.arrivalController.text.isNotEmpty
                            ? Text(DateFormat('yyyy/MM/dd HH:mm:ss').format(
                                DateTime.parse(
                                    controller.arrivalController.text)))
                            : Container(),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                _title(Icons.task_outlined, "complete_condition".tr),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: Column(
                    children: conditionsList(),
                  ),
                ),
                Obx(() => controller.activeLocale.value
                    ? Obx(() => Column(
                          children: [
                            distanceViewUI(context, distValue.value, () async {
                              List<Place> temp =
                                  await RouterProvider.viewMapSelect();
                              for (var element in temp) {
                                controller.pos.value.add(element);
                              }
                            }),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.pos.value.length,
                              itemBuilder: (ctx, idx) {
                                return Text(
                                    "lat: ${controller.pos.value[idx].lat}, lng: ${controller.pos.value[idx].lng}");
                              },
                              shrinkWrap: true,
                            ),
                          ],
                        ))
                    : defaultContainer),
                Obx(() => controller.activeFileUpload.value
                    ? BubbleTextFormField(
                        maxLines: 1,
                        hintText: "file_type_limit".tr,
                        onChanged: (v) {},
                      )
                    : defaultContainer),
                Obx(() => controller.activeContent.value
                    ? contentLimit(context)
                    : defaultContainer),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShadowButton(
                      text: 'save_draft'.tr,
                      onTap: () {
                        // getQrcodeState().then((value) => setState(() {
                        //       res = value;
                        //     }));
                      },
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    ShadowButton(
                      // width: MediaQuery.sizeOf(context).width * 0.4,
                      text: 'confirm'.tr,
                      onTap: () {
                        controller.confirm();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20)
              ]),
            )));
  }

  var defaultContainer = Container();

  List<Row> conditionsList() {
    final List<Row> noList = [];
    int count = 0;
    const int columnCount = 2;
    for (int j = 0; j < controller.taskConditions.length / columnCount; j++) {
      final List<Expanded> listUI = [];
      for (int i = 0; i < columnCount; i++) {
        try {
          listUI.add(Expanded(
            child: TextOption(model: controller.taskConditions[count]),
          ));
          if (count < controller.taskConditions.length - 1) {
            count += 1;
          } else {
            break;
          }
        } catch (e) {}
      }
      noList.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: listUI,
      ));
    }
    return noList;
  }
}
