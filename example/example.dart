import 'package:langgraph_client/langgraph_client.dart';

void main() {
  streamStatefulRun();
}

// https://langchain-ai.github.io/langgraph/cloud/reference/api/api_ref.html#tag/thread-runs/POST/threads/{thread_id}/runs/stream
void streamStatefulRun() async {
  var client = LangGraphClient(
    baseUrl: 'http://localhost:2024', // Replace with your LangGraph API URL
  );

  Thread thread = await client.createThread();

  var statefulRequest = RunCreateStateful(
    assistantId: '72a076d3-4298-402e-a7c6-2006d36c9b93', // Replace with your assistant ID
    input: {
      'messages': [
        {
          'content': '向我问一些问题',
          'role': 'user',
        },
      ]
    },
    streamMode: ['messages-tuple', 'tasks']
  );

  // Store pending tool calls to match with results
  final Map<String, ToolCall> pendingToolCalls = {};

  await for (final sseEvent
      in client.streamStatefulRun(thread.threadId, statefulRequest)) {
    // Try parsing as a message event first
    final messageParsed = parseStreamEventData(sseEvent);
    if (messageParsed != null) {
      final message = messageParsed.message;

      // Stage 1: AI declares tool calls - print tool names
      if (message.isAiMessage && message.allToolCalls.isNotEmpty) {
        for (final toolCall in message.allToolCalls) {
          print('🔧 Tool Call: ${toolCall.name}');
          // Store for matching with results later
          pendingToolCalls[toolCall.id] = toolCall;
        }
      }

      // Stage 2: Tool execution results - print tool results
      if (message.isToolMessage) {
        final toolCallId = message.toolCallId;
        if (toolCallId != null && pendingToolCalls.containsKey(toolCallId)) {
          final originalCall = pendingToolCalls[toolCallId]!;
          // Extract tool result from content
          final result = message.content
              .where((c) => c.text != null)
              .map((c) => c.text!)
              .join('');
          print('✅ Tool Result: ${originalCall.name}');
          if (result.isNotEmpty) {
            print('   Result: $result');
          }

          // Remove completed call
          pendingToolCalls.remove(toolCallId);
        }
      }

      continue;
    }

    // If not a message event, try parsing as a task event
    final taskParsed = parseTaskEventData(sseEvent);
    if (taskParsed != null) {
      final task = taskParsed.task;

      // Only print task interrupt information
      if (task.hasInterrupts) {
        print('⚠️ Task Interrupts (${task.interrupts.length}):');
        for (final interrupt in task.interrupts) {
          print('   ID: ${interrupt.id}');
          print('   Value: ${interrupt.value}');
        }
      }

      continue;
    }
  }
}
