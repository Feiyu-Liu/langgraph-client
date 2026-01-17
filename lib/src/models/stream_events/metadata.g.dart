// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamMetadata _$StreamMetadataFromJson(Map<String, dynamic> json) =>
    StreamMetadata(
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      runAttempt: (json['run_attempt'] as num).toInt(),
      langgraphVersion: json['langgraph_version'] as String,
      langgraphPlan: json['langgraph_plan'] as String,
      langgraphHost: json['langgraph_host'] as String,
      langgraphApiUrl: json['langgraph_api_url'] as String,
      userAgent: json['user-agent'] as String?,
      runId: json['run_id'] as String,
      threadId: json['thread_id'] as String,
      graphId: json['graph_id'] as String,
      assistantId: json['assistant_id'] as String,
      langgraphStep: (json['langgraph_step'] as num).toInt(),
      langgraphNode: json['langgraph_node'] as String,
      langgraphTriggers: (json['langgraph_triggers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      langgraphPath: (json['langgraph_path'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      langgraphCheckpointNs: json['langgraph_checkpoint_ns'] as String?,
      pregelTaskId: json['__pregel_task_id'] as String?,
      checkpointNs: json['checkpoint_ns'] as String?,
      lsProvider: json['ls_provider'] as String?,
      lsModelName: json['ls_model_name'] as String?,
      lsModelType: json['ls_model_type'] as String?,
      lsTemperature: (json['ls_temperature'] as num?)?.toInt(),
      lsMaxTokens: (json['ls_max_tokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StreamMetadataToJson(StreamMetadata instance) =>
    <String, dynamic>{
      'tags': instance.tags,
      'run_attempt': instance.runAttempt,
      'langgraph_version': instance.langgraphVersion,
      'langgraph_plan': instance.langgraphPlan,
      'langgraph_host': instance.langgraphHost,
      'langgraph_api_url': instance.langgraphApiUrl,
      'user-agent': ?instance.userAgent,
      'run_id': instance.runId,
      'thread_id': instance.threadId,
      'graph_id': instance.graphId,
      'assistant_id': instance.assistantId,
      'langgraph_step': instance.langgraphStep,
      'langgraph_node': instance.langgraphNode,
      'langgraph_triggers': ?instance.langgraphTriggers,
      'langgraph_path': ?instance.langgraphPath,
      'langgraph_checkpoint_ns': ?instance.langgraphCheckpointNs,
      '__pregel_task_id': ?instance.pregelTaskId,
      'checkpoint_ns': ?instance.checkpointNs,
      'ls_provider': ?instance.lsProvider,
      'ls_model_name': ?instance.lsModelName,
      'ls_model_type': ?instance.lsModelType,
      'ls_temperature': ?instance.lsTemperature,
      'ls_max_tokens': ?instance.lsMaxTokens,
    };
