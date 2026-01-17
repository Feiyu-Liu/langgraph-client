import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

/// Message content block from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class MessageContent {
  final int index;
  final String type;
  final String? text;

  MessageContent({
    required this.index,
    required this.type,
    this.text,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);
  Map<String, dynamic> toJson() => _$MessageContentToJson(this);
}

/// Response metadata from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseMetadata {
  @JsonKey(name: 'model_provider')
  final String modelProvider;

  ResponseMetadata({required this.modelProvider});

  factory ResponseMetadata.fromJson(Map<String, dynamic> json) =>
      _$ResponseMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseMetadataToJson(this);
}

/// SSE stream message object from LangGraph API
///
/// Represents the message object in SSE event data arrays from the
/// `/threads/{thread_id}/runs/stream` endpoint.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class StreamMessage {
  final List<MessageContent> content;
  @JsonKey(name: 'additional_kwargs')
  final Map<String, dynamic> additionalKwargs;
  @JsonKey(name: 'tool_call_chunks')
  final List<dynamic> toolCallChunks;
  @JsonKey(name: 'response_metadata')
  final ResponseMetadata? responseMetadata;
  final String id;
  @JsonKey(name: 'tool_calls')
  final List<dynamic> toolCalls;
  @JsonKey(name: 'invalid_tool_calls')
  final List<dynamic> invalidToolCalls;
  final String type;

  StreamMessage({
    required this.content,
    required this.additionalKwargs,
    required this.toolCallChunks,
    this.responseMetadata,
    required this.id,
    required this.toolCalls,
    required this.invalidToolCalls,
    required this.type,
  });

  factory StreamMessage.fromJson(Map<String, dynamic> json) =>
      _$StreamMessageFromJson(json);
  Map<String, dynamic> toJson() => _$StreamMessageToJson(this);

  /// Convenience method to get the first text content
  ///
  /// Iterates through content items and returns the first text value found.
  /// Returns null if no text content exists.
  String? get firstText {
    for (final item in content) {
      if (item.type == 'text' && item.text != null) {
        return item.text;
      }
    }
    return null;
  }
}
