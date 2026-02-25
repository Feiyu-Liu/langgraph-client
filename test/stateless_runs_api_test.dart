import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:langgraph_client/langgraph_client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'stateless_runs_api_test.mocks.dart';

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

  group('StatelessRunsApi extension', () {
    group('createBackgroundRun', () {
      test('creates background run successfully', () async {
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
            Uri.parse('$baseUrl/runs'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final request = RunCreateStateless(
          assistantId: 'assistant_123',
          input: {'key': 'value'},
        );

        final result = await client.createBackgroundRun(request);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['run_id'], equals('run_123'));
        expect(result['metadata'], equals({'key': 'value'}));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/runs'),
            headers: client.headers,
            body: jsonEncode(request.toJson()),
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/runs'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        final request = RunCreateStateless(assistantId: 'assistant_123');

        expect(
          () => client.createBackgroundRun(request),
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

    group('streamRun', () {
      test('streams run successfully', () async {
        final mockResponse = http.StreamedResponse(
          Stream.fromIterable([utf8.encode('data: {"key": "value"}\n\n')]),
          200,
        );

        when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

        final request = RunCreateStateless(
          assistantId: 'assistant_123',
          input: {'key': 'value'},
        );

        final stream = client.streamRun(request);

        await expectLater(
          stream,
          emitsInOrder([
            isA<LangGraphMetadataEvent>().having(
              (e) => e.metadata['key'],
              'metadata.key',
              equals('value'),
            ),
            emitsDone,
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

        final request = RunCreateStateless(assistantId: 'assistant_123');

        expect(
          () => client.streamRun(request).toList(),
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

    group('waitForRun', () {
      test('waits for run successfully', () async {
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
            Uri.parse('$baseUrl/runs/wait'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final request = RunCreateStateless(
          assistantId: 'assistant_123',
          input: {'key': 'value'},
        );

        final result = await client.waitForRun(request);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['run_id'], equals('run_123'));
        expect(result['metadata'], equals({'key': 'value'}));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/runs/wait'),
            headers: client.headers,
            body: jsonEncode(request.toJson()),
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/runs/wait'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        final request = RunCreateStateless(assistantId: 'assistant_123');

        expect(
          () => client.waitForRun(request),
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

    group('createRunBatch', () {
      test('creates run batch successfully', () async {
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
          mockClient.post(
            Uri.parse('$baseUrl/runs/batch'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final requests = [
          RunCreateStateless(
            assistantId: 'assistant_1',
            input: {'key': 'value1'},
          ),
          RunCreateStateless(
            assistantId: 'assistant_2',
            input: {'key': 'value2'},
          ),
        ];

        final results = await client.createRunBatch(requests);

        expect(results, isA<List<Map<String, dynamic>>>());
        expect(results.length, equals(2));
        expect(results[0]['run_id'], equals('run_1'));
        expect(results[1]['run_id'], equals('run_2'));

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/runs/batch'),
            headers: client.headers,
            body: jsonEncode(requests.map((r) => r.toJson()).toList()),
          ),
        ).called(1);
      });

      test('throws exception on error', () async {
        when(
          mockClient.post(
            Uri.parse('$baseUrl/runs/batch'),
            headers: client.headers,
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        final requests = [
          RunCreateStateless(assistantId: 'assistant_1'),
          RunCreateStateless(assistantId: 'assistant_2'),
        ];

        expect(
          () => client.createRunBatch(requests),
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
