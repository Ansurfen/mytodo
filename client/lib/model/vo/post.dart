// Copyright 2025 The MyTodo Authors. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.
import 'package:my_todo/model/dto/post.dart';
import 'package:my_todo/utils/guard.dart';

class PostDetailModel extends GetPostDto {
  late List<String> imageUri;

  PostDetailModel(super.id, super.uid, super.username, super.isMale, super.createAt,
      super.content, super.images, super.favoriteCnt, super.commentCnt, super.isFavorite)
      : imageUri = [];

  PostDetailModel.fromDto(GetPostDto v)
      : super(v.id, v.uid, v.username, v.isMale, v.createAt, v.content,
            v.images, v.favoriteCnt, v.commentCnt, v.isFavorite) {
    imageUri =
        v.images.map((e) => "${Guard.server}/post/image/${e.path}").toList();
  }

  static PostDetailModel empty() {
    return PostDetailModel(0, 0, "", false, DateTime.now(), "", [], 0, 0, false);
  }
}
