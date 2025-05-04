// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDetail _$PostDetailFromJson(Map<String, dynamic> json) => PostDetail(
  id: (json['id'] as num).toInt(),
  uid: (json['uid'] as num).toInt(),
  title: json['title'] as String,
  text: json['text'] as List<dynamic>,
  createdAt: DateTime.parse(json['created_at'] as String),
  username: json['username'] as String,
  isMale: json['is_male'] as bool,
  about: json['about'] as String,
  likeCount: (json['like_count'] as num).toInt(),
  visitCount: (json['visit_count'] as num).toInt(),
  isFavorite: json['is_favorite'] as bool,
);

Map<String, dynamic> _$PostDetailToJson(PostDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'title': instance.title,
      'text': instance.text,
      'is_male': instance.isMale,
      'uid': instance.uid,
      'username': instance.username,
      'about': instance.about,
      'like_count': instance.likeCount,
      'visit_count': instance.visitCount,
      'is_favorite': instance.isFavorite,
    };
