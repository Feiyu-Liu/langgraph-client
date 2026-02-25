import 'dart:convert';
import 'package:langgraph_client/langgraph_client.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Tool Message Parsing', () {
    test('parses tool result message with string content', () {
      // This is the actual SSE data format from LangGraph for tool results
      final sseData = jsonEncode([
        {
          "status": "success",
          "content": '{"city": "武汉市", "forecasts": []}',
          "artifact": [],
          "tool_call_id": "call_f57fd77c7f5940d097706fba",
          "name": "maps_weather",
          "metadata": {},
          "additional_kwargs": {},
          "response_metadata": {},
          "id": "run-019bcb93-e662-7000-8000-0d0df6c7f88e",
          "type": "tool",
        },
        {
          "tags": ["graph:step:5"],
          "name": "tools",
          "run_attempt": 1,
          "run_id": "2cb03d41-7bfd-4fcb-b59f-2215e13fab79",
          "langgraph_version": "1.0.13",
          "langgraph_plan": "developer",
          "langgraph_host": "self-hosted",
          "langgraph_api_url": "http://localhost:2024",
          "thread_id": "dc149e7a-289d-4877-8da1-94f1874721b7",
          "graph_id": "agent",
          "assistant_id": "2a35ed90-9273-4c9b-9d3e-477e1e18177e",
          "langgraph_step": 5,
          "langgraph_node": "tools",
        },
      ]);

      // Simulate parsing
      final parsed = jsonDecode(sseData) as List;
      final message = StreamMessage.fromJson(parsed[0] as Map<String, dynamic>);
      StreamMetadata.fromJson(parsed[1] as Map<String, dynamic>);

      expect(message.type, equals('tool'));
      expect(message.isToolMessage, isTrue);
      expect(message.toolCallId, equals('call_f57fd77c7f5940d097706fba'));
      expect(message.status, equals('success'));

      // The content should be parsed as MessageContent objects
      // For tool messages, content is typically an array with text type
      expect(message.content, isNotEmpty);
    });

    test('parses AI message with tool calls', () {
      final sseData = jsonEncode([
        {
          "content": [
            {"index": 0, "type": "text", "text": "Let me check the weather."},
          ],
          "additional_kwargs": {},
          "response_metadata": {"model_provider": "anthropic", "usage": {}},
          "tool_calls": [
            {
              "name": "maps_weather",
              "args": {"city": "武汉"},
              "id": "call_f57fd77c7f5940d097706fba",
              "type": "tool_call",
            },
          ],
          "invalid_tool_calls": [],
          "id": "msg_123",
          "type": "ai",
        },
        {
          "tags": ["graph:step:1"],
          "run_attempt": 1,
          "run_id": "run-123",
          "langgraph_version": "1.0.13",
          "langgraph_plan": "developer",
          "langgraph_host": "self-hosted",
          "langgraph_api_url": "http://localhost:2024",
          "thread_id": "thread-123",
          "graph_id": "agent",
          "assistant_id": "assistant-123",
          "langgraph_step": 1,
          "langgraph_node": "agent",
        },
      ]);

      final parsed = jsonDecode(sseData) as List;
      final message = StreamMessage.fromJson(parsed[0] as Map<String, dynamic>);

      expect(message.type, equals('ai'));
      expect(message.isAiMessage, isTrue);
      expect(message.allToolCalls, hasLength(1));
      expect(message.allToolCalls[0].name, equals('maps_weather'));
      expect(message.allToolCalls[0].args, equals({'city': '武汉'}));
    });

    test('matches tool call with result', () {
      final Map<String, ToolCall> pendingToolCalls = {};

      // Simulate tool call declaration
      final toolCall = ToolCall(
        name: 'maps_weather',
        args: {'city': '武汉'},
        id: 'call_f57fd77c7f5940d097706fba',
        type: 'tool_call',
      );
      pendingToolCalls[toolCall.id] = toolCall;

      // Simulate tool result message
      final resultMessage = StreamMessage(
        content: [
          MessageContent(index: 0, type: 'text', text: '{"city": "武汉市"}'),
        ],
        additionalKwargs: {},
        toolCallId: 'call_f57fd77c7f5940d097706fba',
        status: 'success',
        artifact: [],
        metadata: {},
        id: 'run-123',
        type: 'tool',
      );

      // Verify matching works
      expect(resultMessage.isToolMessage, isTrue);
      expect(pendingToolCalls.containsKey(resultMessage.toolCallId!), isTrue);

      final originalCall = pendingToolCalls[resultMessage.toolCallId!]!;
      expect(originalCall.name, equals('maps_weather'));
    });
  });
}
