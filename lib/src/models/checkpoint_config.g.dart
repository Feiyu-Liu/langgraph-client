// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckpointConfig _$CheckpointConfigFromJson(Map<String, dynamic> json) =>
    CheckpointConfig(
      threadId: json['thread_id'] as String?,
      checkpointNs: json['checkpoint_ns'] as String?,
      checkpointId: json['checkpoint_id'] as String?,
      checkpointMap: json['checkpoint_map'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CheckpointConfigToJson(CheckpointConfig instance) =>
    <String, dynamic>{
      'thread_id': ?instance.threadId,
      'checkpoint_ns': ?instance.checkpointNs,
      'checkpoint_id': ?instance.checkpointId,
      'checkpoint_map': ?instance.checkpointMap,
    };
