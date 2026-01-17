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
    );

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{
      'index': instance.index,
      'type': instance.type,
      'text': ?instance.text,
    };

ResponseMetadata _$ResponseMetadataFromJson(Map<String, dynamic> json) =>
    ResponseMetadata(modelProvider: json['model_provider'] as String);

Map<String, dynamic> _$ResponseMetadataToJson(ResponseMetadata instance) =>
    <String, dynamic>{'model_provider': instance.modelProvider};

StreamMessage _$StreamMessageFromJson(Map<String, dynamic> json) =>
    StreamMessage(
      content: (json['content'] as List<dynamic>)
          .map((e) => MessageContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      additionalKwargs: json['additional_kwargs'] as Map<String, dynamic>,
      toolCallChunks: json['tool_call_chunks'] as List<dynamic>,
      responseMetadata: json['response_metadata'] == null
          ? null
          : ResponseMetadata.fromJson(
              json['response_metadata'] as Map<String, dynamic>,
            ),
      id: json['id'] as String,
      toolCalls: json['tool_calls'] as List<dynamic>,
      invalidToolCalls: json['invalid_tool_calls'] as List<dynamic>,
      type: json['type'] as String,
    );

Map<String, dynamic> _$StreamMessageToJson(StreamMessage instance) =>
    <String, dynamic>{
      'content': instance.content.map((e) => e.toJson()).toList(),
      'additional_kwargs': instance.additionalKwargs,
      'tool_call_chunks': instance.toolCallChunks,
      'response_metadata': ?instance.responseMetadata?.toJson(),
      'id': instance.id,
      'tool_calls': instance.toolCalls,
      'invalid_tool_calls': instance.invalidToolCalls,
      'type': instance.type,
    };
