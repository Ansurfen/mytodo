// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/skeleton/skeleton.dart';
import 'package:my_todo/component/skeleton/stylings.dart';
import 'package:my_todo/component/skeleton/widget.dart';
import 'package:my_todo/theme/color.dart';

class TaskSkeletonPage extends StatelessWidget {
  const TaskSkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.secondary
                : HexColor.fromInt(0x1c1c1e),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                topRight: Radius.circular(68.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  offset: const Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SkeletonParagraph(
                          style: SkeletonParagraphStyle(
                              lines: 3,
                              spacing: 6,
                              lineStyle: SkeletonLineStyle(
                                randomLength: true,
                                height: 10,
                                borderRadius: BorderRadius.circular(8),
                                minLength:
                                    MediaQuery.of(context).size.width / 4,
                                maxLength:
                                    MediaQuery.of(context).size.width / 3,
                              )),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SkeletonParagraph(
                          style: SkeletonParagraphStyle(
                              lines: 3,
                              spacing: 6,
                              lineStyle: SkeletonLineStyle(
                                randomLength: true,
                                height: 10,
                                borderRadius: BorderRadius.circular(8),
                                minLength:
                                    MediaQuery.of(context).size.width / 4,
                                maxLength:
                                    MediaQuery.of(context).size.width / 3,
                              )),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 40),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            shape: BoxShape.circle, width: 100, height: 100),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 8, bottom: 8),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  ),
                ),
              ),
              SkeletonParagraph(
                style: SkeletonParagraphStyle(
                    lines: 3,
                    spacing: 6,
                    lineStyle: SkeletonLineStyle(
                      randomLength: true,
                      height: 10,
                      borderRadius: BorderRadius.circular(8),
                      minLength: MediaQuery.of(context).size.width / 2,
                    )),
              ),
              const SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "task".tr,
              style: TextStyle(
                fontFamily: StatisticTableTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                letterSpacing: 0.5,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  "filter".tr,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: StatisticTableTheme.fontName,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(
                  height: 38,
                  width: 26,
                  child: Icon(
                    Icons.filter_alt,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(
          height: 200,
          child: Skeleton(
            isLoading: true,
            skeleton: SkeletonListView(),
            child: const Center(child: Text("Content")),
          )),
    ]);
  }
}
