# LangGraph Client

`langgraph_client` is a Dart client for the LangGraph API with high-level streaming abstractions for Flutter/Dart apps.

## Features

The package provides:
- Assistant/Thread/Run/Store/Cron APIs
- Typed streaming events (`LangGraphStreamEvent`)
- High-level conversation streaming (`ConversationStreamEvent`)
- Built-in parsing for text deltas, tool calls, interrupts, and completion

## Getting started

Add the following to your **pubspec.yaml**:

```
dependencies:
  langgraph_client: ^1.0.0
```

## Usage

Create client and request:

```dart
final client = LangGraphClient(
  baseUrl: 'http://localhost:2024',
);

final thread = await client.createThread();

final request = RunCreateStateful(
  assistantId: 'my-langgraph-agent',
  input: {
    'messages': [
      {'content': 'Hello!', 'role': 'user'},
    ]
  },
  streamMode: ['messages-tuple', 'tasks'],
  streamSubgraphs: true,
);
```

Recommended high-level conversation stream:

```dart
await for (final event in client.runStatefulConversationStream(
  thread.threadId,
  request,
)) {
  if (event is ConversationTextDeltaEvent) {
    print(event.text);
  } else if (event is ConversationInterruptEvent) {
    print(event.interrupt.value);
  } else if (event is ConversationCompletedEvent) {
    break;
  }
}
```

## Additional information

For details, refer to:
- [LangGraph API Specification](https://langchain-ai.github.io/langgraph/cloud/reference/api/api_ref.html)
- [Stream Modes](https://langchain-ai.github.io/langgraph/concepts/streaming/)
