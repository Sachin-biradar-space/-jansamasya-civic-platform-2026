import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/report.dart';
import '../models/user.dart';

/// Base exception thrown when an API call fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when the backend rejects a request with HTTP 401 (expired/invalid token).
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}

/// Result returned by successful authentication requests (`login` and `signup`).
class AuthResponse {
  final User user;
  final String token;

  const AuthResponse({required this.user, required this.token});
}

/// Service handling all REST API communication with the existing JanSamasya
/// Node.js + Express backend.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Decodes a JSON response body safely into a Map, falling back to an empty map.
  Map<String, dynamic> _tryDecodeJsonMap(String body) {
    if (body.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } on FormatException {
      return {};
    }
  }

  /// Evaluates non-success HTTP status codes and throws a typed [ApiException].
  Never _throwForErrorResponse(int statusCode, String body) {
    final data = _tryDecodeJsonMap(body);
    final message = (data['message'] ?? data['error'] ?? '').toString().trim();

    if (statusCode == 401) {
      throw UnauthorizedException(
        message.isNotEmpty
            ? message
            : 'Session expired or invalid token. Please log in again.',
      );
    }

    throw ApiException(
      message.isNotEmpty
          ? message
          : 'Request failed with status code $statusCode.',
      statusCode: statusCode,
    );
  }

  /// Wraps network execution to surface readable connectivity/timeout errors.
  Future<T> _executeRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'Cannot connect to the JanSamasya server. Check your network and verify the backend is running.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Connection timed out. Please verify the backend server is reachable.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Network error occurred while communicating with the server.',
      );
    }
  }

  /// Registers a new citizen account via `POST /api/auth/signup`.
  ///
  /// Matches `backend/controllers/authController.js`:
  /// Required fields: `username`, `email`, `password`, `role`, `state`.
  /// Optional field: `area`.
  Future<AuthResponse> signup({
    required String username,
    required String email,
    required String password,
    required String state,
    String? area,
  }) async {
    return _executeRequest(() async {
      final payload = <String, dynamic>{
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'role': 'user',
        'state': state.trim().toLowerCase(),
        if (area != null && area.trim().isNotEmpty) 'area': area.trim(),
      };

      final response = await _client
          .post(
            Uri.parse(ApiConfig.signupUrl),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              HttpHeaders.acceptHeader: 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _tryDecodeJsonMap(response.body);
        final token = (data['token'] ?? '').toString();
        final userMap = data['user'];

        if (token.isEmpty || userMap is! Map<String, dynamic>) {
          throw const ApiException('Unexpected signup response from server.');
        }

        return AuthResponse(user: User.fromJson(userMap), token: token);
      }

      _throwForErrorResponse(response.statusCode, response.body);
    });
  }

  /// Authenticates a citizen account via `POST /api/auth/login`.
  ///
  /// Matches `backend/controllers/authController.js`:
  /// Expects `username`, `password`, and `role: 'user'`.
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    return _executeRequest(() async {
      final payload = <String, dynamic>{
        'username': username.trim(),
        'password': password,
        'role': 'user',
      };

      final response = await _client
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              HttpHeaders.acceptHeader: 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = _tryDecodeJsonMap(response.body);
        final token = (data['token'] ?? '').toString();
        final userMap = data['user'];

        if (token.isEmpty || userMap is! Map<String, dynamic>) {
          throw const ApiException('Unexpected login response from server.');
        }

        return AuthResponse(user: User.fromJson(userMap), token: token);
      }

      _throwForErrorResponse(response.statusCode, response.body);
    });
  }

  /// Fetches the authenticated citizen's profile via `GET /api/user/profile`.
  ///
  /// Matches `backend/controllers/userController.js` (`getUserProfile`).
  Future<User> getProfile(String token) async {
    return _executeRequest(() async {
      final response = await _client
          .get(
            Uri.parse(ApiConfig.profileUrl),
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $token',
              HttpHeaders.acceptHeader: 'application/json',
            },
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = _tryDecodeJsonMap(response.body);
        final userMap = data['user'];
        if (userMap is! Map<String, dynamic>) {
          throw const ApiException('Unexpected profile response from server.');
        }
        return User.fromJson(userMap);
      }

      _throwForErrorResponse(response.statusCode, response.body);
    });
  }

  /// Submits a civic report via `POST /api/user/report` using `multipart/form-data`.
  ///
  /// Matches `backend/routes/userRoutes.js` (`upload.single('image')`) and
  /// `backend/controllers/userController.js` (`createReport`).
  Future<Report> createReport({
    required String token,
    required String title,
    required String description,
    required String category,
    File? imageFile,
  }) async {
    return _executeRequest(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.createReportUrl),
      );

      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      request.headers[HttpHeaders.acceptHeader] = 'application/json';

      request.fields['title'] = title.trim();
      request.fields['description'] = description.trim();
      request.fields['category'] = category.trim();

      if (imageFile != null) {
        final mediaType = _resolveImageMediaType(imageFile.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      }

      final streamedResponse = await _client
          .send(request)
          .timeout(ApiConfig.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _tryDecodeJsonMap(response.body);
        final reportMap = data['report'];
        if (reportMap is! Map<String, dynamic>) {
          throw const ApiException(
            'Report submitted, but server response format was unexpected.',
          );
        }
        return Report.fromJson(reportMap);
      }

      _throwForErrorResponse(response.statusCode, response.body);
    });
  }

  /// Retrieves all civic reports filed by the logged-in citizen via
  /// `GET /api/user/my-reports`.
  Future<List<Report>> getMyReports(String token) async {
    return _executeRequest(() async {
      final response = await _client
          .get(
            Uri.parse(ApiConfig.myReportsUrl),
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $token',
              HttpHeaders.acceptHeader: 'application/json',
            },
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = _tryDecodeJsonMap(response.body);
        final rawList = data['reports'];
        if (rawList is! List) {
          return [];
        }
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(Report.fromJson)
            .toList();
      }

      _throwForErrorResponse(response.statusCode, response.body);
    });
  }

  /// Resolves an explicit image MIME type matching Multer's `/jpeg|jpg|png/` filter.
  MediaType _resolveImageMediaType(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    throw const ApiException(
      'Only .jpg, .jpeg, and .png image files are supported by the server.',
    );
  }
}
