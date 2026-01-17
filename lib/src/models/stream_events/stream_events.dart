/// LangGraph SSE stream event models
///
/// This library provides type-safe models for parsing LangGraph SSE stream events
/// from the `/threads/{thread_id}/runs/stream` endpoint.
///
/// The SSE events return JSON arrays containing:
/// - A [StreamMessage] object with message content
/// - A [StreamMetadata] object with execution context
///
/// Use [parseStreamEventData] to convert raw [SseEvent] objects into
/// [ParsedStreamEvent] instances.
library;

export 'message.dart';
export 'metadata.dart';
export 'stream_event.dart';
