import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/plant_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlantNet API Service
// ─────────────────────────────────────────────────────────────────────────────

class PlantNetService {
  static const String _baseUrl = 'https://my-api.plantnet.org/v2/identify';
  static const String _project = 'all'; // or a specific flora project key

  final String apiKey;

  PlantNetService({required this.apiKey});

  /// Identifies plant from a list of [ImageEntry] objects (max 5).
  /// Returns a [PlantNetResponse] or throws a [PlantNetException].
  Future<PlantNetResponse> identify(
    List<ImageEntry> images, {
    String language = 'en',
    bool includeRelatedImages = false,
  }) async {
    if (images.isEmpty || images.length > 5) {
      throw PlantNetException(
        'You must provide between 1 and 5 images.',
        type: PlantNetErrorType.validation,
      );
    }

    final uri = Uri.parse(
      '$_baseUrl/$_project'
      '?api-key=$apiKey'
      '&lang=$language'
      '&include-related-images=$includeRelatedImages',
    );

    final request = http.MultipartRequest('POST', uri);

    for (final entry in images) {
      final file = File(entry.filePath);
      if (!file.existsSync()) {
        throw PlantNetException(
          'Image file not found: ${entry.filePath}',
          type: PlantNetErrorType.validation,
        );
      }

      request.files.add(await http.MultipartFile.fromPath(
        'images',
        entry.filePath,
      ));
      request.fields['organs'] = entry.organ.label;
    }

    try {
      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw PlantNetException(
          'Request timed out. Please try again.',
          type: PlantNetErrorType.timeout,
        ),
      );

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PlantNetResponse.fromJson(json);
      }

      _handleHttpError(response.statusCode, response.body);
      throw PlantNetException('Unexpected error', type: PlantNetErrorType.unknown);
    } on PlantNetException {
      rethrow;
    } on SocketException {
      throw PlantNetException(
        'No internet connection. Check your network and try again.',
        type: PlantNetErrorType.network,
      );
    } catch (e) {
      throw PlantNetException(
        'An unexpected error occurred: $e',
        type: PlantNetErrorType.unknown,
      );
    }
  }

  void _handleHttpError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        throw PlantNetException(
          'Invalid request. Ensure your images are valid.',
          type: PlantNetErrorType.badRequest,
          statusCode: statusCode,
        );
      case 401:
        throw PlantNetException(
          'Invalid API key. Check your Pl@ntNet API key.',
          type: PlantNetErrorType.unauthorized,
          statusCode: statusCode,
        );
      case 404:
        throw PlantNetException(
          'No matching plants found. Try a clearer image.',
          type: PlantNetErrorType.notFound,
          statusCode: statusCode,
        );
      case 429:
        throw PlantNetException(
          'You\'ve reached your daily identification limit.',
          type: PlantNetErrorType.rateLimited,
          statusCode: statusCode,
        );
      case 500:
      case 503:
        throw PlantNetException(
          'Pl@ntNet service is temporarily unavailable. Try again later.',
          type: PlantNetErrorType.serverError,
          statusCode: statusCode,
        );
      default:
        throw PlantNetException(
          'Server error ($statusCode). Try again.',
          type: PlantNetErrorType.unknown,
          statusCode: statusCode,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exception Types
// ─────────────────────────────────────────────────────────────────────────────

enum PlantNetErrorType {
  validation,
  network,
  timeout,
  unauthorized,
  badRequest,
  notFound,
  rateLimited,
  serverError,
  unknown,
}

class PlantNetException implements Exception {
  final String message;
  final PlantNetErrorType type;
  final int? statusCode;

  const PlantNetException(
    this.message, {
    required this.type,
    this.statusCode,
  });

  @override
  String toString() => 'PlantNetException(${type.name}): $message';

  /// User-facing error title
  String get title {
    switch (type) {
      case PlantNetErrorType.network:      return 'No Connection';
      case PlantNetErrorType.timeout:      return 'Timed Out';
      case PlantNetErrorType.unauthorized: return 'API Key Error';
      case PlantNetErrorType.notFound:     return 'Plant Not Found';
      case PlantNetErrorType.rateLimited:  return 'Daily Limit Reached';
      case PlantNetErrorType.serverError:  return 'Service Unavailable';
      default:                             return 'Identification Failed';
    }
  }
}
