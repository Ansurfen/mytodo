// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_todo/view/map/select/location_binding.dart';

import 'package:my_todo/view/map/locate/locate_page.dart';
import 'package:my_todo/view/map/select/location_page.dart';

class MapRouter {
  static List<GetPage> pages = [select, locate];

  static String base(String pattern) => "/map$pattern";

  static final select = GetPage(
    name: base('/select'),
    page: () => const LocatePage(),
    binding: LocationBinding(),
  );

  static final locate = GetPage(
    name: base('/locate'),
    page: () => const MapLocatePage(taskId: 0, condId: 0),
  );
}
