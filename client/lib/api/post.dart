import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/net.dart';

Future postNewRequest({
  required String title,
  required List<Map<String, dynamic>> text,
  required List<String> files,
  required List<int> indexs,
  required List<String> types,
}) async {
  List<MultipartFile> multipartFiles = [];
  for (var file in files) {
    multipartFiles.add(
      await MultipartFile.fromFile(
        Uri.parse(file).toFilePath(),
        filename: file.split("/").last,
      ),
    );
  }
  FormData formData = FormData.fromMap({
    'title': title,
    'text': jsonEncode(text),
    'files': multipartFiles,
    'indexs': indexs,
    'types': types,
  });
  return await HTTP.post(
    '/post/new',
    data: formData,
    options: Options(
      headers: {'Authorization': Guard.jwt},
      sendTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );
}

Future postMeRequest({
  int page = 1,
  int limit = 10,
  String createdAt = "2000-01-01T00:00:00Z",
}) async {
  return (await HTTP.get(
    '/post/me?page=$page&limit=$limit&created_at=$createdAt',
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data;
}

Future<bool?> postLikeRequest({required int postId}) async {
  return (await HTTP.post(
    '/post/like',
    data: {"post_id": postId},
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postGetRequest({required int postId}) async {
  return (await HTTP.get(
    '/post/get/$postId',
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data;
}

Future postFriendRequest({required int page, required int limit}) async {
  return (await HTTP.get(
    '/post/friend?page=$page&limit=$limit',
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postDetailRequest({required int id}) async {
  return (await HTTP.get(
    '/post/detail/$id',
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postVisitorsRequest() async {
  return (await HTTP.get(
    '/post/visitors',
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postHistoryRequest() async {
  return (await HTTP.get(
    '/post/history',
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postCommentNewRequest({
  required int postId,
  required int replyId,
  required String text,
}) async {
  return (await HTTP.post(
    '/post/comment/new',
    data: {'post_id': postId, 'text': text, 'reply_id': replyId},
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postCommentGetRequest({
  required int postId,
  required int page,
  required int pageSize,
}) async {
  return (await HTTP.post(
    '/post/comment/get',
    data: {'post_id': postId, 'page': page, 'page_size': pageSize},
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postCommentReplyGetRequest({
  required int postId,
  required int commentId,
  required int page,
  required int pageSize,
}) async {
  return (await HTTP.post(
    '/post/comment/reply/get',
    data: {
      'post_id': postId,
      'comment_id': commentId,
      'page': page,
      'page_size': pageSize,
    },
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postCommentDelRequest({
  required int commentId,
  required bool deleteReplies,
}) async {
  return (await HTTP.post(
    '/post/comment/del',
    data: {'comment_id': commentId, 'delete_replies': deleteReplies},
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}

Future postCommentLikeRequest({
  required int postId,
  required int commentId,
}) async {
  return (await HTTP.post(
    '/post/comment/like',
    data: {'post_id': postId, 'comment_id': commentId},
    options: Options(headers: {'Authorization': Guard.jwt}),
  )).data["data"];
}
