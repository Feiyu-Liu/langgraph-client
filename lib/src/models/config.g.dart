// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  recursionLimit: (json['recursion_limit'] as num?)?.toInt(),
  configurable: json['configurable'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
  'tags': ?instance.tags,
  'recursion_limit': ?instance.recursionLimit,
  'configurable': ?instance.configurable,
};
