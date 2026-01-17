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
    assistantId: '510cdb0d-5992-4100-a3de-8d9ca8bef7b9', // Replace with your assistant ID
    input: {
      'messages': [
        {
          'content': 'Write a Hello World program in Dart',
          'role': 'user',
        },
      ]
    },
    streamMode: 'messages-tuple',
  );

  await for (final sseEvent
      in client.streamStatefulRun(thread.threadId, statefulRequest)) {
    // Parse the SSE event using the new stream event models
    final parsed = parseStreamEventData(sseEvent);
    if (parsed != null) {
      // Print the text content from the message
      final text = parsed.message.firstText;
      if (text != null) {
        print(text);
      }
      // // Print metadata information
      // print('Run ID: ${parsed.metadata.runId}');
      // print('Node: ${parsed.metadata.langgraphNode}');
      // print('Step: ${parsed.metadata.langgraphStep}');
      // print('---');
    } else {
      // If parsing failed, print the raw event
      print('Raw event: $sseEvent');
    }
  }
}
