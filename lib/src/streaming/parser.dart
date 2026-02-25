import 'dart:convert';

import 'package:sse_stream/sse_stream.dart';

import '../models/stream_events/metadata.dart';
import '../models/stream_events/stream_event.dart';
import 'events.dart';

Stream<LangGraphStreamEvent> parseLangGraphEventStream(
  Stream<SseEvent> rawEvents,
) async* {
  await for (final event in rawEvents) {
    yield parseLangGraphEvent(event);
  }
}

LangGraphStreamEvent parseLangGraphEvent(SseEvent event) {
  final eventName = event.name ?? '';
  final rawData = event.data;
  Object? parseError;

  if (_isEndEvent(event)) {
    return LangGraphEndEvent(
      eventName: eventName,
      reason: _resolveEndReason(event),
      runId: _extractRunIdFromPayload(rawData),
    );
  }

  try {
    final parsedMessage = parseStreamEventData(event);
    if (parsedMessage != null) {
      final origin = classifyStreamOrigin(
        eventName: eventName,
        metadata: parsedMessage.metadata,
      );
      return LangGraphMessageEvent(
        eventName: eventName,
        message: parsedMessage.message,
        metadata: parsedMessage.metadata,
        runId: parsedMessage.metadata.runId,
        textDelta: parsedMessage.message.firstText,
        origin: origin,
      );
    }
  } catch (e) {
    parseError = e;
  }

  final parsedTask = parseTaskEventData(event);
  if (parsedTask != null) {
    return LangGraphTaskStreamEvent(
      eventName: eventName,
      task: parsedTask.task,
    );
  }

  final decoded = _tryDecode(rawData);
  if (decoded is Map<String, dynamic> && !_looksLikeTaskPayload(decoded)) {
    return LangGraphMetadataEvent(
      eventName: eventName,
      metadata: decoded,
      runId: _readString(decoded, 'run_id'),
      threadId: _readString(decoded, 'thread_id'),
      assistantId: _readString(decoded, 'assistant_id'),
    );
  }

  return LangGraphUnknownEvent(
    eventName: eventName,
    rawData: rawData,
    parseError: parseError,
  );
}

LangGraphStreamOrigin classifyStreamOrigin({
  required String eventName,
  required StreamMetadata metadata,
}) {
  final eventDepth = _countSubagentDepth(eventName);
  if (eventDepth > 0) {
    return LangGraphStreamOrigin(
      isSubagent: true,
      subagentDepth: eventDepth,
      subagentNamespace: _extractSubagentNamespaceFromEvent(eventName),
      subagentName: _extractSubagentName(metadata),
    );
  }

  final checkpoint =
      metadata.langgraphCheckpointNs ?? metadata.checkpointNs ?? '';
  final checkpointDepth = _countSubagentDepth(checkpoint);
  if (checkpointDepth > 0) {
    return LangGraphStreamOrigin(
      isSubagent: true,
      subagentDepth: checkpointDepth,
      subagentNamespace: _extractSubagentNamespaceFromCheckpoint(checkpoint),
      subagentName: _extractSubagentName(metadata),
    );
  }

  return LangGraphStreamOrigin.main;
}

bool _isEndEvent(SseEvent event) {
  if (event.name == 'end' || event.name == 'messages/end') {
    return true;
  }

  final decoded = _tryDecode(event.data);
  return decoded is Map<String, dynamic> && decoded['event'] == 'end';
}

String _resolveEndReason(SseEvent event) {
  if (event.name == 'messages/end') {
    return 'messages_end';
  }
  if (event.name == 'end') {
    return 'event_end';
  }

  final decoded = _tryDecode(event.data);
  if (decoded is Map<String, dynamic> && decoded['event'] == 'end') {
    final reason = decoded['reason'];
    if (reason is String && reason.isNotEmpty) {
      return reason;
    }
  }
  return 'event_end';
}

String? _extractRunIdFromPayload(String? rawData) {
  final decoded = _tryDecode(rawData);
  if (decoded is! Map<String, dynamic>) {
    return null;
  }
  return _readString(decoded, 'run_id');
}

dynamic _tryDecode(String? rawData) {
  if (rawData == null || rawData.trim().isEmpty) {
    return null;
  }
  try {
    return jsonDecode(rawData.trim());
  } catch (_) {
    return null;
  }
}

bool _looksLikeTaskPayload(Map<String, dynamic> data) {
  return data.containsKey('id') && data.containsKey('name');
}

String? _readString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}

int _countSubagentDepth(String source) {
  if (source.isEmpty) {
    return 0;
  }
  return RegExp(r'(^|\|)tools:').allMatches(source).length;
}

String? _extractSubagentNamespaceFromEvent(String eventName) {
  if (!eventName.startsWith('messages|')) {
    return null;
  }

  var namespace = eventName.substring('messages|'.length);
  final modelRequestIndex = namespace.lastIndexOf('|model_request:');
  if (modelRequestIndex != -1) {
    namespace = namespace.substring(0, modelRequestIndex);
  }

  if (namespace.isEmpty || namespace.startsWith('model_request:')) {
    return null;
  }

  return namespace;
}

String? _extractSubagentNamespaceFromCheckpoint(String checkpoint) {
  if (checkpoint.isEmpty) {
    return null;
  }

  var namespace = checkpoint;
  final modelRequestIndex = namespace.lastIndexOf('|model_request:');
  if (modelRequestIndex != -1) {
    namespace = namespace.substring(0, modelRequestIndex);
  }

  if (!namespace.contains('tools:')) {
    return null;
  }
  return namespace;
}

String? _extractSubagentName(StreamMetadata metadata) {
  final name = metadata.name;
  if (name == null || name.isEmpty) {
    return null;
  }
  if (name == 'model_request' || name == 'tools') {
    return null;
  }
  return name;
}
