// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageContent _$MessageContentFromJson(Map<String, dynamic> json) =>
    MessageContent(
      index: (json['index'] as num).toInt(),
      type: json['type'] as String,
      text: json['text'] as String?,
      id: json['id'] as String?,
      name: json['name'] as String?,
      input: json['input'] as String?,
    );

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{
      'index': instance.index,
      'type': instance.type,
      'text': ?instance.text,
      'id': ?instance.id,
      'name': ?instance.name,
      'input': ?instance.input,
    };

ToolCall _$ToolCallFromJson(Map<String, dynamic> json) => ToolCall(
  name: json['name'] as String,
  args: json['args'] as Map<String, dynamic>,
  id: json['id'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
  'name': instance.name,
  'args': instance.args,
  'id': instance.id,
  'type': instance.type,
};

ToolCallChunk _$ToolCallChunkFromJson(Map<String, dynamic> json) =>
    ToolCallChunk(
      id: json['id'] as String?,
      index: (json['index'] as num).toInt(),
      name: json['name'] as String?,
      args: json['args'] as String?,
    );

Map<String, dynamic> _$ToolCallChunkToJson(ToolCallChunk instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'index': instance.index,
      'name': ?instance.name,
      'args': ?instance.args,
    };

InvalidToolCall _$InvalidToolCallFromJson(Map<String, dynamic> json) =>
    InvalidToolCall(
      name: json['name'] as String,
      args: json['args'] as String,
      error: json['error'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$InvalidToolCallToJson(InvalidToolCall instance) =>
    <String, dynamic>{
      'name': instance.name,
      'args': instance.args,
      'error': ?instance.error,
      'type': instance.type,
    };

UsageMetadata _$UsageMetadataFromJson(Map<String, dynamic> json) =>
    UsageMetadata(
      inputTokens: (json['input_tokens'] as num?)?.toInt(),
      outputTokens: (json['output_tokens'] as num?)?.toInt(),
      totalTokens: (json['total_tokens'] as num?)?.toInt(),
      inputTokenDetails: json['input_token_details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UsageMetadataToJson(UsageMetadata instance) =>
    <String, dynamic>{
      'input_tokens': ?instance.inputTokens,
      'output_tokens': ?instance.outputTokens,
      'total_tokens': ?instance.totalTokens,
      'input_token_details': ?instance.inputTokenDetails,
    };

ResponseMetadata _$ResponseMetadataFromJson(Map<String, dynamic> json) =>
    ResponseMetadata(
      modelProvider: json['model_provider'] as String?,
      usage: json['usage'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResponseMetadataToJson(ResponseMetadata instance) =>
    <String, dynamic>{
      'model_provider': ?instance.modelProvider,
      'usage': ?instance.usage,
    };

StreamMessage _$StreamMessageFromJson(Map<String, dynamic> json) =>
    StreamMessage(
      additionalKwargs: json['additional_kwargs'] as Map<String, dynamic>,
      toolCallChunks: (json['tool_call_chunks'] as List<dynamic>?)
          ?.map((e) => ToolCallChunk.fromJson(e as Map<String, dynamic>))
          .toList(),
      usageMetadata: json['usage_metadata'] == null
          ? null
          : UsageMetadata.fromJson(
              json['usage_metadata'] as Map<String, dynamic>,
            ),
      responseMetadata: json['response_metadata'] == null
          ? null
          : ResponseMetadata.fromJson(
              json['response_metadata'] as Map<String, dynamic>,
            ),
      id: json['id'] as String,
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      invalidToolCalls: (json['invalid_tool_calls'] as List<dynamic>?)
          ?.map((e) => InvalidToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
      artifact: json['artifact'] as List<dynamic>?,
      toolCallId: json['tool_call_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$StreamMessageToJson(
  StreamMessage instance,
) => <String, dynamic>{
  'additional_kwargs': instance.additionalKwargs,
  'tool_call_chunks': ?instance.toolCallChunks?.map((e) => e.toJson()).toList(),
  'usage_metadata': ?instance.usageMetadata?.toJson(),
  'response_metadata': ?instance.responseMetadata?.toJson(),
  'id': instance.id,
  'tool_calls': ?instance.toolCalls?.map((e) => e.toJson()).toList(),
  'invalid_tool_calls': ?instance.invalidToolCalls
      ?.map((e) => e.toJson())
      .toList(),
  'status': ?instance.status,
  'artifact': ?instance.artifact,
  'tool_call_id': ?instance.toolCallId,
  'metadata': ?instance.metadata,
  'type': instance.type,
};
