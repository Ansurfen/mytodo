// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTaskDto _$GetTaskDtoFromJson(Map<String, dynamic> json) => GetTaskDto(
      json['id'] as int,
      json['topic'] as String,
      json['name'] as String,
      json['desc'] as String,
      DateTime.parse(json['departure'] as String),
      DateTime.parse(json['arrival'] as String),
      (json['conds'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$GetTaskDtoToJson(GetTaskDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'name': instance.name,
      'desc': instance.desc,
      'departure': instance.departure.toIso8601String(),
      'arrival': instance.arrival.toIso8601String(),
      'conds': instance.conds,
    };

InfoTaskDto _$InfoTaskDtoFromJson(Map<String, dynamic> json) => InfoTaskDto(
      json['name'] as String,
      json['desc'] as String,
      DateTime.parse(json['departure'] as String),
      DateTime.parse(json['arrival'] as String),
      (json['conds'] as List<dynamic>)
          .map((e) => InfoTaskCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InfoTaskDtoToJson(InfoTaskDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'desc': instance.desc,
      'departure': instance.departure.toIso8601String(),
      'arrival': instance.arrival.toIso8601String(),
      'conds': instance.conds,
    };

InfoTaskCondition _$InfoTaskConditionFromJson(Map<String, dynamic> json) =>
    InfoTaskCondition(
      json['type'] as int,
      (json['want_params'] as List<dynamic>).map((e) => e as String).toList(),
      (json['got_params'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$InfoTaskConditionToJson(InfoTaskCondition instance) =>
    <String, dynamic>{
      'type': instance.type,
      'want_params': instance.wantParams,
      'got_params': instance.gotParams,
    };
