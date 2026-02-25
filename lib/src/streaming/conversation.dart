import '../models/stream_events/message.dart';
import '../models/stream_events/task.dart';
import 'events.dart';

Stream<ConversationStreamEvent> toConversationStreamEvents(
  Stream<LangGraphStreamEvent> events,
) async* {
  final pendingToolCalls = <String, ToolCall>{};

  String? activeRunId;
  String? activeThreadId;
  String? activeAssistantId;
  bool started = false;
  bool completed = false;

  await for (final event in events) {
    if (event is LangGraphMessageEvent) {
      activeRunId = event.runId;
      activeThreadId ??= event.metadata.threadId;
      activeAssistantId ??= event.metadata.assistantId;

      if (!started) {
        started = true;
        yield ConversationStartedEvent(
          runId: activeRunId,
          threadId: activeThreadId,
          assistantId: activeAssistantId,
        );
      }

      if (event.message.isAiMessage) {
        for (final toolCall in event.message.allToolCalls) {
          pendingToolCalls[toolCall.id] = toolCall;
          yield ConversationToolCallRequestedEvent(
            runId: activeRunId,
            toolCall: toolCall,
            origin: event.origin,
          );
        }
      }

      if (event.message.isToolMessage && event.message.toolCallId != null) {
        final toolCallId = event.message.toolCallId!;
        final originalToolCall = pendingToolCalls.remove(toolCallId);
        final result = event.message.content
            .map((item) => item.text ?? '')
            .join();
        yield ConversationToolCallCompletedEvent(
          runId: activeRunId,
          toolCallId: toolCallId,
          toolName: originalToolCall?.name,
          status: event.message.status,
          result: result.isEmpty ? null : result,
          origin: event.origin,
        );
      }

      final text = event.textDelta;
      if (text != null && text.isNotEmpty) {
        yield ConversationTextDeltaEvent(
          runId: activeRunId,
          text: text,
          eventName: event.eventName,
          origin: event.origin,
        );
      }
      continue;
    }

    if (event is LangGraphTaskStreamEvent) {
      for (final interrupt in event.task.interrupts) {
        yield ConversationInterruptEvent(
          runId: activeRunId,
          interrupt: interrupt,
        );
      }
      continue;
    }

    if (event is LangGraphMetadataEvent) {
      activeRunId ??= event.runId;
      activeThreadId ??= event.threadId;
      activeAssistantId ??= event.assistantId;

      if (!started &&
          activeRunId != null &&
          activeThreadId != null &&
          activeAssistantId != null) {
        started = true;
        yield ConversationStartedEvent(
          runId: activeRunId,
          threadId: activeThreadId,
          assistantId: activeAssistantId,
        );
      }

      yield ConversationMetadataStreamEvent(
        runId: activeRunId,
        metadata: event.metadata,
      );
      continue;
    }

    if (event is LangGraphEndEvent) {
      completed = true;
      yield ConversationCompletedEvent(
        runId: activeRunId ?? event.runId,
        reason: event.reason,
      );
      break;
    }

    if (event is LangGraphUnknownEvent) {
      yield ConversationUnknownEvent(runId: activeRunId, unknown: event);
    }
  }

  if (!completed) {
    yield ConversationCompletedEvent(
      runId: activeRunId,
      reason: 'stream_exhausted',
    );
  }
}

Stream<LangGraphTextChunk> toTextChunks(
  Stream<LangGraphStreamEvent> events,
) async* {
  await for (final event in events) {
    if (event is! LangGraphMessageEvent) {
      continue;
    }
    final text = event.textDelta;
    if (text == null || text.isEmpty) {
      continue;
    }
    yield LangGraphTextChunk(
      text: text,
      eventName: event.eventName,
      runId: event.runId,
      origin: event.origin,
    );
  }
}

Stream<TaskInterrupt> toInterrupts(Stream<LangGraphStreamEvent> events) async* {
  await for (final event in events) {
    if (event is! LangGraphTaskStreamEvent || !event.task.hasInterrupts) {
      continue;
    }
    for (final interrupt in event.task.interrupts) {
      yield interrupt;
    }
  }
}
