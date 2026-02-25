import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sse_stream/sse_stream.dart';

import 'client.dart';
import '../models/run.dart';
import '../streaming/streaming.dart';

extension ThreadRunsApi on LangGraphClient {
  Future<List<Run>> listStatefulRuns(
    String threadId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final response = await client.get(
        Uri.parse(
          '$baseUrl/threads/$threadId/runs',
        ).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Run.fromJson(json)).toList();
      }
      throw LangGraphApiException('Failed to list runs', response.statusCode);
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to list runs: $e');
    }
  }

  /// Create a run in existing thread, return the run ID immediately. Don't wait for the final run output.
  Future<Run> createStatefulBackgroundRun(
    String threadId,
    RunCreateStateful request,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/threads/$threadId/runs'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Run.fromJson(jsonDecode(response.body));
      }
      throw LangGraphApiException(
        'Failed to create background run',
        response.statusCode,
      );
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to create background run: $e');
    }
  }

  /// Create a run in existing thread and stream structured events.
  Stream<LangGraphStreamEvent> streamStatefulRun(
    String threadId,
    RunCreateStateful request,
  ) async* {
    try {
      final req =
          http.Request(
              'POST',
              Uri.parse('$baseUrl/threads/$threadId/runs/stream'),
            )
            ..headers.addAll(headers)
            ..body = jsonEncode(request.toJson());

      final response = await client.send(req);

      if (response.statusCode == 200) {
        final rawEvents = response.stream
            .transform(utf8.decoder)
            .transform(const SseEventTransformer());
        yield* parseLangGraphEventStream(rawEvents);
      } else {
        throw LangGraphApiException(
          'Failed to stream run',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to stream run: $e');
    }
  }

  /// High-level conversation stream for a stateful run.
  Stream<ConversationStreamEvent> runStatefulConversationStream(
    String threadId,
    RunCreateStateful request,
  ) {
    return toConversationStreamEvents(streamStatefulRun(threadId, request));
  }

  /// Create a run in existing thread. Wait for the final output and then return it.
  Future<Map<String, dynamic>> waitForStatefulRun(
    String threadId,
    RunCreateStateful request,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/threads/$threadId/runs/wait'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw LangGraphApiException(
        'Failed to wait for run',
        response.statusCode,
      );
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to wait for run: $e');
    }
  }

  /// Get a run by ID.
  Future<Run> getStatefulRun(String threadId, String runId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/threads/$threadId/runs/$runId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Run.fromJson(jsonDecode(response.body));
      }
      throw LangGraphApiException('Failed to get run', response.statusCode);
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to get run: $e');
    }
  }

  Future<void> cancelStatefulRun(
    String threadId,
    String runId, {
    bool wait = false,
    String action = 'interrupt',
  }) async {
    try {
      final queryParams = {'wait': wait.toString(), 'action': action};

      final response = await client.post(
        Uri.parse(
          '$baseUrl/threads/$threadId/runs/$runId/cancel',
        ).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw LangGraphApiException(
          'Failed to cancel run',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to cancel run: $e');
    }
  }

  Future<void> deleteStatefulRun(String threadId, String runId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/threads/$threadId/runs/$runId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw LangGraphApiException(
          'Failed to delete run',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to delete run: $e');
    }
  }

  /// Joins an existing streaming run to continue receiving events.
  ///
  /// This allows reconnecting to a run that is already in progress and
  /// was originally created with streaming enabled.
  ///
  /// [threadId] is the ID of the thread the run belongs to.
  /// [runId] is the ID of the run to join.
  ///
  /// Returns a stream of structured events from the run.
  /// Throws [LangGraphApiException] if the request fails.
  Stream<LangGraphStreamEvent> joinStatefulRunStream(
    String threadId,
    String runId,
  ) async* {
    try {
      final req = http.Request(
        'GET',
        Uri.parse('$baseUrl/threads/$threadId/runs/$runId/join'),
      )..headers.addAll(headers);

      final response = await client.send(req);

      if (response.statusCode == 200) {
        final rawEvents = response.stream
            .transform(utf8.decoder)
            .transform(const SseEventTransformer());
        yield* parseLangGraphEventStream(rawEvents);
      } else {
        throw LangGraphApiException(
          'Failed to join run stream',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to join run stream: $e');
    }
  }

  /// High-level conversation stream for joining an in-progress run.
  Stream<ConversationStreamEvent> joinStatefulConversationStream(
    String threadId,
    String runId,
  ) {
    return toConversationStreamEvents(joinStatefulRunStream(threadId, runId));
  }

  /// Streams an existing run from the beginning.
  ///
  /// This replays all events for an existing run from the start.
  ///
  /// [threadId] is the ID of the thread the run belongs to.
  /// [runId] is the ID of the run to stream.
  ///
  /// Returns a stream of structured events from the run.
  /// Throws [LangGraphApiException] if the request fails.
  Stream<LangGraphStreamEvent> streamExistingStatefulRun(
    String threadId,
    String runId,
  ) async* {
    try {
      final req = http.Request(
        'GET',
        Uri.parse('$baseUrl/threads/$threadId/runs/$runId/stream'),
      )..headers.addAll(headers);

      final response = await client.send(req);

      if (response.statusCode == 200) {
        final rawEvents = response.stream
            .transform(utf8.decoder)
            .transform(const SseEventTransformer());
        yield* parseLangGraphEventStream(rawEvents);
      } else {
        throw LangGraphApiException(
          'Failed to stream existing run',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Failed to stream existing run: $e');
    }
  }

  /// High-level conversation stream for replaying a historical run.
  Stream<ConversationStreamEvent> streamExistingStatefulConversation(
    String threadId,
    String runId,
  ) {
    return toConversationStreamEvents(
      streamExistingStatefulRun(threadId, runId),
    );
  }
}
