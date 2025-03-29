// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPostDto _$GetPostDtoFromJson(Map<String, dynamic> json) => GetPostDto(
  (json['id'] as num?)?.toInt() ?? 0,
  (json['uid'] as num?)?.toInt() ?? 0,
  json['username'] as String? ?? '',
  json['isMale'] as bool? ?? false,
  string2DateTime(json['created_at'] as String),
  json['content'] as String? ?? '',
  json['image'] == null ? [] : MImage.imagesFromJson(json['image'] as List?),
  (json['fc'] as num?)?.toInt() ?? 0,
  (json['cc'] as num?)?.toInt() ?? 0,
  json['is_favorite'] as bool? ?? false,
);

Map<String, dynamic> _$GetPostDtoToJson(GetPostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'username': instance.username,
      'isMale': instance.isMale,
      'created_at': instance.createAt.toIso8601String(),
      'content': instance.content,
      'image': instance.images,
      'fc': instance.favoriteCnt,
      'cc': instance.commentCnt,
      'is_favorite': instance.isFavorite,
    };
