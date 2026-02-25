import '../models/stream_events/message.dart';
import '../models/stream_events/metadata.dart';
import '../models/stream_events/task.dart';

/// Identifies where a streamed token was generated in a LangGraph hierarchy.
class LangGraphStreamOrigin {
  final bool isSubagent;
  final int subagentDepth;
  final String? subagentNamespace;
  final String? subagentName;

  const LangGraphStreamOrigin({
    required this.isSubagent,
    required this.subagentDepth,
    this.subagentNamespace,
    this.subagentName,
  });

  bool get isMainAgent => !isSubagent;

  static const main = LangGraphStreamOrigin(
    isSubagent: false,
    subagentDepth: 0,
  );
}

/// Structured stream event emitted by LangGraph stream endpoints.
sealed class LangGraphStreamEvent {
  final String eventName;

  const LangGraphStreamEvent({required this.eventName});
}

class LangGraphMessageEvent extends LangGraphStreamEvent {
  final StreamMessage message;
  final StreamMetadata metadata;
  final String runId;
  final String? textDelta;
  final LangGraphStreamOrigin origin;

  const LangGraphMessageEvent({
    required super.eventName,
    required this.message,
    required this.metadata,
    required this.runId,
    required this.textDelta,
    required this.origin,
  });
}

class LangGraphTaskStreamEvent extends LangGraphStreamEvent {
  final TaskEvent task;

  const LangGraphTaskStreamEvent({
    required super.eventName,
    required this.task,
  });
}

class LangGraphMetadataEvent extends LangGraphStreamEvent {
  final Map<String, dynamic> metadata;
  final String? runId;
  final String? threadId;
  final String? assistantId;

  LangGraphMetadataEvent({
    required super.eventName,
    required Map<String, dynamic> metadata,
    this.runId,
    this.threadId,
    this.assistantId,
  }) : metadata = Map<String, dynamic>.unmodifiable(metadata);
}

class LangGraphEndEvent extends LangGraphStreamEvent {
  final String reason;
  final String? runId;

  const LangGraphEndEvent({
    required super.eventName,
    required this.reason,
    this.runId,
  });
}

class LangGraphUnknownEvent extends LangGraphStreamEvent {
  final String? rawData;
  final Object? parseError;

  const LangGraphUnknownEvent({
    required super.eventName,
    required this.rawData,
    this.parseError,
  });
}

sealed class ConversationStreamEvent {
  final String? runId;

  const ConversationStreamEvent({this.runId});
}

class ConversationStartedEvent extends ConversationStreamEvent {
  final String threadId;
  final String assistantId;

  const ConversationStartedEvent({
    required super.runId,
    required this.threadId,
    required this.assistantId,
  });
}

class ConversationTextDeltaEvent extends ConversationStreamEvent {
  final String text;
  final String eventName;
  final LangGraphStreamOrigin origin;

  const ConversationTextDeltaEvent({
    required super.runId,
    required this.text,
    required this.eventName,
    required this.origin,
  });
}

class ConversationToolCallRequestedEvent extends ConversationStreamEvent {
  final ToolCall toolCall;
  final LangGraphStreamOrigin origin;

  const ConversationToolCallRequestedEvent({
    required super.runId,
    required this.toolCall,
    required this.origin,
  });
}

class ConversationToolCallCompletedEvent extends ConversationStreamEvent {
  final String toolCallId;
  final String? toolName;
  final String? status;
  final String? result;
  final LangGraphStreamOrigin origin;

  const ConversationToolCallCompletedEvent({
    required super.runId,
    required this.toolCallId,
    required this.toolName,
    required this.status,
    required this.result,
    required this.origin,
  });
}

class ConversationInterruptEvent extends ConversationStreamEvent {
  final TaskInterrupt interrupt;

  const ConversationInterruptEvent({
    required super.runId,
    required this.interrupt,
  });
}

class ConversationMetadataStreamEvent extends ConversationStreamEvent {
  final Map<String, dynamic> metadata;

  ConversationMetadataStreamEvent({
    required super.runId,
    required Map<String, dynamic> metadata,
  }) : metadata = Map<String, dynamic>.unmodifiable(metadata);
}

class ConversationCompletedEvent extends ConversationStreamEvent {
  final String reason;

  const ConversationCompletedEvent({
    required super.runId,
    required this.reason,
  });
}

class ConversationUnknownEvent extends ConversationStreamEvent {
  final LangGraphUnknownEvent unknown;

  const ConversationUnknownEvent({required super.runId, required this.unknown});
}

/// Flattened text chunk for UI rendering.
class LangGraphTextChunk {
  final String text;
  final String eventName;
  final String runId;
  final LangGraphStreamOrigin origin;

  const LangGraphTextChunk({
    required this.text,
    required this.eventName,
    required this.runId,
    required this.origin,
  });
}
