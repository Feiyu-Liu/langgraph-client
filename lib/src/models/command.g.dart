// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Command _$CommandFromJson(Map<String, dynamic> json) => Command(
  update: json['update'] as Map<String, dynamic>?,
  resume: json['resume'],
  send: Command._parseSend(json['send']),
);

Map<String, dynamic> _$CommandToJson(Command instance) => <String, dynamic>{
  'update': ?instance.update,
  'resume': ?instance.resume,
  'send': ?instance.send,
};
