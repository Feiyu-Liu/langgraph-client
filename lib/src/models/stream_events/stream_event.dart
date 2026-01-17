import 'dart:convert';
import 'package:sse_stream/sse_stream.dart';

import '../../api/client.dart';
import 'message.dart';
import 'metadata.dart';

/// Parsed SSE stream event containing message and metadata
///
/// Represents a successfully parsed LangGraph SSE event with both
/// the [StreamMessage] (content) and [StreamMetadata] (context).
class ParsedStreamEvent {
  final StreamMessage message;
  final StreamMetadata metadata;

  ParsedStreamEvent({
    required this.message,
    required this.metadata,
  });
}

/// Parses a LangGraph SSE event into typed models
///
/// The SSE event data field can contain two formats:
///
/// 1. **Message event** (JSON array with two elements):
///   - Index 0: StreamMessage (the message object)
///   - Index 1: StreamMetadata (the metadata object)
///
/// 2. **Metadata event** (JSON object):
///   - Contains run metadata like `run_id`, `attempt`, etc.
///   - These events are ignored by this parser
///
/// Returns [ParsedStreamEvent] for message events, null otherwise.
///
/// Example:
/// ```dart
/// await for (final event in streamStatefulRun(threadId, request)) {
///   final parsed = parseStreamEventData(event);
///   if (parsed != null) {
///     print('Text: ${parsed.message.firstText}');
///     print('Run ID: ${parsed.metadata.runId}');
///   }
/// }
/// ```
ParsedStreamEvent? parseStreamEventData(SseEvent event) {
  if (event.data == null || event.data!.isEmpty) {
    return null;
  }

  try {
    // Decode JSON data
    final data = event.data!.trim();
    final decoded = jsonDecode(data);

    // Check if decoded data is a List (message event) or Map (metadata event)
    if (decoded is! List || decoded.length < 2) {
      // Metadata events (objects) or invalid arrays are not parsed here
      return null;
    }

    final parsed = decoded;

    // First element is StreamMessage
    final message = StreamMessage.fromJson(parsed[0] as Map<String, dynamic>);

    // Second element is StreamMetadata
    final metadata =
        StreamMetadata.fromJson(parsed[1] as Map<String, dynamic>);

    return ParsedStreamEvent(
      message: message,
      metadata: metadata,
    );
  } catch (e) {
    // Parse failed - return null for non-fatal parsing errors
    // The error is re-thrown as LangGraphApiException for proper error handling
    if (e is LangGraphApiException) {
      return null;
    }
    throw LangGraphApiException('Failed to parse SSE event: $e');
  }
}
