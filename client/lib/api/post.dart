import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/api/response.dart';
import 'package:my_todo/model/dao/post.dart';
import 'package:my_todo/model/dto/post.dart';
import 'package:my_todo/model/entity/post.dart';
import 'package:my_todo/utils/guard.dart';
import 'package:my_todo/utils/net.dart';
import 'package:my_todo/utils/picker.dart';

class GetPostRequest {
  int page;
  int count;

  GetPostRequest(this.page, this.count);
}

class GetPostResponse extends BaseResponse {
  late final List<GetPostDto> data;

  GetPostResponse(this.data) : super({});

  GetPostResponse.fromResponse(Response res)
      : data = (res.data['data']['posts'] as List)
            .map((e) => GetPostDto.fromJson(e))
            .toList(),
        super(res.data);
}

Future<GetPostResponse> getPost(GetPostRequest req) async {
  if (Guard.isOffline()) {
    await PostDao.findMany();
    return GetPostResponse((await PostDao.findMany())
        .map((e) => GetPostDto(
            e.id ?? 0,
            e.uid,
            "",
            true,
            DateTime.fromMicrosecondsSinceEpoch(e.createAt),
            e.content,
            [],
            0,
            0,
            false))
        .toList());
  }
  return GetPostResponse.fromResponse(await HTTP.get("/post/get",
      queryParams: {'page': req.page, 'count': req.count},
      options: Options(headers: {'x-token': Guard.jwt})));
}

// @FormDataSerializable()
class CreatePostRequest {
  // @FormDataKey(name: "uid")
  int user;

  // @FormDataKey(name: "content")
  String content;

  // @FormDataKey(toFormData: )
  List<TFile> images;

  // static _prepare(List<TFile> images) =>
  //     images.map((e) async => MapEntry("files", await e.m)).toList();

  CreatePostRequest(this.user, this.content, this.images);

  Future<FormData> toFormData() async {
    FormData formData = FormData();
    formData.fields.addAll({
      'uid': "$user",
      'content': content,
    }.entries);
    for (TFile img in images) {
      formData.files.add(MapEntry("files", await img.m));
    }
    return formData;
  }
}

class CreatePostResponse extends BaseResponse {
  CreatePostResponse() : super({});

  CreatePostResponse.fromResponse(Response res) : super(res.data);
}

Future<CreatePostResponse> createPost(CreatePostRequest req) async {
  // if (Guard.isOffline()) {
  //   int now = DateTime.now().microsecondsSinceEpoch;
  //   Post c = Post(Guard.user, req.content, now, 0);
  //   await PostDao.create(c);
  //   Guard.eventBus.fire(c);
  //   return CreatePostResponse();
  // }
  if (Guard.isOffline()) {
    int now = DateTime.now().microsecondsSinceEpoch;
    PostDao.create(Post(Guard.user, req.content, now, 0, []));
    return CreatePostResponse();
  }

  return CreatePostResponse.fromResponse(await HTTP.post("/post/add",
      data: await req.toFormData(),
      options: Options(headers: {
        "x-token": Guard.jwt,
      })));
}

class GetPostCommentRequest {
  int pid;
  int page;
  int pageSize;

  GetPostCommentRequest(
      {required this.pid, required this.page, required this.pageSize});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll(
        {"pid": "$pid", "page": "$page", "pageSize": "$pageSize"}.entries);
    return formData;
  }
}

class GetPostCommentResponse extends BaseResponse {
  late final List<PostComment> comments;

  GetPostCommentResponse() : super({});

  GetPostCommentResponse.fromResponse(Response res) : super(res.data) {
    comments = res.data["data"]["comments"] != null
        ? (res.data["data"]["comments"] as List)
            .map((e) => PostComment.fromJson(e))
            .toList()
        : [];
  }
}

Future<GetPostCommentResponse> getPostComment(GetPostCommentRequest req) async {
  if (Guard.isOffline()) {
    return GetPostCommentResponse();
  }
  return GetPostCommentResponse.fromResponse(
      await HTTP.post('/post/comment/get',
          data: req.toFormData(),
          options: Options(headers: {
            "x-token": Guard.jwt,
          })));
}

class PostCommentFavoriteCountRequest {
  String id;

  PostCommentFavoriteCountRequest({required this.id});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({'comment_id': id}.entries);
    return formData;
  }
}

class PostCommentFavoriteCountResponse extends BaseResponse {
  PostCommentFavoriteCountResponse() : super({});

  PostCommentFavoriteCountResponse.fromResponse(Response res) : super(res.data);
}

Future<PostCommentFavoriteCountResponse> postCommentFavoriteCount(
    PostCommentFavoriteCountRequest req) async {
  if (Guard.isOffline()) {
    return PostCommentFavoriteCountResponse();
  }
  return PostCommentFavoriteCountResponse.fromResponse(
      await HTTP.post('/post/comment/favoriteCount', data: req.toFormData()));
}

class PostDetailRequest {
  int id;

  PostDetailRequest({required this.id});
}

@JsonSerializable()
class PostDetailResponse extends BaseResponse {
  @JsonKey(name: "username", defaultValue: '')
  late String username;

  @JsonKey(name: "favorite", defaultValue: 0)
  late int favorite;

  @JsonKey(name: "is_favorite", defaultValue: false)
  late bool isFavorite;

  @JsonKey(name: "uid", defaultValue: 0)
  late int uid;

  @JsonKey(name: "isMale", defaultValue: false)
  late bool isMale;

  @JsonKey(name: "images", defaultValue: [])
  late List<String> images;

  @JsonKey(name: "content", defaultValue: '')
  late String content;

