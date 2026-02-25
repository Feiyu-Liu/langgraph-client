/// A Dart client for the LangGraph API that enables Flutter and Dart applications
/// to interact with LangGraph services.
///
/// This library provides a comprehensive set of tools for working with LangGraph's
/// features including:
/// - Thread management with state persistence
/// - Assistant creation and configuration
/// - Run execution (both stateful and stateless)
/// - Streaming responses via server-sent events
/// - Cron job scheduling for automated graph execution
///
/// Example usage:
/// ```dart
/// // Create a client instance
/// final client = LangGraphClient(
///   baseUrl: 'https://your-langgraph-server.com/api',
///   apiKey: 'your-api-key',
/// );
///
/// // Create a thread
/// final thread = await client.createThread();
///
/// // Execute a run on the thread
/// final run = await client.createStatefulRun(
///   threadId: thread.threadId,
///   assistantId: 'your-assistant-id',
/// );
/// ```
library;

export 'src/api/api.dart';
export 'src/models/models.dart';
export 'src/streaming/streaming.dart';
