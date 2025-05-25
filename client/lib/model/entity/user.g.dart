// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  (json['id'] as num).toInt(),
  json['name'] as String,
  json['email'] as String,
  telephone: json['telephone'] as String? ?? '',
  about: json['about'] as String? ?? '',
)..isMale = json['is_male'] as bool? ?? true;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'telephone': instance.telephone,
  'is_male': instance.isMale,
};
