// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_todo/view/user/forget/forget_binding.dart';
import 'package:my_todo/view/user/forget/forget_page.dart';
import 'package:my_todo/view/user/license/license_binding.dart';
import 'package:my_todo/view/user/license/license_page.dart';
import 'package:my_todo/view/user/profile/profile_binding.dart';
import 'package:my_todo/view/user/sign/login_binding.dart';
import 'package:my_todo/view/user/sign/login_page.dart';
import 'package:my_todo/view/user/verify/verification_page.dart';
import 'package:my_todo/view/user/edit/edit_binding.dart';
import 'package:my_todo/view/user/edit/edit_page.dart';
import 'package:my_todo/view/user/profile/profile_page.dart';

class UserRouter {
  static List<GetPage> pages = [sign, license, forget, edit, verify, profile];

  static String base(String pattern) => "/user$pattern";

  static final sign = GetPage(
    name: base('/sign'),
    page: () => const LoginPage(),
    binding: LoginBinding(),
  );

  static final license = GetPage(
    name: base('/license'),
    page: () => const LicensePage(),
    binding: LicenseBinding(),
  );

  static final forget = GetPage(
    name: base('/forget'),
    page: () => const ForgetPage(),
    binding: ForgetBinding(),
  );

  static final edit = GetPage(
    name: base('/edit'),
    page: () => const EditPage(),
    binding: EditBinding(),
  );

  static final profile = GetPage(
    name: base('/profile'),
    page: () => const ProfilePage(),
    binding: ProfileBinding(),
  );

  static final verify = GetPage(
    name: base('/verify'),
    page: () => const VerificationPage(),
  );
}
