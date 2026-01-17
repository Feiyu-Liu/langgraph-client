// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantVersion _$AssistantVersionFromJson(Map<String, dynamic> json) =>
    AssistantVersion(
      assistantId: json['assistant_id'] as String,
      version: (json['version'] as num).toInt(),
      graphId: json['graph_id'] as String,
      config: AssistantConfig.fromJson(json['config'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$AssistantVersionToJson(AssistantVersion instance) =>
    <String, dynamic>{
      'assistant_id': instance.assistantId,
      'version': instance.version,
      'graph_id': instance.graphId,
      'config': instance.config.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
      'name': ?instance.name,
    };

AssistantVersionList _$AssistantVersionListFromJson(
  Map<String, dynamic> json,
) => AssistantVersionList(
  versions: (json['versions'] as List<dynamic>)
      .map((e) => AssistantVersion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AssistantVersionListToJson(
  AssistantVersionList instance,
) => <String, dynamic>{
  'versions': instance.versions.map((e) => e.toJson()).toList(),
};

AssistantSchema _$AssistantSchemaFromJson(Map<String, dynamic> json) =>
    AssistantSchema(
      input: json['input'] as Map<String, dynamic>?,
      output: json['output'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AssistantSchemaToJson(AssistantSchema instance) =>
    <String, dynamic>{'input': ?instance.input, 'output': ?instance.output};

AssistantSubgraph _$AssistantSubgraphFromJson(Map<String, dynamic> json) =>
    AssistantSubgraph(
      namespace: json['namespace'] as String,
      graph: json['graph'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AssistantSubgraphToJson(AssistantSubgraph instance) =>
    <String, dynamic>{'namespace': instance.namespace, 'graph': instance.graph};
