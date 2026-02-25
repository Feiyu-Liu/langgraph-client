import 'package:json_annotation/json_annotation.dart';

import '../../api/client.dart';
import 'message.dart';

part 'task.g.dart';

/// Helper function to safely cast `Map<dynamic, dynamic>` to `Map<String, dynamic>`.
Map<String, dynamic> _castMap(dynamic map) {
  if (map == null) return {};
  if (map is! Map) return {};
  final result = <String, dynamic>{};
  map.forEach((key, value) {
    result[key.toString()] = _convertDynamic(value);
  });
  return result;
}

/// Recursively convert dynamic values to proper types
dynamic _convertDynamic(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return _castMap(value);
  }
  if (value is List) {
    return value.map((e) => _convertDynamic(e)).toList();
  }
  return value;
}

/// Helper function to safely convert a dynamic map to `Map<String, dynamic>`
/// for use with StreamMessage.fromJson
Map<String, dynamic> _convertToMapStringDynamic(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) {
    // Recursively convert nested maps
    return _castMap(value);
  }
  if (value is Map) {
    return _castMap(value);
  }
  return {};
}

/// Task input data (input field in task events)
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TaskInput {
  final List<StreamMessage> messages;
  final List<dynamic> todos;
  final Map<String, dynamic> files;

  TaskInput({required this.messages, required this.todos, required this.files});

  /// Custom fromJson to handle `Map<dynamic, dynamic>` casting
  factory TaskInput.fromJson(Map<String, dynamic> json) {
    // Cast files Map from dynamic to Map<String, dynamic>
    final filesCast = _castMap(json['files']);

    // Parse messages using the generated code
    final messagesData = json['messages'] as List;
    final messages = messagesData
        .map((e) => StreamMessage.fromJson(_convertToMapStringDynamic(e)))
        .toList();

    // Parse todos
    final todosData = json['todos'] as List;

    return TaskInput(messages: messages, todos: todosData, files: filesCast);
  }

  Map<String, dynamic> toJson() => _$TaskInputToJson(this);
}

/// Task result data (result field in task events)
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TaskResult {
  final List<StreamMessage> messages;

  TaskResult({required this.messages});

  /// Custom fromJson to handle `Map<dynamic, dynamic>` casting
  factory TaskResult.fromJson(Map<String, dynamic> json) {
    // Parse messages - handle empty result objects
    final messagesData = json['messages'] as List?;
    final messages = messagesData == null
        ? <StreamMessage>[]
        : messagesData
              .map((e) => StreamMessage.fromJson(_convertToMapStringDynamic(e)))
              .toList();

    return TaskResult(messages: messages);
  }

  Map<String, dynamic> toJson() => _$TaskResultToJson(this);
}

/// Interrupt object in task events
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TaskInterrupt {
  final String id;
  final Map<String, dynamic> value;

  TaskInterrupt({required this.id, required this.value});

  /// Custom fromJson to handle `Map<dynamic, dynamic>` casting
  factory TaskInterrupt.fromJson(Map<String, dynamic> json) {
    return TaskInterrupt(
      id: json['id'] as String,
      value: _castMap(json['value']),
    );
  }

  Map<String, dynamic> toJson() => _$TaskInterruptToJson(this);
}

/// Task event from LangGraph SSE stream
///
/// Represents a task event (event: tasks) from the
/// `/threads/{thread_id}/runs/stream` endpoint.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TaskEvent {
  final String id;
  final String name;
  final TaskInput? input;
  final TaskResult? result;
  final List<String> triggers;
  final List<TaskInterrupt> interrupts;

  TaskEvent({
    required this.id,
    required this.name,
    this.input,
    this.result,
    required this.triggers,
    required this.interrupts,
  });

  /// Custom fromJson to handle null triggers and proper type casting
  factory TaskEvent.fromJson(Map<String, dynamic> json) {
    // Parse triggers with null safety
    final triggersData = json['triggers'];
    List<String> triggersCast = [];
    if (triggersData != null && triggersData is List) {
      triggersCast = triggersData.map((e) => e.toString()).toList();
    }

    // Parse interrupts
    final interruptsData = json['interrupts'] as List? ?? [];
    final interrupts = interruptsData
        .map((e) => TaskInterrupt.fromJson(_convertToMapStringDynamic(e)))
        .toList();

    // Parse input
    TaskInput? input;
    if (json['input'] != null) {
      input = TaskInput.fromJson(_convertToMapStringDynamic(json['input']));
    }

    // Parse result
    TaskResult? result;
    if (json['result'] != null) {
      result = TaskResult.fromJson(_convertToMapStringDynamic(json['result']));
    }

    return TaskEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      input: input,
      result: result,
      triggers: triggersCast,
      interrupts: interrupts,
    );
  }

  Map<String, dynamic> toJson() => _$TaskEventToJson(this);

  /// Convenience method: check if this is an input task
  bool get isInputTask => input != null;

  /// Convenience method: check if this is a result task
  bool get isResultTask => result != null;

  /// Convenience method: check if this task has interrupts
  bool get hasInterrupts => interrupts.isNotEmpty;

  /// Convenience method: check if this is a model request task
  bool get isModelRequest => name == 'model_request';

  /// Convenience method: check if this is a tools task
  bool get isToolsTask => name == 'tools';
}

/// Parses a task event from SSE data
///
/// Returns [TaskEvent] if the data is a valid task event, null otherwise.
TaskEvent? parseTaskEvent(Map<String, dynamic> data) {
  try {
    // Check if it's a task event (should have id and name fields)
    if (!data.containsKey('id') || !data.containsKey('name')) {
      return null;
    }

    return TaskEvent.fromJson(data);
  } catch (e) {
    throw LangGraphApiException('Failed to parse TaskEvent: $e');
  }
}
