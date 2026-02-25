import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:langgraph_client/langgraph_client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'thread_runs_api_test.mocks.dart';

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

  group('ThreadRunsApi extension', () {
    group('listStatefulRuns', () {
      test('lists stateful runs successfully', () async {
        final mockResponse = [
          {
            'run_id': 'run_1',
            'thread_id': 'thread_1',
            'assistant_id': 'assistant_1',
            'created_at': '2025-02-26T12:00:00Z',
            'updated_at': '2025-02-26T12:00:00Z',
            'status': 'completed',
            'metadata': {'key': 'value1'},
            'kwargs': {},
            'multitask_strategy': 'reject',
          },
          {
            'run_id': 'run_2',
            'thread_id': 'thread_2',
            'assistant_id': 'assistant_2',
            'created_at': '2025-02-26T12:00:00Z',
            'updated_at': '2025-02-26T12:00:00Z',
            'status': 'completed',
            'metadata': {'key': 'value2'},
            'kwargs': {},
            'multitask_strategy': 'reject',
          },
        ];

        when(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/runs?limit=10&offset=0'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final results = await client.listStatefulRuns('thread_123');

        expect(results, isA<List<Run>>());
        expect(results.length, equals(2));
        expect(results[0].runId, equals('run_1'));
        expect(results[1].runId, equals('run_2'));

        verify(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/runs?limit=10&offset=0'),
            headers: client.headers,
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/runs?limit=10&offset=0'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        expect(
          () => client.listStatefulRuns('thread_123'),
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

    group('createStatefulBackgroundRun', () {
      test('creates stateful background run successfully', () async {
        final mockResponse = {
          'run_id': 'run_123',
          'thread_id': 'thread_123',
          'assistant_id': 'assistant_123',
          'created_at': '2025-02-26T12:00:00Z',
          'updated_at': '2025-02-26T12:00:00Z',
          'status': 'completed',
          'metadata': {'key': 'value'},
          'kwargs': {},
          'multitask_strategy': 'reject',
        };

        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/runs'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final request = RunCreateStateful(
          assistantId: 'assistant_123',
          input: {'key': 'value'},
        );

        final result = await client.createStatefulBackgroundRun(
          'thread_123',
          request,
        );

        expect(result, isA<Run>());
        expect(result.runId, equals('run_123'));
        expect(result.metadata, equals({'key': 'value'}));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/runs'),
            headers: client.headers,
            body: jsonEncode(request.toJson()),
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/runs'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        final request = RunCreateStateful(assistantId: 'assistant_123');

        expect(
          () => client.createStatefulBackgroundRun('thread_123', request),
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

    group('streamStatefulRun', () {
      test('streams stateful run successfully', () async {
        final mockResponse = http.StreamedResponse(
          Stream.fromIterable([utf8.encode('data: {"key": "value"}\n\n')]),
          200,
        );

        when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

        final request = RunCreateStateful(
          assistantId: 'assistant_123',
          input: {'key': 'value'},
        );

        final stream = client.streamStatefulRun('thread_123', request);

        await expectLater(
          stream,
          emitsInOrder([
            isA<LangGraphMetadataEvent>().having(
              (e) => e.metadata['key'],
              'metadata.key',
              equals('value'),
            ),
          ]),
        );

        verify(mockClient.send(any)).called(1);
      });

      test('throws exception on error', () async {
        final mockResponse = http.StreamedResponse(
          Stream.fromIterable([utf8.encode('Error')]),
          404,
        );

        when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

        final request = RunCreateStateful(assistantId: 'assistant_123');

        expect(
          () => client.streamStatefulRun('thread_123', request).toList(),
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

    group('waitForStatefulRun', () {
      test('waits for stateful run successfully', () async {
        final mockResponse = {
          'run_id': 'run_123',
          'thread_id': 'thread_123',
          'assistant_id': 'assistant_123',
          'created_at': '2025-02-26T12:00:00Z',
          'updated_at': '2025-02-26T12:00:00Z',
          'status': 'completed',
          'metadata': {'key': 'value'},
          'kwargs': {},
          'multitask_strategy': 'reject',
        };

        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/runs/wait'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final request = RunCreateStateful(
          assistantId: 'assistant_123',
          input: {'key': 'value'},
        );

        final result = await client.waitForStatefulRun('thread_123', request);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['run_id'], equals('run_123'));
        expect(result['metadata'], equals({'key': 'value'}));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/runs/wait'),
            headers: client.headers,
            body: jsonEncode(request.toJson()),
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/threads/thread_123/runs/wait'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        final request = RunCreateStateful(assistantId: 'assistant_123');

        expect(
          () => client.waitForStatefulRun('thread_123', request),
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

    group('getStatefulRun', () {
      test('gets stateful run successfully', () async {
        final mockResponse = {
          'run_id': 'run_123',
          'thread_id': 'thread_123',
          'assistant_id': 'assistant_123',
          'created_at': '2025-02-26T12:00:00Z',
          'updated_at': '2025-02-26T12:00:00Z',
          'status': 'completed',
          'metadata': {'key': 'value'},
          'kwargs': {},
          'multitask_strategy': 'reject',
        };

        when(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/runs/run_123'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await client.getStatefulRun('thread_123', 'run_123');

        expect(result, isA<Run>());
        expect(result.runId, equals('run_123'));
        expect(result.metadata, equals({'key': 'value'}));

        verify(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/runs/run_123'),
            headers: client.headers,
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.get(
            Uri.parse('$baseUrl/threads/thread_123/runs/run_123'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        expect(
          () => client.getStatefulRun('thread_123', 'run_123'),
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

    group('cancelStatefulRun', () {
      test('cancels stateful run successfully', () async {
        when(
          mockClient.post(
            Uri.parse(
              '$baseUrl/threads/thread_123/runs/run_123/cancel?wait=false&action=interrupt',
            ),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response('', 200));

        await client.cancelStatefulRun('thread_123', 'run_123');

        verify(
          mockClient.post(
            Uri.parse(
              '$baseUrl/threads/thread_123/runs/run_123/cancel?wait=false&action=interrupt',
            ),
            headers: client.headers,
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.post(
            Uri.parse(
              '$baseUrl/threads/thread_123/runs/run_123/cancel?wait=false&action=interrupt',
            ),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        expect(
          () => client.cancelStatefulRun('thread_123', 'run_123'),
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

    group('deleteStatefulRun', () {
      test('deletes stateful run successfully', () async {
        when(
          mockClient.delete(
            Uri.parse('$baseUrl/threads/thread_123/runs/run_123'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response('', 200));

        await client.deleteStatefulRun('thread_123', 'run_123');

        verify(
          mockClient.delete(
            Uri.parse('$baseUrl/threads/thread_123/runs/run_123'),
            headers: client.headers,
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.delete(
            Uri.parse('$baseUrl/threads/thread_123/runs/run_123'),
            headers: client.headers,
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        expect(
          () => client.deleteStatefulRun('thread_123', 'run_123'),
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
  });
}
