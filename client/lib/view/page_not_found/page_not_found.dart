import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo/component/icon.dart';
import 'package:my_todo/component/scaffold.dart';
import 'package:my_todo/router/provider.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return todoScaffold(
      context,
      appBar: AppBar(
        elevation: 0,
        leading: todoTextIconButton(
          context,
          icon: Icons.arrow_back_ios,
          onPressed: () => RouterProvider.back(),
        ),
        title: Text('page_not_found'.tr),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 100),
        child: Image.asset("assets/images/page_not_found.png"),
      ),
    );
  }
}
