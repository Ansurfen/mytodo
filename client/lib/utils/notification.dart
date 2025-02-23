// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotifyProvider {
  static void _selectedCallback(NotificationResponse res) {
    print(res);
  }

  static late final INotification _notification;

  static Future<void> init() async {
    if (kIsWeb) {
      _notification = WebNotification(_selectedCallback);
    } else {
      _notification = LocalNotification(_selectedCallback);
      await _notification.init();
    }
  }

  static void sendJson(String title, String body, {dynamic params}) {
    send(title, body, params: jsonEncode(params));
  }

  static void send(String title, String body, {String? params}) {
    _notification.send(title, body, params: params);
  }
}

abstract class INotification {
  Future<void> init() async {}

  void send(String title, String body, {String? params}) {}
}

class WebNotification implements INotification {
  final ValueChanged<NotificationResponse>? _selectedCallback;

  WebNotification(this._selectedCallback);

  @override
  Future<void> init() async {}

  @override
  void send(String title, String body, {String? params}) {
    BuildContext? context = Get.context;
    late Color bgColor, textColor;
    if (context != null) {
      ThemeData themeData = Theme.of(context);
      if (themeData.brightness == Brightness.dark) {
        bgColor = Colors.grey.withOpacity(0.5);
        textColor = Colors.white;
      } else {
        bgColor = Colors.white.withOpacity(0.5);
        textColor = Colors.grey;
      }
    } else {
      bgColor = Colors.white.withOpacity(0.5);
      textColor = Colors.grey;
    }
    Get.snackbar(title, body, onTap: (evt) {
      _selectedCallback!(NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: -1,
          payload: params));
    }, backgroundColor: bgColor, colorText: textColor);
  }
}

class LocalNotification implements INotification {
  final FlutterLocalNotificationsPlugin np = FlutterLocalNotificationsPlugin();
  final ValueChanged<NotificationResponse>? _selectedCallback;

  LocalNotification(this._selectedCallback);

  @override
  Future<void> init() async {
    var android = const AndroidInitializationSettings("@mipmap/ic_launcher");

    await np.initialize(InitializationSettings(android: android),
        onDidReceiveNotificationResponse: _selectedCallback);
  }

  /// params为点击通知时，可以拿到的参数，title和body仅仅是展示作用
  /// Map params = {};
  /// params['type'] = "100";
  /// params['id'] = "10086";
  /// params['content'] = "content";
  /// notification.send("title", "content",params: json.encode(params));
  ///
  /// notificationId指定时，不在根据时间生成
  @override
  void send(String title, String body, {int? notificationId, String? params}) {
    // 构建描述
    var androidDetails = const AndroidNotificationDetails(
      //区分不同渠道的标识
      'channelId',

      //channelName渠道描述不要随意填写，会显示在手机设置，本app 、通知列表中，
      //规范写法根据业务：比如： 重要通知，一般通知、或者，交易通知、消息通知、等
      'channelName',

      //通知的级别
      importance: Importance.max,
      priority: Priority.high,

      //可以单独设置每次发送通知的图标
      // icon: ''

      //显示进度条 3个参数必须同时设置
      // progress: 19,
      // maxProgress: 100,
      // showProgress: true
    );
    //ios配置选项相对较少

    var details = NotificationDetails(android: androidDetails);

    // 显示通知, 第一个参数是id,id如果一致则会覆盖之前的通知
    // String? payload, 点击时可以拿到的参数
    np.show(notificationId ?? DateTime.now().millisecondsSinceEpoch >> 10,
        title, body, details,
        payload: params);
  }

  ///清除所有通知
  void cleanNotification() {
    np.cancelAll();
  }

  ///清除指定id的通知
  /// `tag`参数指定Android标签。 如果提供，
  /// 那么同时匹配 id 和 tag 的通知将会
  /// 被取消。 `tag` 对其他平台没有影响。
  void cancelNotification(int id, {String? tag}) {
    np.cancel(id, tag: tag);
  }
}
