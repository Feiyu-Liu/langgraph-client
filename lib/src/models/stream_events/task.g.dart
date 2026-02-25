// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskInput _$TaskInputFromJson(Map<String, dynamic> json) => TaskInput(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => StreamMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  todos: json['todos'] as List<dynamic>,
  files: json['files'] as Map<String, dynamic>,
);

Map<String, dynamic> _$TaskInputToJson(TaskInput instance) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'todos': instance.todos,
  'files': instance.files,
};

TaskResult _$TaskResultFromJson(Map<String, dynamic> json) => TaskResult(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => StreamMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TaskResultToJson(TaskResult instance) =>
    <String, dynamic>{
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

TaskInterrupt _$TaskInterruptFromJson(Map<String, dynamic> json) =>
    TaskInterrupt(
      id: json['id'] as String,
      value: json['value'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TaskInterruptToJson(TaskInterrupt instance) =>
    <String, dynamic>{'id': instance.id, 'value': instance.value};

TaskEvent _$TaskEventFromJson(Map<String, dynamic> json) => TaskEvent(
  id: json['id'] as String,
  name: json['name'] as String,
  input: json['input'] == null
      ? null
      : TaskInput.fromJson(json['input'] as Map<String, dynamic>),
  result: json['result'] == null
      ? null
      : TaskResult.fromJson(json['result'] as Map<String, dynamic>),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interrupts: (json['interrupts'] as List<dynamic>)
      .map((e) => TaskInterrupt.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TaskEventToJson(TaskEvent instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'input': ?instance.input?.toJson(),
  'result': ?instance.result?.toJson(),
  'triggers': instance.triggers,
  'interrupts': instance.interrupts.map((e) => e.toJson()).toList(),
};
