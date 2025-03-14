import 'package:flutter/widgets.dart';
import 'package:my_todo/utils/store.dart';
import 'package:showcaseview/showcaseview.dart';

class Guide {
  static void start(BuildContext context) {
    bool? enableGuide = Store.localStorage.getBool("guide");
    if (enableGuide == null) {
      Store.localStorage.setBool('guide', false);
      enableGuide = true;
    }

    if (enableGuide) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) =>
            ShowCaseWidget.of(context).startShowCase([one, two, three, four]),
      );
    }
  }

  static GlobalKey one = GlobalKey();
  static GlobalKey two = GlobalKey();
  static GlobalKey three = GlobalKey();
  static GlobalKey four = GlobalKey();
}
