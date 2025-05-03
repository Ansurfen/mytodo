// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:universal_html/html.dart' as html;
import 'ui_app.dart' if (dart.library.html) 'ui_web.dart' as ui;
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:universal_html/js.dart' as js;

Widget webSandBox(WebSandBoxController controller) {
  if (kIsWeb) {
    String id = "sandBox";
    if (controller.id != null) {
      id = controller.id!;
      controller.id = id;
    }
    ui.platformViewRegistry.registerViewFactory(id, (int viewId) {
      if (controller is _WebSandBoxController4Web) {
        controller.listen();
        return controller.iFrameElement;
      }
      return html.IFrameElement();
    }, isVisible: false);
    return ui.htmlElementView(id);
  } else {
    late WebViewController ctr;
    if (controller is _WebSandBoxController4App) {
      ctr = controller.controller;
    } else {
      ctr = WebViewController();
    }
    return WebViewWidget(controller: ctr);
  }
}

abstract class WebSandBoxController {
  factory WebSandBoxController() {
    if (kIsWeb) {
      return _WebSandBoxController4Web();
    } else {
      return _WebSandBoxController4App();
    }
  }

  String? get width;

  set width(String? v);

  String? get height;

  set height(String? v);

  String? get id;

  set id(String? v);

  html.CssStyleDeclaration? get style;

  set style(html.CssStyleDeclaration? v);

  bool? get jsEnable;

  set jsEnable(bool? v);

  void addEventChannel(String type, EventCallback callback);

  void addDartHandler(String method, DartFunction callback);

  void sendEvent(String type, Object detail, {String targetOrigin});

  void loadFlutterAsset(String key);

  void loadFile(String absoluteFilePath);

  void loadHtmlString(String html);

  Future<Object> callMethod(String method, List<Object>? args);

  Future<Object> asyncCallMethod(String method, List<Object>? args);
}

typedef EventCallback = void Function(html.MessageEvent evt);
typedef DartFunction = dynamic Function(dynamic v);

class _WebSandBoxController4Web implements WebSandBoxController {
  late html.IFrameElement iFrameElement;
  late js.JsObject _jsObject;
  Map<String, EventCallback> evtCallback = <String, EventCallback>{};

  _WebSandBoxController4Web() {
    iFrameElement = html.IFrameElement();
    js.context["__web_builder__"] = (window) {
      _jsObject = window;
    };
  }

  void listen() {
    html.window.onMessage.listen((event) {
      Map<String, dynamic> evt = jsonDecode(event.data);
      EventCallback? cb = evtCallback[evt["type"]];
      if (cb != null) {
        cb(html.MessageEvent(evt["type"], data: evt["detail"]));
      }
    });
  }

  @override
  String? get height {
    return iFrameElement.height;
  }

  @override
  String? get width {
    return iFrameElement.width;
  }

  @override
  String? get id {
    return iFrameElement.id;
  }

  @override
  html.CssStyleDeclaration? style;

  @override
  set width(String? v) {
    iFrameElement.width = v;
  }

  @override
  set height(String? v) {
    iFrameElement.height = v;
  }

  @override
  bool? jsEnable;

  @override
  void loadFile(String absoluteFilePath) {
    iFrameElement.src = absoluteFilePath;
  }

  @override
  void loadFlutterAsset(String key) {
    iFrameElement.src = key;
  }

  @override
  void loadHtmlString(String html) {
    iFrameElement.srcdoc = html;
  }

  @override
  void addEventChannel(String type, EventCallback callback) {
    evtCallback[type] = callback;
  }

  @override
  Future<Object> callMethod(String method, List<Object>? args) async {
    if (args == null) {
      return await _jsObject.callMethod(method);
    }
    return await _jsObject.callMethod(method, args);
  }

  @override
  void sendEvent(String type, Object detail, {String targetOrigin = "*"}) {
    html.window.postMessage(
      jsonEncode({'type': type, 'detail': detail}),
      targetOrigin,
    );
  }

  @override
  set id(String? v) {
    if (v != null) {
      iFrameElement.id = v;
    }
  }

