// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:my_todo/component/button/shadow_button.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/component/textarea.dart';
import 'package:my_todo/theme/provider.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          ThemeProvider.isDarkByContext(context) ? Colors.black : Colors.white,
      child: SafeArea(
        top: false,
        child: todoScaffold(
          context,
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16,
                      right: 16,
                    ),
                    child: Image.asset('assets/images/helpImage.png'),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'feedback'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            ThemeProvider.isDarkByContext(context)
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'feedback_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            ThemeProvider.isDarkByContext(context)
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 32, right: 32),
                    child: TextArea(hintText: "feedback_hint".tr),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ShadowButton(text: "send".tr, onTap: () {}),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
