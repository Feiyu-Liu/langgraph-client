import 'package:json_annotation/json_annotation.dart';

import '../../api/client.dart';

part 'metadata.g.dart';

/// SSE stream metadata object from LangGraph API
///
/// Represents the metadata object in SSE event data arrays from the
/// `/threads/{thread_id}/runs/stream` endpoint.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class StreamMetadata {
  final List<String> tags;
  final String? name; // Node name (e.g., "model_request", "tools")
  @JsonKey(name: 'run_attempt')
  final int runAttempt;
  @JsonKey(name: 'langgraph_version')
  final String langgraphVersion;
  @JsonKey(name: 'langgraph_plan')
  final String langgraphPlan;
  @JsonKey(name: 'langgraph_host')
  final String langgraphHost;
  @JsonKey(name: 'langgraph_api_url')
  final String langgraphApiUrl;
  @JsonKey(name: 'user-agent')
  final String? userAgent;
  @JsonKey(name: 'run_id')
  final String runId;
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'graph_id')
  final String graphId;
  @JsonKey(name: 'assistant_id')
  final String assistantId;
  @JsonKey(name: 'langgraph_step')
  final int langgraphStep;
  @JsonKey(name: 'langgraph_node')
  final String langgraphNode;
  @JsonKey(name: 'langgraph_triggers')
  final List<String>? langgraphTriggers;
  @JsonKey(name: 'langgraph_path')
  final List<dynamic>? langgraphPath;
  @JsonKey(name: 'langgraph_checkpoint_ns')
  final String? langgraphCheckpointNs;
  @JsonKey(name: '__pregel_task_id')
  final String? pregelTaskId;
  @JsonKey(name: 'checkpoint_ns')
  final String? checkpointNs;
  @JsonKey(name: 'ls_provider')
  final String? lsProvider;
  @JsonKey(name: 'ls_model_name')
  final String? lsModelName;
  @JsonKey(name: 'ls_model_type')
  final String? lsModelType;
  @JsonKey(name: 'ls_temperature')
  final int? lsTemperature;
  @JsonKey(name: 'ls_max_tokens')
  final int? lsMaxTokens;

  StreamMetadata({
    required this.tags,
    this.name,
    required this.runAttempt,
    required this.langgraphVersion,
    required this.langgraphPlan,
    required this.langgraphHost,
    required this.langgraphApiUrl,
    this.userAgent,
    required this.runId,
    required this.threadId,
    required this.graphId,
    required this.assistantId,
    required this.langgraphStep,
    required this.langgraphNode,
    this.langgraphTriggers,
    this.langgraphPath,
    this.langgraphCheckpointNs,
    this.pregelTaskId,
    this.checkpointNs,
    this.lsProvider,
    this.lsModelName,
    this.lsModelType,
    this.lsTemperature,
    this.lsMaxTokens,
  });

  factory StreamMetadata.fromJson(Map<String, dynamic> json) {
    try {
      return _$StreamMetadataFromJson(json);
    } catch (e) {
      throw LangGraphApiException(
        'Failed to parse StreamMetadata: $e\n'
        'JSON keys: ${json.keys.toList()}',
      );
    }
  }
  Map<String, dynamic> toJson() => _$StreamMetadataToJson(this);
}
