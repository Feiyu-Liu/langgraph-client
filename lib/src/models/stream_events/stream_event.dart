import 'dart:convert';
import 'package:sse_stream/sse_stream.dart';
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
/// The SSE event data field contains a JSON array with two elements:
/// - Index 0: StreamMessage (the message object)
/// - Index 1: StreamMetadata (the metadata object)
///
/// Returns [ParsedStreamEvent] if parsing succeeds, null otherwise.
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
    // data field is a JSON array string
    final data = event.data!.trim();

    // Use jsonDecode to convert string to List
    final parsed = jsonDecode(data) as List;

    if (parsed.length < 2) {
      return null;
    }

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
    // Parse failed, return null
    return null;
  }
}
