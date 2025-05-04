import 'package:json_annotation/json_annotation.dart';
import 'package:my_todo/utils/json.dart';

part 'post.g.dart';

@JsonSerializable()
class PostDetail {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "created_at")
  DateTime createdAt;

  @JsonKey(name: "title")
  String title;

  @JsonKey(name: "text")
  List text;

  @JsonKey(name: "is_male")
  bool isMale;

  @JsonKey(name: "uid")
  int uid;

  @JsonKey(name: "username")
  String username;

  @JsonKey(name: "about")
  String about;

  @JsonKey(name: "like_count")
  int likeCount;

  @JsonKey(name: "visit_count")
  int visitCount;

  @JsonKey(name: "is_favorite")
  bool isFavorite;

  PostDetail({
    required this.id,
    required this.uid,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.username,
    required this.isMale,
    required this.about,
    required this.likeCount,
    required this.visitCount,
    required this.isFavorite,
  });

  static PostDetail fromJson(JsonObject json) => _$PostDetailFromJson(json);
}
