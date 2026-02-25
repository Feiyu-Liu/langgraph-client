import 'package:langgraph_client/langgraph_client.dart';

void main() {
  streamConversation();
}

// https://langchain-ai.github.io/langgraph/cloud/reference/api/api_ref.html#tag/thread-runs/POST/threads/{thread_id}/runs/stream
void streamConversation() async {
  var client = LangGraphClient(
    baseUrl: 'http://localhost:2024', // Replace with your LangGraph API URL
  );

  Thread thread = await client.createThread();

  var statefulRequest = RunCreateStateful(
    assistantId:
        '72a076d3-4298-402e-a7c6-2006d36c9b93', // Replace with your assistant ID
    input: {
      'messages': [
        {'content': '向我问一些问题', 'role': 'user'},
      ],
    },
    streamMode: ['messages-tuple', 'tasks'],
  );

  await for (final event in client.runStatefulConversationStream(
    thread.threadId,
    statefulRequest,
  )) {
    if (event is ConversationStartedEvent) {
      print('🚀 Run started: ${event.runId}');
      continue;
    }
    if (event is ConversationTextDeltaEvent) {
      print(event.text);
      continue;
    }
    if (event is ConversationToolCallRequestedEvent) {
      print('🔧 Tool Call: ${event.toolCall.name}');
      continue;
    }
    if (event is ConversationToolCallCompletedEvent) {
      print('✅ Tool Result: ${event.toolName ?? event.toolCallId}');
      if (event.result != null) {
        print('   Result: ${event.result}');
      }
      continue;
    }
    if (event is ConversationInterruptEvent) {
      print('⚠️ Interrupt: ${event.interrupt.id} -> ${event.interrupt.value}');
      continue;
    }
    if (event is ConversationCompletedEvent) {
      print('🏁 Completed: ${event.reason}');
    }
  }
}
