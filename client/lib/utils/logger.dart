// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'dart:io';
import 'package:logger/logger.dart';

class LoggerFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // if (event.level == Level.error ||
    //     event.level == Level.warning ||
    //     event.level == Level.trace) {
    //   return true;
    // }
    return true;
  }
}

class TodoFileOutput extends ConsoleOutput {
  File file;

  late String filePath;

  TodoFileOutput(this.file);

  @override
  void output(OutputEvent event) async {
    super.output(event);
    for (var line in event.lines) {
      await file.writeAsString("${line.toString()}\n",
          mode: FileMode.writeOnlyAppend);
    }
  }
}

class ConsoleOutputExt extends ConsoleOutput {}
