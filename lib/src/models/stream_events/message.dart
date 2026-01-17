import 'package:json_annotation/json_annotation.dart';

import '../../api/client.dart';

part 'message.g.dart';

/// Message content block from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class MessageContent {
  final int index;
  final String type;
  final String? text;
  // New fields for tool_use and input_json_delta types
  final String? id;    // for tool_use type
  final String? name;  // for tool_use type
  final String? input; // for tool_use/input_json_delta type

  MessageContent({
    required this.index,
    required this.type,
    this.text,
    this.id,
    this.name,
    this.input,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);
  Map<String, dynamic> toJson() => _$MessageContentToJson(this);

  /// Convenience method: check if this is text content
  bool get isText => type == 'text';

  /// Convenience method: check if this is tool use content
  bool get isToolUse => type == 'tool_use';

  /// Convenience method: check if this is input JSON delta
  bool get isInputJsonDelta => type == 'input_json_delta';

  /// Get tool use content (only valid when type='tool_use')
  ToolUseContent? get asToolUse {
    if (!isToolUse) return null;
    return ToolUseContent(
      index: index,
      id: id!,
      name: name!,
      input: input ?? '',
    );
  }
}

/// Tool use content helper class
class ToolUseContent {
  final int index;
  final String id;
  final String name;
  final String input;

  ToolUseContent({
    required this.index,
    required this.id,
    required this.name,
    required this.input,
  });
}

/// Tool call object from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ToolCall {
  final String name;
  final Map<String, dynamic> args;
  final String id;
  final String type;

  ToolCall({
    required this.name,
    required this.args,
    required this.id,
    required this.type,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) =>
      _$ToolCallFromJson(json);
  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

/// Streaming tool call chunk from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ToolCallChunk {
  final String? id;
  final int index;
  final String? name;
  final String? args;

  ToolCallChunk({
    this.id,
    required this.index,
    this.name,
    this.args,
  });

  factory ToolCallChunk.fromJson(Map<String, dynamic> json) =>
      _$ToolCallChunkFromJson(json);
  Map<String, dynamic> toJson() => _$ToolCallChunkToJson(this);
}

/// Invalid tool call object from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class InvalidToolCall {
  final String name;
  final String args;
  final String? error;
  final String type;

  InvalidToolCall({
    required this.name,
    required this.args,
    this.error,
    required this.type,
  });

  factory InvalidToolCall.fromJson(Map<String, dynamic> json) =>
      _$InvalidToolCallFromJson(json);
  Map<String, dynamic> toJson() => _$InvalidToolCallToJson(this);
}

/// Usage metadata from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UsageMetadata {
  @JsonKey(name: 'input_tokens')
  final int? inputTokens;
  @JsonKey(name: 'output_tokens')
  final int? outputTokens;
  @JsonKey(name: 'total_tokens')
  final int? totalTokens;
  @JsonKey(name: 'input_token_details')
  final Map<String, dynamic>? inputTokenDetails;

  UsageMetadata({
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
    this.inputTokenDetails,
  });

  factory UsageMetadata.fromJson(Map<String, dynamic> json) =>
      _$UsageMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$UsageMetadataToJson(this);
}

