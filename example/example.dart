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
          'content': '武汉天气怎么样',
          'role': 'user',
        },
      ]
    },
    streamMode: 'messages-tuple',
  );

  // Store pending tool calls to match with results
  final Map<String, ToolCall> pendingToolCalls = {};

  await for (final sseEvent
      in client.streamStatefulRun(thread.threadId, statefulRequest)) {
    // Debug: print raw event data
    final dataPreview = sseEvent.data != null && sseEvent.data!.length > 100
        ? '${sseEvent.data!.substring(0, 100)}...'
        : sseEvent.data;
    print('📨 Data: $dataPreview');

    // Parse the SSE event using the new stream event models
    final parsed = parseStreamEventData(sseEvent);
    if (parsed != null) {
      final message = parsed.message;
      print('   ✅ Parsed: type=${message.type}, isTool=${message.isToolMessage}, toolCallId=${message.toolCallId}');

      // Stage 1: AI declares tool calls
      if (message.isAiMessage && message.allToolCalls.isNotEmpty) {
        for (final toolCall in message.allToolCalls) {
          print('🔧 Tool Call:');
          print('   Name: ${toolCall.name}');
          print('   Args: ${toolCall.args}');
          print('   ID: ${toolCall.id}');
          // Store for matching with results later
          pendingToolCalls[toolCall.id] = toolCall;
        }
      }

      // Stage 2: Tool execution results
      if (message.isToolMessage) {
        print('🔍 Found tool message!');
        print('   toolCallId: ${message.toolCallId}');
        print('   status: ${message.status}');
        print('   content length: ${message.content.length}');

        final toolCallId = message.toolCallId;
        if (toolCallId != null && pendingToolCalls.containsKey(toolCallId)) {
          final originalCall = pendingToolCalls[toolCallId]!;
          print('✅ Tool Result:');
          print('   Name: ${originalCall.name}');
          print('   Status: ${message.status ?? "unknown"}');

          // Extract tool result from content
          final result = message.content
              .where((c) => c.text != null)
              .map((c) => c.text!)
              .join('');
          if (result.isNotEmpty) {
            print('   Result: $result');
          }

          // Remove completed call
          pendingToolCalls.remove(toolCallId);
        } else {
          print('⚠️ Tool result but no matching call found');
          print('   Pending calls: ${pendingToolCalls.keys}');
        }
      }

      // Print text content (non-tool messages)
      if (message.isAiMessage && message.allToolCalls.isEmpty) {
        final text = message.firstText;
        if (text != null) {
          // print(text);
        }
      }
    } else {
      // If parsing failed, print the raw event
      print('   ❌ Failed to parse');
    }
    print('');
  }
}
