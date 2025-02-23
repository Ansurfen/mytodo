// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
Future<T> Function() doOnce<T>(Future<T> Function() callback) {
  bool once = false;
  return () {
    if (!once) {
      once = true;
      return callback();
    }
    return Future.value();
  };
}
