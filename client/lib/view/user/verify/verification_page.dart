// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:get/get.dart';
import 'package:my_todo/component/icon.dart';
import 'package:my_todo/component/timer/repeatable_countdown.dart';
import 'package:my_todo/router/provider.dart';
import 'package:my_todo/router/user.dart';
import 'package:my_todo/theme/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';

class Constants {
  static const Color primaryColor = Color(0xffFBFBFB);
  static const String otpGifImage = "images/otp.gif";
}

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  final String? phoneNumber = "xxx@gmail.com";

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  TextEditingController textEditingController = TextEditingController();

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: _title()),
          const SizedBox(height: 38),
          RichText(
            text: TextSpan(
              text: "verify_email".tr,
              children: [
                TextSpan(
                  text: "${widget.phoneNumber}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 50,
          ),
          Center(
            child: Text(
              "verify_enter".tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          _pinTextField(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  hasError ? "verify_error".tr : "",
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          _resend()
        ],
      ),
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              RouterProvider.back(failPage: UserRouter.sign);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: ThemeProvider.plainColor(context),
            )),
        const Text(
          "Verification",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        todoTextIconButton(context, onPressed: () {}, icon: Icons.help)
      ],
    );
  }

  Widget _pinTextField() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 30,
        ),
        child: PinCodeTextField(
          appContext: context,
          pastedTextStyle: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
          ),
          length: 6,
          blinkWhenObscuring: true,
          animationType: AnimationType.fade,
          validator: (v) => null,
          pinTheme: PinTheme(
            inactiveColor: Theme.of(context).primaryColorLight,
            activeColor: Theme.of(context).primaryColorLight,
            selectedColor: Theme.of(context).primaryColor,
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
          ),
          cursorColor: Colors.black,
          animationDuration: const Duration(milliseconds: 300),
          // enableActiveFill: true,
          errorAnimationController: errorController,
          controller: textEditingController,
          keyboardType: TextInputType.number,
          boxShadows: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
          onCompleted: (v) {
            formKey.currentState!.validate();
            if (currentText.length != 6 || currentText != "123456") {
              errorController!.add(ErrorAnimationType.shake);
              setState(() => hasError = true);
            } else {
              setState(
                () {
                  hasError = false;
                  snackBar("OTP Verified!!");
                },
              );
            }
          },
          onChanged: (value) {
            setState(() {
              currentText = value;
            });
          },
          beforeTextPaste: (text) {
            debugPrint("Allowing to paste $text");
            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
            //but you can show anything you want here, like your pop up saying wrong paste format or etc
            return true;
          },
        ),
      ),
    );
  }

  Widget _resend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            "opt_not_receive".tr,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary, fontSize: 15),
          ),
        ),
        const SizedBox(height: 15),
        RepeatableCountdown(
          total: 60,
          countingWidget: (cnt) => Text(
            "$cnt" "opt_repeat_sec".tr,
            style: TextStyle(
              // color: Color(0xFF91D3B3),
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          freeWidget: Text(
            "opt_resend".tr,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
