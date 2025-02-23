// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'formdata.dart';

Builder formDataBuilder(BuilderOptions options) =>
    LibraryBuilder(FormDataGenerator());