/// Response metadata from LangGraph SSE stream events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResponseMetadata {
  @JsonKey(name: 'model_provider')
  final String? modelProvider;
  final Map<String, dynamic>? usage;

  ResponseMetadata({
    this.modelProvider,
    this.usage,
  });

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
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<MessageContent> content;
  @JsonKey(name: 'additional_kwargs')
  final Map<String, dynamic> additionalKwargs;
  @JsonKey(name: 'tool_call_chunks')
  final List<ToolCallChunk>? toolCallChunks;
  @JsonKey(name: 'usage_metadata')
  final UsageMetadata? usageMetadata;
  @JsonKey(name: 'response_metadata')
  final ResponseMetadata? responseMetadata;
  final String id;
  @JsonKey(name: 'tool_calls')
  final List<ToolCall>? toolCalls;
  @JsonKey(name: 'invalid_tool_calls')
  final List<InvalidToolCall>? invalidToolCalls;
  // New fields for tool type messages
  final String? status; // for tool type
  final List<dynamic>? artifact; // for tool type
  @JsonKey(name: 'tool_call_id')
  final String? toolCallId; // for tool type
  final Map<String, dynamic>? metadata; // for tool type
  final String type;

  StreamMessage({
    List<MessageContent>? content,
    required this.additionalKwargs,
    this.toolCallChunks,
    this.usageMetadata,
    this.responseMetadata,
    required this.id,
    this.toolCalls,
    this.invalidToolCalls,
    this.status,
    this.artifact,
    this.toolCallId,
    this.metadata,
    required this.type,
  }) : content = content ?? const [];

  /// Custom fromJson to handle both array and string content
  ///
  /// Tool messages have content as a plain string (JSON), while AI messages
  /// have content as an array of MessageContent objects.
  factory StreamMessage.fromJson(Map<String, dynamic> json) {
    // Handle content field - can be either a String or a List
    List<MessageContent> parsedContent = [];
    if (json.containsKey('content')) {
      final contentValue = json['content'];
      if (contentValue is String) {
        // Tool message: content is a plain JSON string
        parsedContent = [
          MessageContent(
            index: 0,
            type: 'text',
            text: contentValue,
          ),
        ];
      } else if (contentValue is List) {
        // AI message: content is an array of MessageContent objects
        parsedContent = contentValue
            .map((e) => MessageContent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    try {
      // Parse the rest using generated code
      final generated = _$StreamMessageFromJson(json);
      return generated.copyWith(content: parsedContent);
    } catch (e) {
      throw LangGraphApiException(
        'Failed to parse StreamMessage: $e\n'
        'Message type: ${json['type']}\n'
        'JSON keys: ${json.keys.toList()}',
      );
    }
  }

  /// Custom toJson to serialize content correctly
  Map<String, dynamic> toJson() {
    final json = _$StreamMessageToJson(this);
    // For tool messages with single text content, unwrap the content array
    if (type == 'tool' &&
        content.length == 1 &&
        content[0].type == 'text' &&
        content[0].text != null) {
      json['content'] = content[0].text;
    } else {
      json['content'] = content.map((e) => e.toJson()).toList();
    }
    return json;
  }

  /// Convenience method to get the first text content
  ///
  /// Only returns text from AI messages. Tool messages return null even if
  /// they have content (which contains JSON-formatted tool results).
  ///
  /// Returns null if this is not an AI message or no text content exists.
  String? get firstText {
    // Only return text for AI messages, not tool messages
    if (type != 'ai') {
      return null;
    }
    for (final item in content) {
      if (item.type == 'text' && item.text != null) {
        return item.text;
      }
    }
    return null;
  }

  /// Convenience method: check if this is an AI message
  bool get isAiMessage => type == 'ai';

  /// Convenience method: check if this is a tool message
  bool get isToolMessage => type == 'tool';

  /// Convenience method: check if this is a remove message
  bool get isRemoveMessage => type == 'remove';

  /// Convenience method: get all tool calls
  List<ToolCall> get allToolCalls => toolCalls ?? [];

  /// Convenience method: get all tool call chunks
  List<ToolCallChunk> get allToolCallChunks => toolCallChunks ?? [];

  /// Creates a copy of this message with the given fields replaced
  StreamMessage copyWith({
    List<MessageContent>? content,
    Map<String, dynamic>? additionalKwargs,
    List<ToolCallChunk>? toolCallChunks,
    UsageMetadata? usageMetadata,
    ResponseMetadata? responseMetadata,
    String? id,
    List<ToolCall>? toolCalls,
    List<InvalidToolCall>? invalidToolCalls,
    String? status,
    List<dynamic>? artifact,
    String? toolCallId,
    Map<String, dynamic>? metadata,
    String? type,
  }) {
    return StreamMessage(
      content: content ?? this.content,
      additionalKwargs: additionalKwargs ?? this.additionalKwargs,
      toolCallChunks: toolCallChunks ?? this.toolCallChunks,
      usageMetadata: usageMetadata ?? this.usageMetadata,
      responseMetadata: responseMetadata ?? this.responseMetadata,
      id: id ?? this.id,
      toolCalls: toolCalls ?? this.toolCalls,
      invalidToolCalls: invalidToolCalls ?? this.invalidToolCalls,
      status: status ?? this.status,
      artifact: artifact ?? this.artifact,
      toolCallId: toolCallId ?? this.toolCallId,
      metadata: metadata ?? this.metadata,
      type: type ?? this.type,
    );
  }
}
