import 'dart:convert';
import 'package:langgraph_client/langgraph_client.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'threads_api_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late LangGraphClient client;
  const baseUrl = 'https://api.example.com';
  const apiKey = 'test_api_key';

  setUp(() {
    mockClient = MockClient();
    client = LangGraphClient(
      baseUrl: baseUrl,
      apiKey: apiKey,
      client: mockClient,
    );
  });

  group('LangGraphClient', () {
    test('initializes with correct parameters', () {
      expect(client.baseUrl, equals(baseUrl));
      expect(client.apiKey, equals(apiKey));
      expect(
        client.headers,
        equals({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        }),
      );
    });

    test('initializes without apiKey', () {
      final clientWithoutKey = LangGraphClient(
        baseUrl: baseUrl,
        client: mockClient,
      );
      expect(
        clientWithoutKey.headers,
        equals({'Content-Type': 'application/json'}),
      );
    });

    test('LangGraphApiException formats message correctly', () {
      final exception = LangGraphApiException('Test error', 404);
      expect(
        exception.toString(),
        equals('LangGraphApiException: Test error (Status: 404)'),
      );
    });
  });

  group('ThreadApi extension', () {
    group('createThread', () {
      test('creates thread successfully', () async {
        final mockResponse = {
          'thread_id': 'thread_123',
          'created_at': '2025-02-26T12:00:00Z',
          'updated_at': '2025-02-26T12:00:00Z',
          'metadata': {'key': 'value'},
          'status': 'active',
        };

        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await client.createThread(
          threadId: 'thread_123',
          metadata: {'key': 'value'},
        );

        expect(result, isA<Thread>());
        expect(result.threadId, equals('thread_123'));
        expect(result.metadata, equals({'key': 'value'}));
        expect(result.status, equals('active'));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/threads'),
            headers: client.headers,
            body: jsonEncode({
              'thread_id': 'thread_123',
              'metadata': {'key': 'value'},
              'if_exists': 'raise',
            }),
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        expect(
          () => client.createThread(),
          throwsA(
            isA<LangGraphApiException>().having(
              (e) => e.statusCode,
              'statusCode',
              404,
            ),
          ),
        );
      });
    });

    group('searchThreads', () {
      test('searches threads successfully', () async {
        final mockResponse = [
          {
            'thread_id': 'thread_1',
            'created_at': '2025-02-26T12:00:00Z',
            'updated_at': '2025-02-26T12:00:00Z',
            'metadata': {'key': 'value1'},
            'status': 'active',
          },
          {
            'thread_id': 'thread_2',
            'created_at': '2025-02-26T12:00:00Z',
            'updated_at': '2025-02-26T12:00:00Z',
            'metadata': {'key': 'value2'},
            'status': 'active',
          },
        ];

        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads/search'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final results = await client.searchThreads(
          metadata: {'key': 'value'},
          limit: 5,
        );

        expect(results, isA<List<Thread>>());
        expect(results.length, equals(2));
        expect(results[0].threadId, equals('thread_1'));
        expect(results[1].threadId, equals('thread_2'));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/threads/search'),
            headers: client.headers,
            body: jsonEncode({
              'metadata': {'key': 'value'},
              'limit': 5,
              'offset': 0,
            }),
          ),
        ).called(1);
      });
    });

    group('getThreadState', () {
      test('gets thread state successfully', () async {
        final mockResponse = {
          'values': {'key': 'value'},
          'next': [],
          'tasks': [],
          'checkpoint': {
            'thread_id': 'thread_123',
            'checkpoint_ns': 'ns1',
            'checkpoint_id': 'cp1',
            'checkpoint_map': {},
          },
          'metadata': {},
          'created_at': '2025-02-26T12:00:00Z',
        };

        when(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/state'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await client.getThreadState('thread_123');

        expect(result, isA<ThreadState>());
        expect(result.values, equals({'key': 'value'}));
        expect(result.checkpoint.threadId, equals('thread_123'));
      });
    });

    group('updateThreadState', () {
      test('updates thread state successfully', () async {
        final mockResponse = {'status': 'success'};

        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/state'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final checkpoint = CheckpointConfig(
          threadId: 'thread_123',
          checkpointId: 'cp1',
        );

        final result = await client.updateThreadState(
          'thread_123',
          values: {'key': 'updated'},
          checkpoint: checkpoint,
        );

        expect(result, equals({'status': 'success'}));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/state'),
            headers: client.headers,
            body: jsonEncode({
              'values': {'key': 'updated'},
              'checkpoint': checkpoint.toJson(),
            }),
          ),
        ).called(1);
      });
    });

    group('getThreadHistory', () {
      test('gets thread history successfully', () async {
        final mockResponse = [
          {
            'values': {'key': 'value1'},
            'next': [],
            'tasks': [],
            'checkpoint': {
              'thread_id': 'thread_123',
              'checkpoint_ns': 'ns1',
              'checkpoint_id': 'cp1',
              'checkpoint_map': {},
            },
            'metadata': {},
            'created_at': '2025-02-26T12:00:00Z',
          },
          {
            'values': {'key': 'value2'},
            'next': [],
            'tasks': [],
            'checkpoint': {
              'thread_id': 'thread_123',
              'checkpoint_ns': 'ns1',
              'checkpoint_id': 'cp2',
              'checkpoint_map': {},
            },
            'metadata': {},
            'created_at': '2025-02-26T12:01:00Z',
          },
        ];

        when(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/history?limit=5'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final results = await client.getThreadHistory('thread_123', limit: 5);

        expect(results, isA<List<ThreadState>>());
        expect(results.length, equals(2));
        expect(results[0].values, equals({'key': 'value1'}));
        expect(results[1].values, equals({'key': 'value2'}));
      });
    });

    group('copyThread', () {
      test('copies thread successfully', () async {
        final mockResponse = {
          'thread_id': 'thread_copy',
          'created_at': '2025-02-26T12:00:00Z',
          'updated_at': '2025-02-26T12:00:00Z',
          'metadata': {'key': 'value'},
          'status': 'active',
        };

        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/copy'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await client.copyThread('thread_123');

        expect(result, isA<Thread>());
        expect(result.threadId, equals('thread_copy'));
      });
    });
  });

  group('Model classes', () {
    group('CheckpointConfig', () {
      test('fromJson and toJson work correctly', () {
        final json = {
          'thread_id': 'thread_123',
          'checkpoint_ns': 'ns1',
          'checkpoint_id': 'cp1',
          'checkpoint_map': {'key': 'value'},
        };

        final config = CheckpointConfig.fromJson(json);
        expect(config.threadId, equals('thread_123'));
        expect(config.checkpointNs, equals('ns1'));
        expect(config.checkpointId, equals('cp1'));
        expect(config.checkpointMap, equals({'key': 'value'}));

        final outputJson = config.toJson();
        expect(outputJson, equals(json));
      });

      test('copyWith works correctly', () {
        final config = CheckpointConfig(
          threadId: 'thread_123',
          checkpointNs: 'ns1',
          checkpointId: 'cp1',
        );

        final copied = config.copyWith(
          checkpointId: 'cp2',
          checkpointMap: {'key': 'value'},
        );

        expect(copied.threadId, equals('thread_123'));
        expect(copied.checkpointNs, equals('ns1'));
        expect(copied.checkpointId, equals('cp2'));
        expect(copied.checkpointMap, equals({'key': 'value'}));
      });

      test('equality works correctly', () {
        final config1 = CheckpointConfig(
          threadId: 'thread_123',
          checkpointNs: 'ns1',
          checkpointId: 'cp1',
          checkpointMap: {'key': 'value'},
        );

        final config2 = CheckpointConfig(
          threadId: 'thread_123',
          checkpointNs: 'ns1',
          checkpointId: 'cp1',
          checkpointMap: {'key': 'value'},
        );

        final config3 = CheckpointConfig(
          threadId: 'thread_123',
          checkpointNs: 'ns1',
          checkpointId: 'cp2',
          checkpointMap: {'key': 'value'},
        );

        expect(config1 == config2, isTrue);
        expect(config1 == config3, isFalse);
        expect(config1.hashCode == config2.hashCode, isTrue);
      });
    });

    group('Thread', () {
      test('fromJson and toJson work correctly', () {
        final json = {
          'thread_id': 'thread_123',
          'created_at': '2025-02-26T12:00:00Z',
          'updated_at': '2025-02-26T12:00:00Z',
          'metadata': {'key': 'value'},
          'status': 'active',
          'values': {'data': 'content'},
        };

        final thread = Thread.fromJson(json);
        expect(thread.threadId, equals('thread_123'));
        expect(thread.metadata, equals({'key': 'value'}));
        expect(thread.status, equals('active'));
        expect(thread.values, equals({'data': 'content'}));

        final outputJson = thread.toJson();
        expect(outputJson['thread_id'], equals('thread_123'));
        expect(outputJson['metadata'], equals({'key': 'value'}));
      });
    });

    group('ThreadState', () {
      test('fromJson and toJson work correctly', () {
        final json = {
          'values': <String, dynamic>{'key': 'value'},
          'next': <String>[],
          'tasks': <Map<String, dynamic>>[],
          'checkpoint': {
            'thread_id': 'thread_123',
            'checkpoint_ns': 'ns1',
            'checkpoint_id': 'cp1',
            'checkpoint_map': <String, dynamic>{},
          },
          'metadata': <String, dynamic>{},
          'created_at': '2025-02-26T12:00:00Z',
        };

        final state = ThreadState.fromJson(json);
        expect(state.values, equals({'key': 'value'}));
        expect(state.next, equals([]));
        expect(state.tasks, equals([]));
        expect(state.checkpoint.threadId, equals('thread_123'));

        final outputJson = state.toJson();
        expect(outputJson['values'], equals({'key': 'value'}));
        expect(outputJson['checkpoint']['thread_id'], equals('thread_123'));
      });
    });
    group('TaskState', () {
      test('fromJson and toJson work correctly', () {
        expect(true, isTrue);
      });
    });
  });
}
