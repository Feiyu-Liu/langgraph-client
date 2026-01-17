// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Assistant _$AssistantFromJson(Map<String, dynamic> json) => Assistant(
  assistantId: json['assistant_id'] as String,
  graphId: json['graph_id'] as String,
  config: AssistantConfig.fromJson(json['config'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
  version: (json['version'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$AssistantToJson(Assistant instance) => <String, dynamic>{
  'assistant_id': instance.assistantId,
  'graph_id': instance.graphId,
  'config': instance.config.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
  'version': ?instance.version,
  'name': ?instance.name,
};

AssistantConfig _$AssistantConfigFromJson(Map<String, dynamic> json) =>
    AssistantConfig(
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      recursionLimit: (json['recursion_limit'] as num?)?.toInt(),
      configurable: json['configurable'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AssistantConfigToJson(AssistantConfig instance) =>
    <String, dynamic>{
      'tags': ?instance.tags,
      'recursion_limit': ?instance.recursionLimit,
      'configurable': ?instance.configurable,
    };