  @override
  void addDartHandler(String method, DartFunction callback) {
    js.context["__dart_function_$method"] = callback;
  }

  @override
  Future<Object> asyncCallMethod(String method, List<Object>? args) {
    Completer<Object> completer = Completer();
    EasyLoading.show(status: "loading...");
    callMethod(method, args).then((v) {
      if (v is int) {
        bool exit = false;
        for (int i = 0; i < 10; i++) {
          callMethod("WebViewEventChannel.get", [v]).then((Object? value) {
            if (value != null) {
              completer.complete(value);
              exit = true;
            }
          });
          if (exit) {
            break;
          }
        }
      }
    });
    EasyLoading.dismiss();
    return completer.future;
  }
}

class _WebSandBoxController4App implements WebSandBoxController {
  bool enableJS = false;
  late WebViewController controller;
  final Map<String, DartFunction> _dartFunction = <String, DartFunction>{};

  _WebSandBoxController4App() {
    controller =
        WebViewController()..addJavaScriptChannel(
          "__webview_event_bridge__",
          onMessageReceived: (msg) {
            Map<String, dynamic> callstack = jsonDecode(msg.message);
            var res = callDart(callstack["method"], callstack["args"]);
            callMethod("WebViewEventChannel.put", [callstack["id"], res]);
          },
        );
  }

  @override
  String? height;

  @override
  String? id;

  @override
  html.CssStyleDeclaration? style;

  @override
  String? width;

  @override
  bool? get jsEnable {
    return enableJS;
  }

  @override
  void loadFile(String absoluteFilePath) {
    controller.loadFile(absoluteFilePath);
  }

  @override
  void loadFlutterAsset(String key) {
    controller.loadFlutterAsset(key);
  }

  @override
  void loadHtmlString(String html) {
    controller.loadHtmlString(html);
  }

  @override
  set jsEnable(bool? v) {
    if (v != null && v) {
      enableJS = true;
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
  }

  @override
  void addEventChannel(String type, EventCallback callback) {
    if (type == "__webview_event_bridge__") {
      throw "event bridge was occupied, and try to change event's type literal.";
    }
    controller.addJavaScriptChannel(
      type,
      onMessageReceived: (msg) {
        String evt = msg.message;
        if (evt.startsWith("'") && evt.endsWith("'")) {
          evt = evt.substring(1, evt.length - 1);
        }
        Map<String, dynamic> json = jsonDecode(evt);
        callback(html.MessageEvent(type, data: json["detail"]));
      },
    );
  }

  @override
  Future<Object> callMethod(String method, List<Object>? args) {
    List<String> argStr = [];
    if (args != null) {
      for (Object obj in args) {
        if (obj is String) {
          argStr.add("`$obj`");
        } else {
          argStr.add(obj.toString());
        }
      }
    }
    return controller.runJavaScriptReturningResult(
      "$method(${argStr.join(",")})",
    );
  }

  @override
  void sendEvent(String type, Object detail, {String targetOrigin = "*"}) {
    controller.runJavaScript(
      "__webview_event_listener_entry(`${jsonEncode({'type': type, 'detail': detail})}`)",
    );
  }

  dynamic callDart(String method, String? args) {
    DartFunction? cb = _dartFunction[method];
    if (cb != null) {
      if (args != null) {
        return cb(jsonDecode(args));
      }
      return cb(null);
    }
    return null;
  }

  @override
  void addDartHandler(String method, DartFunction callback) {
    _dartFunction["__dart_function_$method"] = callback;
  }

  @override
  Future<Object> asyncCallMethod(String method, List<Object>? args) {
    Completer<Object> completer = Completer();
    EasyLoading.show(status: "loading...");
    callMethod(method, args).then((v) {
      if (v is int) {
        bool exit = false;
        for (int i = 0; i < 10; i++) {
          callMethod("WebViewEventChannel.get", [v]).then((Object? value) {
            if (value != null) {
              completer.complete(value);
              exit = true;
            }
          });
          if (exit) {
            break;
          }
        }
      }
    });
    EasyLoading.dismiss();
    return completer.future;
  }
}
