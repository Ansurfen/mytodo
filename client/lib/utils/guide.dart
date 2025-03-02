import 'package:flutter/widgets.dart';
import 'package:showcaseview/showcaseview.dart';

class Guide {
  bool enable = true;

  static void start(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase([one, two, three, four]),
    );
  }

  static GlobalKey one = GlobalKey();
  static GlobalKey two = GlobalKey();
  static GlobalKey three = GlobalKey();
  static GlobalKey four = GlobalKey();
}
