import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class UserAuthApi {
  static bool isSuccessfulResponse({
    required int statusCode,
    required dynamic responseBody,
    bool requireBodySuccess = false,
  }) {
    if (statusCode < 200 || statusCode >= 300) {
      return false;
    }

    if (!requireBodySuccess) {
      return true;
    }

    if (responseBody is! Map<String, dynamic>) {
      return false;
    }

    final successValue = responseBody['success'];
    if (successValue is bool) {
      return successValue;
    }

    if (successValue is String) {
      final normalized = successValue.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }

    return true;
  }

  static Future<http.Response> _postWithFallback(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final errors = <String>[];
    http.Response? lastServerErrorResponse;
    final hosts = apiBaseUrls;

    for (final baseUrl in hosts) {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('Auth request attempting: $url');
      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 4));

        debugPrint('Auth request completed: $url (${response.statusCode})');

        if (response.statusCode < 500) {
          setWorkingBaseUrl(baseUrl);
          return response;
        }

        lastServerErrorResponse = response;
        final msg = '[$url] HTTP ${response.statusCode} ${response.body}';
        errors.add(msg);
        debugPrint('Auth request server error: $msg');
      } catch (e) {
        final msg = '[$url] $e';
        errors.add(msg);
        debugPrint('Auth request failed for $url: $e');
      }
    }

    if (lastServerErrorResponse != null) {
      return lastServerErrorResponse;
    }

    throw Exception(
      'Unable to reach backend on any configured host. Tried: ${errors.join(' | ')}',
    );
  }

  //======================================================================
  // REGISTER USER
  //======================================================================
  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    debugPrint('Registering user: $email to $apiBaseUrl/register/');

    try {
      final response = await _postWithFallback('/register/', {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      });

      final responseBody = _parseResponseBody(response.body);
      debugPrint('Register response: ${response.statusCode} $responseBody');

      if (isSuccessfulResponse(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requireBodySuccess: true,
      )) {
        return {
          'success': true,
          'message': responseBody is Map<String, dynamic>
              ? responseBody['message'] ??
                    responseBody['success'] ??
                    'User registered successfully'
              : 'User registered successfully',
          'data': responseBody,
        };
      }

      return {'success': false, 'errors': _extractErrors(responseBody)};
    } catch (e) {
      debugPrint('Register error: $e');
      return {
        'success': false,
        'message':
            'Unable to reach the server. Please check your backend and network connection.',
        'error': e.toString(),
      };
    }
  }

  //======================================================================
  // LOGIN USER
  //======================================================================
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    debugPrint('Logging in user: $email to $apiBaseUrl/login/');

    try {
      final response = await _postWithFallback('/login/', {
        'email': email,
        'password': password,
      });

      final responseBody = _parseResponseBody(response.body);
      debugPrint('Login response: ${response.statusCode} $responseBody');

      if (isSuccessfulResponse(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requireBodySuccess: true,
      )) {
        return {
          'success': true,
          'user': responseBody is Map<String, dynamic>
              ? responseBody['user']
              : null,
        };
      }

      return {'success': false, 'errors': _extractErrors(responseBody)};
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'success': false,
        'message':
            'Unable to reach the server. Please check your backend and network connection.',
        'error': e.toString(),
      };
    }
  }

  //======================================================================
  // UPDATE USER ACCOUNT
  //======================================================================
  static Future<Map<String, dynamic>> updateUserAccount({
    int? userId,
    required String firstName,
    required String lastName,
    required String email,
    String? newEmail,
    String? currentPassword,
    String? newPassword,
  }) async {
    debugPrint('Updating user account: $email');

    try {
      final payload = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      if (userId != null && userId > 0) {
        payload['userId'] = userId;
      }
      if (newEmail != null && newEmail.isNotEmpty && newEmail != email) {
        payload['new_email'] = newEmail;
      }
      if (currentPassword != null && currentPassword.isNotEmpty) {
        payload['current_password'] = currentPassword;
      }
      if (newPassword != null && newPassword.isNotEmpty) {
        payload['new_password'] = newPassword;
      }

      final response = await _postWithFallback('/update-account/', payload);
      final responseBody = _parseResponseBody(response.body);
      debugPrint('Update account response: ${response.statusCode} $responseBody');

      if (isSuccessfulResponse(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requireBodySuccess: true,
      )) {
        return {
          'success': true,
          'message': responseBody is Map<String, dynamic>
              ? responseBody['message'] ?? 'Account details updated successfully'
              : 'Account details updated successfully',
          'user': responseBody is Map<String, dynamic>
              ? responseBody['user']
              : null,
        };
      }

      return {'success': false, 'errors': _extractErrors(responseBody)};
    } catch (e) {
      debugPrint('Update account error: $e');
      return {
        'success': false,
        'message':
            'Unable to reach the server. Please check your backend and network connection.',
        'error': e.toString(),
      };
    }
  }

  static dynamic _parseResponseBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  /// Django wraps validation messages in an `errors` object.  Return that
  /// object directly so the sign-up and login screens can show each message.
  static Map<String, dynamic> _extractErrors(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      final nestedErrors = responseBody['errors'];
      if (nestedErrors is Map<String, dynamic>) {
        return nestedErrors;
      }
      return responseBody;
    }

    return {'error': responseBody.toString()};
  }
}
