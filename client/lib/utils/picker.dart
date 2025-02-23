// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialog.dart';

enum FileType { web, app }

class TFile {
  String get name {
    throw UnimplementedError();
  }

  FileType get type {
    throw UnimplementedError();
  }

  Future<MultipartFile> get m {
    throw UnimplementedError();
  }

  XFile get x {
    throw UnimplementedError();
  }
}

class AppFile implements TFile {
  late String filePath;
  late XFile? xFile;

  AppFile(this.filePath);

  AppFile.fromXFile(XFile file) {
    xFile = file;
    filePath = file.path;
  }

  @override
  String get name => filePath;

  @override
  FileType get type => FileType.app;

  @override
  Future<MultipartFile> get m {
    return Future.delayed(Duration.zero, () {
      return MultipartFile.fromFileSync(filePath);
    });
  }

  @override
  XFile get x {
    if (xFile != null) {
      return xFile!;
    }
    return XFile(filePath);
  }
}

class WebFile implements TFile {
  late final html.File htmlFile;
  late XFile? xFile;

  WebFile(this.htmlFile);

  WebFile.fromXFile(XFile file) {
    htmlFile = html.File([], file.name);
    xFile = file;
  }

  @override
  String get name => htmlFile.name;

  @override
  FileType get type => FileType.web;

  @override
  Future<MultipartFile> get m {
    final Completer<MultipartFile> completer = Completer();

    if (xFile != null) {
      xFile!.readAsBytes().then((bits) {
        completer
            .complete(MultipartFile.fromBytes(bits, filename: xFile!.name));
      });
      return completer.future;
    }

    html.FileReader reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      completer.complete(MultipartFile.fromBytes(reader.result as List<int>,
          filename: htmlFile.name));
    });
    reader.readAsArrayBuffer(htmlFile);
    return completer.future;
  }

  @override
  XFile get x {
    if (xFile != null) {
      return xFile!;
    }
    return XFile(htmlFile.relativePath!);
  }
}

Future<List<TFile>> filePicker(
    {bool allowMultiple = false, List<String>? filter}) async {
  final Completer<List<TFile>> completer = Completer();
  if (kIsWeb) {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = allowMultiple;
    uploadInput.click();
    uploadInput.onChange.first.then((html.Event event) {
      final List<html.File>? files = uploadInput.files;
      if (!completer.isCompleted && files != null) {
        completer.complete(files.map((e) => WebFile(e)).toList());
      }
    });
  } else {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: allowMultiple);
    if (result != null && result.files.isNotEmpty) {
      if (!completer.isCompleted) {
        completer.complete(result.files.map((e) => AppFile(e.name)).toList());
      }
    }
  }
  return completer.future;
}

Future<TFile?> imagePicker() async {
  XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (xFile != null) {
    if (kIsWeb) {
      return WebFile.fromXFile(xFile);
    } else {
      return AppFile.fromXFile(xFile);
    }
  }
  return null;
}

Future urlPicker(BuildContext context, String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    if (context.mounted) {
      showTipDialog(context, content: "Could not launch $url");
    } else {
      if (kDebugMode) {
        print("Could not launch $url");
      }
    }
  }
}
