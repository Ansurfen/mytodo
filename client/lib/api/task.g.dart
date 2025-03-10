// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    CreateTaskRequest(
      (json['topic'] as num).toInt(),
      json['name'] as String,
      json['desc'] as String,
      DateTime.parse(json['departure'] as String),
      DateTime.parse(json['arrival'] as String),
      TaskCondition.conditionsFromJson(json['conds'] as List),
    );

Map<String, dynamic> _$CreateTaskRequestToJson(CreateTaskRequest instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'name': instance.name,
      'desc': instance.desc,
      'departure': instance.departure.toIso8601String(),
      'arrival': instance.arrival.toIso8601String(),
      'conds': instance.conds,
    };

CommitTaskRequest _$CommitTaskRequestFromJson(Map<String, dynamic> json) =>
    CommitTaskRequest(
      (json['tid'] as num).toInt(),
      (json['type'] as num).toInt(),
      json['param'] as String,
    );

Map<String, dynamic> _$CommitTaskRequestToJson(CommitTaskRequest instance) =>
    <String, dynamic>{
      'tid': instance.task,
      'type': instance.type,
      'param': instance.param,
    };

TaskHasPermRequest _$TaskHasPermRequestFromJson(Map<String, dynamic> json) =>
    TaskHasPermRequest(tid: (json['tid'] as num).toInt());

Map<String, dynamic> _$TaskHasPermRequestToJson(TaskHasPermRequest instance) =>
    <String, dynamic>{'tid': instance.tid};
