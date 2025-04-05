// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCardModel _$TaskCardModelFromJson(Map<String, dynamic> json) =>
    TaskCardModel(
      (json['id'] as num).toInt(),
      json['icon'] as String,
      json['name'] as String,
      json['description'] as String,
      parseCondition(json['conds'] as List<Map<dynamic, dynamic>>),
    );
