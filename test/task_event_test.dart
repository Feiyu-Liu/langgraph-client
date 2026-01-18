import 'dart:convert';
import 'package:langgraph_client/langgraph_client.dart';
import 'package:sse_stream/sse_stream.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Task Event Parsing', () {
    group('TaskEvent models', () {
      test('parses task event with input', () {
        final jsonData = {
          "id": "7660a93f-70ff-5108-a583-1cdb2aca6b7c",
          "name": "patchToolCallsMiddleware.before_agent",
          "input": {
            "messages": [
              {
                "content": [
                  {"index": 0, "type": "text", "text": "Hello"}
                ],
                "additional_kwargs": {},
                "response_metadata": {},
                "tool_calls": [],
                "invalid_tool_calls": [],
                "id": "msg_123",
                "type": "ai"
              }
            ],
            "todos": [],
            "files": {}
          },
          "triggers": ["branch:to:patchToolCallsMiddleware.before_agent"],
          "interrupts": []
        };

        final taskEvent = TaskEvent.fromJson(jsonData);

        expect(taskEvent.id, equals('7660a93f-70ff-5108-a583-1cdb2aca6b7c'));
        expect(taskEvent.name, equals('patchToolCallsMiddleware.before_agent'));
        expect(taskEvent.input, isNotNull);
        expect(taskEvent.result, isNull);
        expect(taskEvent.isInputTask, isTrue);
        expect(taskEvent.isResultTask, isFalse);
        expect(taskEvent.hasInterrupts, isFalse);
      });

      test('parses task event with result', () {
        final jsonData = {
          "id": "8660a93f-70ff-5108-a583-1cdb2aca6b7d",
          "name": "model_request",
          "result": {
            "messages": [
              {
                "content": [
                  {"index": 0, "type": "text", "text": "Response"}
                ],
                "additional_kwargs": {},
                "response_metadata": {},
                "tool_calls": [],
                "invalid_tool_calls": [],
                "id": "msg_456",
                "type": "ai"
              }
            ]
          },
          "interrupts": []
        };

        final taskEvent = TaskEvent.fromJson(jsonData);

        expect(taskEvent.id, equals('8660a93f-70ff-5108-a583-1cdb2aca6b7d'));
        expect(taskEvent.name, equals('model_request'));
        expect(taskEvent.input, isNull);
        expect(taskEvent.result, isNotNull);
        expect(taskEvent.isInputTask, isFalse);
        expect(taskEvent.isResultTask, isTrue);
        expect(taskEvent.isModelRequest, isTrue);
        expect(taskEvent.isToolsTask, isFalse);
      });

      test('parses task event with interrupts', () {
        final jsonData = {
          "id": "9660a93f-70ff-5108-a583-1cdb2aca6b7e",
          "name": "tools",
          "input": {
            "messages": [],
            "todos": [],
            "files": {}
          },
          "triggers": [],
          "interrupts": [
            {
              "id": "interrupt_1",
              "value": {
                "type": "question",
                "questions": ["What is your name?"]
              }
            }
          ]
        };

        final taskEvent = TaskEvent.fromJson(jsonData);

        expect(taskEvent.id, equals('9660a93f-70ff-5108-a583-1cdb2aca6b7e'));
        expect(taskEvent.name, equals('tools'));
        expect(taskEvent.interrupts, hasLength(1));
        expect(taskEvent.hasInterrupts, isTrue);
        expect(taskEvent.interrupts[0].id, equals('interrupt_1'));
        expect(taskEvent.interrupts[0].value, containsPair('type', 'question'));
        expect(taskEvent.isToolsTask, isTrue);
      });

      test('convenience methods work correctly', () {
        final modelRequestTask = TaskEvent(
          id: 'task_1',
          name: 'model_request',
          input: TaskInput(
            messages: [],
            todos: [],
            files: {},
          ),
          triggers: [],
          interrupts: [],
        );

        expect(modelRequestTask.isInputTask, isTrue);
        expect(modelRequestTask.isResultTask, isFalse);
        expect(modelRequestTask.hasInterrupts, isFalse);
        expect(modelRequestTask.isModelRequest, isTrue);
        expect(modelRequestTask.isToolsTask, isFalse);

        final toolsTask = TaskEvent(
          id: 'task_2',
          name: 'tools',
          result: TaskResult(messages: []),
          triggers: [],
          interrupts: [],
        );

        expect(toolsTask.isInputTask, isFalse);
        expect(toolsTask.isResultTask, isTrue);
        expect(toolsTask.isModelRequest, isFalse);
        expect(toolsTask.isToolsTask, isTrue);
      });

      test('TaskInput serializes correctly', () {
        final taskInput = TaskInput(
          messages: [
            StreamMessage(
              content: [
                MessageContent(index: 0, type: 'text', text: 'Hello')
              ],
              additionalKwargs: {},
              id: 'msg_123',
              type: 'ai',
            )
          ],
          todos: ['task1', 'task2'],
          files: {'file1.txt': 'content'},
        );

        final json = taskInput.toJson();
        expect(json['messages'], isNotEmpty);
        expect(json['todos'], equals(['task1', 'task2']));
        expect(json['files'], equals({'file1.txt': 'content'}));
      });

      test('TaskResult serializes correctly', () {
        final taskResult = TaskResult(
          messages: [
            StreamMessage(
              content: [
                MessageContent(index: 0, type: 'text', text: 'Result')
              ],
              additionalKwargs: {},
              id: 'msg_456',
              type: 'ai',
            )
          ],
        );

        final json = taskResult.toJson();
        expect(json['messages'], hasLength(1));
      });

      test('TaskInterrupt serializes correctly', () {
        final interrupt = TaskInterrupt(
          id: 'interrupt_123',
          value: {'type': 'question', 'data': 'value'},
        );

        final json = interrupt.toJson();
        expect(json['id'], equals('interrupt_123'));
        expect(json['value'], equals({'type': 'question', 'data': 'value'}));
      });
    });

    group('parseTaskEvent function', () {
      test('returns null for invalid data', () {
        final invalidData = {'name': 'task'}; // missing 'id'

        final result = parseTaskEvent(invalidData);

        expect(result, isNull);
      });

      test('returns null for data without name', () {
        final invalidData = {'id': '123'}; // missing 'name'

        final result = parseTaskEvent(invalidData);

        expect(result, isNull);
      });

      test('parses valid task event', () {
        final validData = {
          'id': 'task_123',
          'name': 'model_request',
          'triggers': [],
          'interrupts': [],
        };

        final result = parseTaskEvent(validData);

        expect(result, isNotNull);
        expect(result!.id, equals('task_123'));
        expect(result.name, equals('model_request'));
      });

      test('throws LangGraphApiException on parse error', () {
        final invalidData = {
          'id': 'task_123',
          'name': 'model_request',
          'input': 'invalid', // should be a map or null
          'triggers': [],
          'interrupts': [],
        };

        expect(
          () => parseTaskEvent(invalidData),
          throwsA(isA<LangGraphApiException>()),
        );
      });
    });

    group('parseTaskEventData function (SSE integration)', () {
      test('parses SSE event with task data', () {
        final taskData = {
          "id": "7660a93f-70ff-5108-a583-1cdb2aca6b7c",
          "name": "patchToolCallsMiddleware.before_agent",
          "input": {
            "messages": [],
            "todos": [],
            "files": {}
          },
          "triggers": ["branch:to:patchToolCallsMiddleware.before_agent"],
          "interrupts": []
        };

        final sseEvent = SseEvent(
          name: 'tasks',
          data: jsonEncode(taskData),
        );

        final parsed = parseTaskEventData(sseEvent);

        expect(parsed, isNotNull);
        expect(parsed!.task.id, equals('7660a93f-70ff-5108-a583-1cdb2aca6b7c'));
        expect(parsed.task.name, equals('patchToolCallsMiddleware.before_agent'));
        expect(parsed.task.isInputTask, isTrue);
      });

      test('returns null for SSE event with empty data', () {
        final sseEvent = SseEvent(
          name: 'tasks',
          data: '',
        );

        final parsed = parseTaskEventData(sseEvent);

        expect(parsed, isNull);
      });

      test('returns null for SSE event with null data', () {
        final sseEvent = SseEvent(
          name: 'tasks',
          data: null,
        );

        final parsed = parseTaskEventData(sseEvent);

        expect(parsed, isNull);
      });

      test('returns null for SSE event with invalid JSON', () {
        final sseEvent = SseEvent(
          name: 'tasks',
          data: 'invalid json{',
        );

        // Invalid JSON throws FormatException, which should be re-thrown as LangGraphApiException
        // Since parseTaskEventData catches FormatException and returns null, this should return null
        final parsed = parseTaskEventData(sseEvent);

        // The function catches LangGraphApiException and returns null
        expect(parsed, isNull);
      });

      test('returns null for SSE event with non-object data', () {
        final sseEvent = SseEvent(
          name: 'tasks',
          data: jsonEncode(['array', 'data']),
        );

        final parsed = parseTaskEventData(sseEvent);

        expect(parsed, isNull);
      });

      test('returns null for SSE event without id or name', () {
        final sseEvent = SseEvent(
          name: 'tasks',
          data: jsonEncode({'other': 'data'}),
        );

        final parsed = parseTaskEventData(sseEvent);

        expect(parsed, isNull);
      });
    });

    group('Real-world task event scenarios', () {
      test('parses complete task event with input and messages', () {
        final jsonData = {
          "id": "7660a93f-70ff-5108-a583-1cdb2aca6b7c",
          "name": "patchToolCallsMiddleware.before_agent",
          "input": {
            "messages": [
              {
                "content": [
                  {
                    "index": 0,
                    "type": "text",
                    "text": "你能做什么"
                  }
                ],
                "additional_kwargs": {},
                "response_metadata": {},
                "tool_calls": [],
                "invalid_tool_calls": [],
                "id": "msg_user_123",
                "type": "human"
              }
            ],
            "todos": [],
            "files": {}
          },
          "triggers": ["branch:to:patchToolCallsMiddleware.before_agent"],
          "interrupts": []
        };

        final taskEvent = TaskEvent.fromJson(jsonData);

        expect(taskEvent.name, contains('agent'));
        expect(taskEvent.input!.messages, hasLength(1));
        expect(taskEvent.input!.messages[0].type, equals('human'));
        // firstText only returns text for AI messages, not human messages
        expect(taskEvent.input!.messages[0].firstText, isNull);
        // But we can still access the content directly
        expect(taskEvent.input!.messages[0].content[0].text, equals('你能做什么'));
        expect(taskEvent.triggers, contains('branch:to:patchToolCallsMiddleware.before_agent'));
      });

      test('parses task event with multiple interrupts', () {
        final jsonData = {
          "id": "task_interrupts",
          "name": "tools",
          "result": {
            "messages": []
          },
          "interrupts": [
            {
              "id": "interrupt_1",
              "value": {
                "type": "question",
                "questions": ["What is your name?", "How old are you?"]
              }
            },
            {
              "id": "interrupt_2",
              "value": {
                "type": "approval",
                "metadata": {"requires": ["admin", "moderator"]}
              }
            }
          ]
        };

        final taskEvent = TaskEvent.fromJson(jsonData);

        expect(taskEvent.interrupts, hasLength(2));
        expect(taskEvent.interrupts[0].value['questions'], hasLength(2));
        expect(taskEvent.interrupts[1].value['type'], equals('approval'));
      });

      test('handles task event with empty arrays', () {
        final jsonData = {
          "id": "empty_task",
          "name": "SummarizationMiddleware.before_model",
          "input": {
            "messages": [],
            "todos": [],
            "files": {}
          },
          "triggers": [],
          "interrupts": []
        };

        final taskEvent = TaskEvent.fromJson(jsonData);

        expect(taskEvent.input!.messages, isEmpty);
        expect(taskEvent.input!.todos, isEmpty);
        expect(taskEvent.input!.files, isEmpty);
        expect(taskEvent.triggers, isEmpty);
        expect(taskEvent.interrupts, isEmpty);
      });
    });
  });
}
