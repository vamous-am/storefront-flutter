import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';


class ApiClient {
  ApiClient({http.Client? httpClient, Duration? timeout})
    : _httpClient = httpClient ?? http.Client(),
      _timeout = timeout ?? ApiConstants.requestTimeout;

  final http.Client _httpClient;
  final Duration _timeout;

  Future<Map<String, dynamic>> getJsonMap(String path) async {
    final response = await _get(path);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response format from server.');
    }
    return decoded;
  }

  Future<List<dynamic>> getJsonList(String path) async {
    final response = await _get(path);
    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const ApiException('Unexpected response format from server.');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _post(path, body);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response format from server.');
    }
    return decoded;
  }

  Future<http.Response> _get(String path) async {
    try {
      final response = await _httpClient.get(_uri(path)).timeout(_timeout);
      _throwIfFailure(response);
      return response;
    } catch (error) {
      throw _mapError(error);
    }
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _httpClient
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      _throwIfFailure(response);
      return response;
    } catch (error) {
      throw _mapError(error);
    }
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConstants.baseUrl}$normalizedPath');
  }

  void _throwIfFailure(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 401) {
      throw const AuthException('Invalid username or password.');
    }

    if (response.statusCode >= 500) {
      throw const ServerException('Server error. Please try again later.');
    }

    throw ApiException('Request failed with status ${response.statusCode}.');
  }

  AppException _mapError(Object error) {
    if (error is AppException) {
      return error;
    }
    if (error is SocketException) {
      return const NetworkException('No internet connection.');
    }
    if (error is TimeoutException) {
      return const TimeoutAppException('Server took too long to respond.');
    }
    if (error is FormatException) {
      return const ApiException('Failed to parse server response.');
    }
    return const ApiException('Unexpected error while processing request.');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

