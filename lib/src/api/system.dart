import 'dart:convert';

import 'client.dart';

/// System API Extension
///
/// Provides system-level endpoints like health checks.
extension SystemApi on LangGraphClient {
  /// Checks the health status of the server.
  ///
  /// Optionally checks database connectivity.
  ///
  /// [checkDb] specifies whether to check database connectivity.
  /// - `false` (default): Only checks server health
  /// - `true`: Also checks database connectivity
  ///
  /// Returns a [HealthResponse] containing the health status.
  /// Throws [LangGraphApiException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final client = LangGraphClient(baseUrl: 'http://localhost:2024');
  ///
  /// // Basic health check
  /// final health = await client.healthCheck();
  /// print('Server healthy: ${health.ok}');
  ///
  /// // Health check with database
  /// final healthWithDb = await client.healthCheck(checkDb: true);
  /// print('Server and DB healthy: ${healthWithDb.ok}');
  /// ```
  Future<HealthResponse> healthCheck({bool checkDb = false}) async {
    try {
      final queryParams = {'check_db': checkDb ? '1' : '0'};
      final response = await client.get(
        Uri.parse('$baseUrl/ok').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return HealthResponse.fromJson(data);
      }
      throw LangGraphApiException(
        'Health check failed',
        response.statusCode,
      );
    } catch (e) {
      if (e is LangGraphApiException) rethrow;
      throw LangGraphApiException('Health check failed: $e');
    }
  }
}

/// Health check response model.
///
/// Indicates the health status of the server and optionally the database.
class HealthResponse {
  /// Indicates whether the server (and optionally database) is healthy.
  final bool ok;

  const HealthResponse({required this.ok});

  /// Creates a [HealthResponse] from JSON data.
  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      ok: json['ok'] as bool? ?? false,
    );
  }

  /// Converts this [HealthResponse] to JSON.
  Map<String, dynamic> toJson() {
    return {'ok': ok};
  }

  @override
  String toString() => 'HealthResponse(ok: $ok)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthResponse && other.ok == ok;
  }

  @override
  int get hashCode => ok.hashCode;
}
