// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart' as e;
import 'package:build/build.dart';

import 'annotation.dart';

class TestGenerator extends GeneratorForAnnotation<WebSandInterface> {
  static List<String> jsFunction = [];

  @override
  generateForAnnotatedElement(
      e.Element element, ConstantReader annotation, BuildStep buildStep) {
    analyseBuildStep(buildStep);
    // analyseAnnotation(annotation);
    analyseElement(element);
    String webViewCode = "";
    String webHtmlCode = "";
    for (var e in jsFunction) {
      webViewCode += "    ${webViewTemplate(e)}\n";
      webHtmlCode += "    ${webHTMLTemplate(e)}\n";
    }
    return webBindingCode(webViewCode, webHtmlCode);
  }

  String analyseElement(e.Element element) {
    switch (element.kind) {
      case e.ElementKind.CLASS:
        return _analyseElementForClass(element as e.ClassElement);
      case e.ElementKind.FUNCTION:
        return _analyseElementForMethod(element as e.FunctionElement);
      default:
        return "";
    }
  }

  String _analyseElementForClass(e.ClassElement classElement) {
    var fieldStr = "  class中拦截到的成员字段有：\n";
    for (var e in classElement.fields) {
      fieldStr += "   ${e.declaration}\n";
    }
    var methodStr = " class中拦截到的成员方法：\n";
    for (var e in classElement.methods) {
      for (var annotation in e.metadata) {
        if (annotation.element?.displayName == "DartMethod") {
          TestGenerator.jsFunction.add(e.name);
        }
      }
      methodStr += "   ${e.declaration.name}\n";
    }
    return "$fieldStr\n$methodStr";
  }

  String _analyseElementForMethod(e.FunctionElement methodElement) {
    var result =
        "方法名称 : ${methodElement.name}, 方法参数：${methodElement.parameters[0].declaration} \n";
    return result;
  }

  void analyseAnnotation(ConstantReader annotation) {
    print("analyseAnnotation \n");
    print("params - name : ${annotation.read("name")}\n");
    print("params - id : ${annotation.read("id")}\n");
  }

  void analyseBuildStep(BuildStep buildStep) {
    print("output： ${buildStep.inputId.toString()}\n");
  }
}

String webBindingCode(String webView, String webHtml) {
  return """
if (kIsPhone) {
$webView
} else {
$webHtml
}
 """;
}

String webViewTemplate(String name) {
  return """
parent["__dart_function_$name"] = WebViewEventChannel.handler("__dart_function_$name")
WebBridge.register("$name", (v) => {
    let [id, handle] =  parent["__dart_function_$name"](v)
    return { id: id, handle: handle }
})
  """;
}

String webHTMLTemplate(String name) {
  return """
WebBridge.register("$name", (v) => {
  return {
      id: 0, handle: new Promise((resolve) => {
          resolve(parent.__dart_function_$name(v))
      })
  };
})
  """;
}
