// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:my_todo/utils/web_sanbox/annotation.dart';

@WebSandInterface()
class TLocation {

  @DartMethod("abc")
  static String abc() {
    return "abc called";
  }

  int test() {
    return 0;
  }
}
