import 'dart:convert';

import 'package:langgraph_client/langgraph_client.dart';
import 'package:sse_stream/sse_stream.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming API', () {
    test('parses message tuple into LangGraphMessageEvent', () {
      final event = SseEvent(
        name: 'messages|tools:subagent-1|model_request:node-1',
        data: jsonEncode([
          {
            'content': [
              {'index': 0, 'type': 'text', 'text': 'hello'},
            ],
            'additional_kwargs': {},
            'response_metadata': {},
            'tool_calls': [],
            'invalid_tool_calls': [],
            'id': 'msg_1',
            'type': 'ai',
          },
          {
            'tags': [],
            'run_attempt': 1,
            'langgraph_version': '1.0.0',
            'langgraph_plan': 'developer',
            'langgraph_host': 'self-hosted',
            'langgraph_api_url': 'http://localhost:2024',
            'run_id': 'run_1',
            'thread_id': 'thread_1',
            'graph_id': 'agent',
            'assistant_id': 'assistant_1',
            'langgraph_step': 1,
            'langgraph_node': 'model_request',
          },
        ]),
      );

      final parsed = parseLangGraphEvent(event);
      expect(parsed, isA<LangGraphMessageEvent>());

      final messageEvent = parsed as LangGraphMessageEvent;
      expect(messageEvent.textDelta, equals('hello'));
      expect(messageEvent.runId, equals('run_1'));
      expect(messageEvent.origin.isSubagent, isTrue);
      expect(messageEvent.origin.subagentDepth, equals(1));
    });

    test('normalizes tool message checkpoint depth to owning subagent', () {
      final event = SseEvent(
        name: 'messages',
        data: jsonEncode([
          {
            'content': '{"success":true}',
            'additional_kwargs': {},
            'response_metadata': {},
            'id': 'tool_msg_1',
            'status': 'success',
            'tool_call_id': 'call_1',
            'type': 'tool',
          },
          {
            'tags': [],
            'run_attempt': 1,
            'langgraph_version': '1.0.0',
            'langgraph_plan': 'developer',
            'langgraph_host': 'self-hosted',
            'langgraph_api_url': 'http://localhost:2024',
            'run_id': 'run_1',
            'thread_id': 'thread_1',
            'graph_id': 'agent',
            'assistant_id': 'assistant_1',
            'langgraph_step': 1,
            'langgraph_node': 'tools',
            'langgraph_checkpoint_ns':
                'tools:parent|tools:child|tools:tool-node',
          },
        ]),
      );

      final parsed = parseLangGraphEvent(event) as LangGraphMessageEvent;
      expect(parsed.message.isToolMessage, isTrue);
      expect(parsed.origin.isSubagent, isTrue);
      expect(parsed.origin.subagentDepth, equals(2));
      expect(parsed.origin.subagentNamespace, equals('tools:parent|tools:child'));
    });

    test('normalizes tool message event namespace to owning subagent', () {
      final event = SseEvent(
        name: 'messages|tools:parent|tools:child|tools:tool-node',
        data: jsonEncode([
          {
            'content': '{"success":true}',
            'additional_kwargs': {},
            'response_metadata': {},
            'id': 'tool_msg_2',
            'status': 'success',
            'tool_call_id': 'call_2',
            'type': 'tool',
          },
          {
            'tags': [],
            'run_attempt': 1,
            'langgraph_version': '1.0.0',
            'langgraph_plan': 'developer',
            'langgraph_host': 'self-hosted',
            'langgraph_api_url': 'http://localhost:2024',
            'run_id': 'run_1',
            'thread_id': 'thread_1',
            'graph_id': 'agent',
            'assistant_id': 'assistant_1',
            'langgraph_step': 1,
            'langgraph_node': 'tools',
          },
        ]),
      );

      final parsed = parseLangGraphEvent(event) as LangGraphMessageEvent;
      expect(parsed.message.isToolMessage, isTrue);
      expect(parsed.origin.isSubagent, isTrue);
      expect(parsed.origin.subagentDepth, equals(2));
      expect(parsed.origin.subagentNamespace, equals('tools:parent|tools:child'));
    });

    test('projects structured events to conversation events', () async {
      final stream = Stream<LangGraphStreamEvent>.fromIterable([
        LangGraphMetadataEvent(
          eventName: 'metadata',
          metadata: const {
            'run_id': 'run_1',
            'thread_id': 'thread_1',
            'assistant_id': 'assistant_1',
          },
          runId: 'run_1',
          threadId: 'thread_1',
          assistantId: 'assistant_1',
        ),
        LangGraphMessageEvent(
          eventName: 'messages',
          message: StreamMessage(
            content: [MessageContent(index: 0, type: 'text', text: 'hello')],
            additionalKwargs: const {},
            id: 'msg_1',
            type: 'ai',
          ),
          metadata: StreamMetadata(
            tags: const [],
            runAttempt: 1,
            langgraphVersion: '1.0.0',
            langgraphPlan: 'developer',
            langgraphHost: 'self-hosted',
            langgraphApiUrl: 'http://localhost:2024',
            runId: 'run_1',
            threadId: 'thread_1',
            graphId: 'agent',
            assistantId: 'assistant_1',
            langgraphStep: 1,
            langgraphNode: 'model_request',
          ),
          runId: 'run_1',
          textDelta: 'hello',
          origin: LangGraphStreamOrigin.main,
        ),
        LangGraphTaskStreamEvent(
          eventName: 'tasks',
          task: TaskEvent(
            id: 'task_1',
            name: 'tools',
            triggers: const [],
            interrupts: [
              TaskInterrupt(
                id: 'interrupt_1',
                value: const {'prompt': 'Need approval'},
              ),
            ],
          ),
        ),
        const LangGraphEndEvent(
          eventName: 'end',
          reason: 'event_end',
          runId: 'run_1',
        ),
      ]);

      final events = await toConversationStreamEvents(stream).toList();
      expect(events.whereType<ConversationStartedEvent>(), hasLength(1));
      expect(events.whereType<ConversationTextDeltaEvent>(), hasLength(1));
      expect(events.whereType<ConversationInterruptEvent>(), hasLength(1));
      expect(events.whereType<ConversationCompletedEvent>(), hasLength(1));
    });
  });
}
