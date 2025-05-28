// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/share.dart';
import 'package:my_todo/view/home/nav/component/app_bar.dart';
import 'package:my_todo/theme/color.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Scaffold(
      appBar: todoAppBar(
        context,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              openQRScanner(context);
            },
            icon: Icon(
              Icons.crop_free,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 15),
          settingWidget(),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? HexColor.fromInt(0xf5f5f5).withOpacity(0.5)
                        : HexColor.fromInt(0x1c1c1e),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: QrImageView(
                data: Guard.jwt,
                version: QrVersions.auto,
                size: 250,
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Theme.of(context).primaryColorLight,
                ),
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: Theme.of(context).primaryColorLight,
                ),
                gapless: false,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'scan_me'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLightMode ? Colors.black : Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLightMode ? Colors.blue : Colors.white,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          offset: const Offset(4, 4),
                          blurRadius: 8.0,
                        ),
                      ],
                    ),
                    child: ShadowButton(
                      onTap: () {
                        TodoShare.share(Guard.jwt);
                      },
                      icon: const Icon(
                        Icons.share,
                        size: 18,
                        color: Colors.white,
                      ),
                      text: "share".tr,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