  PostDetailResponse(
      {required this.username,
      required this.isFavorite,
      required this.favorite,
      required this.uid})
      : super({});

  PostDetailResponse.fromResponse(Response res) : super(res.data) {
    username = res.data["data"]["username"];
    uid = res.data["data"]["uid"];
    favorite = res.data["data"]["favorite"];
    isMale = res.data["data"]["isMale"];
    images = res.data["data"]["images"] ?? [];
    content = res.data["data"]["content"];
    isFavorite = res.data["data"]["is_favorite"];
  }
}

Future<PostDetailResponse> postDetail(PostDetailRequest req) async {
  return PostDetailResponse.fromResponse(await HTTP.get(
      '/post/detail/${req.id}',
      options: Options(headers: {'x-token': Guard.jwt})));
}

class PostAddCommentRequest {
  int reply;

  String content;

  int id;

  PostAddCommentRequest(
      {required this.id, required this.reply, required this.content});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({
      'pid': "$id",
      'reply': "$reply",
      'content': content,
    }.entries);
    return formData;
  }
}

class PostAddCommentResponse extends BaseResponse {
  late String id;

  PostAddCommentResponse({required this.id}) : super({});

  PostAddCommentResponse.fromResponse(Response res) : super(res.data) {
    id = res.data["data"]["id"];
  }
}

Future<PostAddCommentResponse> postAddComment(PostAddCommentRequest req) async {
  return PostAddCommentResponse.fromResponse(
      await HTTP.post("/post/comment/add",
          data: req.toFormData(),
          options: Options(headers: {
            "x-token": Guard.jwt,
          })));
}

class PostAddCommentReplyRequest {
  String id;

  String content;

  int reply;

  PostAddCommentReplyRequest(
      {required this.id, required this.reply, required this.content});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({
      'id': id,
      'reply': "$reply",
      'content': content,
    }.entries);
    return formData;
  }
}

class PostAddCommentReplyResponse extends BaseResponse {
  late String id;

  PostAddCommentReplyResponse({required this.id}) : super({});

  PostAddCommentReplyResponse.fromResponse(Response res) : super(res.data) {
    id = res.data["data"]["id"];
  }
}

Future<PostAddCommentReplyResponse> postAddCommentReply(
    PostAddCommentReplyRequest req) async {
  return PostAddCommentReplyResponse.fromResponse(
      await HTTP.post("/post/comment/reply/add",
          data: req.toFormData(),
          options: Options(headers: {
            "x-token": Guard.jwt,
          })));
}

class PostCommentFavoriteRequest {
  String id;

  PostCommentFavoriteRequest({required this.id});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({'comment_id': id}.entries);
    return formData;
  }
}

class PostCommentFavoriteResponse extends BaseResponse {
  bool success = false;

  PostCommentFavoriteResponse(super.json);

  PostCommentFavoriteResponse.fromResponse(Response res)
      : success = res.data["data"]["success"],
        super(res.data);
}

Future<PostCommentFavoriteResponse> postCommentFavorite(
    PostCommentFavoriteRequest req) async {
  return PostCommentFavoriteResponse.fromResponse(
      await HTTP.post("/post/comment/favorite",
          data: req.toFormData(),
          options: Options(headers: {
            "x-token": Guard.jwt,
          })));
}

class PostCommentUnFavoriteRequest {
  late String id;

  PostCommentUnFavoriteRequest({required this.id});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({'comment_id': id}.entries);
    return formData;
  }
}

class PostCommentUnFavoriteResponse extends BaseResponse {
  bool success = false;

  PostCommentUnFavoriteResponse(super.json);

  PostCommentUnFavoriteResponse.fromResponse(Response res)
      : success = res.data["data"]["success"],
        super(res.data);
}

Future<PostCommentUnFavoriteResponse> postCommentUnFavorite(
    PostCommentUnFavoriteRequest req) async {
  return PostCommentUnFavoriteResponse.fromResponse(
      await HTTP.post('/post/comment/unfavorite',
          data: req.toFormData(),
          options: Options(headers: {
            "x-token": Guard.jwt,
          })));
}

class PostFavoriteRequest {
  late int id;

  PostFavoriteRequest({required this.id});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({'pid': "$id"}.entries);
    return formData;
  }
}

class PostFavoriteResponse extends BaseResponse {
  bool success = false;

  PostFavoriteResponse(super.json);

  PostFavoriteResponse.fromResponse(Response res)
      : success = res.data["data"]["success"],
        super(res.data);
}

Future<PostFavoriteResponse> postFavorite(PostFavoriteRequest req) async {
  return PostFavoriteResponse.fromResponse(await HTTP.post('/post/favorite/add',
      data: req.toFormData(),
      options: Options(headers: {
        "x-token": Guard.jwt,
      })));
}

class PostUnFavoriteRequest {
  late int id;

  PostUnFavoriteRequest({required this.id});

  FormData toFormData() {
    FormData formData = FormData();
    formData.fields.addAll({'pid': "$id"}.entries);
    return formData;
  }
}

class PostUnFavoriteResponse extends BaseResponse {
  bool success = false;

  PostUnFavoriteResponse(super.json);

  PostUnFavoriteResponse.fromResponse(Response res)
      : success = res.data["data"]["success"],
        super(res.data);
}

Future<PostUnFavoriteResponse> postUnFavorite(PostUnFavoriteRequest req) async {
  return PostUnFavoriteResponse.fromResponse(
      await HTTP.post('/post/favorite/del',
          data: req.toFormData(),
          options: Options(headers: {
            "x-token": Guard.jwt,
          })));
}
