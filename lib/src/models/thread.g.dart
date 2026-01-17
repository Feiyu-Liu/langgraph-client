// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thread _$ThreadFromJson(Map<String, dynamic> json) => Thread(
  threadId: json['thread_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
  status: json['status'] as String,
  values: json['values'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ThreadToJson(Thread instance) => <String, dynamic>{
  'thread_id': instance.threadId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
  'status': instance.status,
  'values': ?instance.values,
};

ThreadState _$ThreadStateFromJson(Map<String, dynamic> json) => ThreadState(
  values: json['values'],
  next: (json['next'] as List<dynamic>).map((e) => e as String).toList(),
  tasks: (json['tasks'] as List<dynamic>)
      .map((e) => TaskState.fromJson(e as Map<String, dynamic>))
      .toList(),
  checkpoint: CheckpointConfig.fromJson(
    json['checkpoint'] as Map<String, dynamic>,
  ),
  metadata: json['metadata'] as Map<String, dynamic>,
  createdAt: json['created_at'] as String,
  parentCheckpoint: json['parent_checkpoint'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ThreadStateToJson(ThreadState instance) =>
    <String, dynamic>{
      'values': ?instance.values,
      'next': instance.next,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
      'checkpoint': instance.checkpoint.toJson(),
      'metadata': instance.metadata,
      'created_at': instance.createdAt,
      'parent_checkpoint': ?instance.parentCheckpoint,
    };

TaskState _$TaskStateFromJson(Map<String, dynamic> json) => TaskState(
  id: json['id'] as String,
  name: json['name'] as String,
  error: json['error'] as String?,
  interrupts: json['interrupts'] as List<dynamic>?,
  checkpoint: json['checkpoint'] == null
      ? null
      : CheckpointConfig.fromJson(json['checkpoint'] as Map<String, dynamic>),
  state: json['state'] == null
      ? null
      : ThreadState.fromJson(json['state'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskStateToJson(TaskState instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'error': ?instance.error,
  'interrupts': ?instance.interrupts,
  'checkpoint': ?instance.checkpoint?.toJson(),
  'state': ?instance.state?.toJson(),
};
