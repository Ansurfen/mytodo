// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:analyzer/dart/element/element.dart' as e;
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

class FormDataSerializable {
  const FormDataSerializable();
}

class FormDataKey {
  final String? name;
  final Function? toFormData;

  const FormDataKey({this.name, this.toFormData});
}

class FormDataGenerator extends GeneratorForAnnotation<FormDataSerializable> {
  @override
  generateForAnnotatedElement(
      e.Element element, ConstantReader annotation, BuildStep buildStep) {
    analyseElement(element);
    return "";
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
        print(annotation.element);
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
}

