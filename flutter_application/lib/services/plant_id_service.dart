import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/plant_identification.dart';

class PlantIdException implements Exception {
  final String message;
  PlantIdException(this.message);

  @override
  String toString() => message;
}

class PlantIdService {
  static const String _baseUrl = 'https://plant.id/api/v3/identification';
  static const List<String> _details = [
    'common_names',
    'url',
    'description',
    'description_all',
    'taxonomy',
    'edible_parts',
    'best_watering',
    'best_light_condition',
    'best_soil_type',
    'toxicity',
    'cultural_significance',
  ];

  /// Reads PLANT_API_KEY from the loaded .env file — same source
  /// UsageService uses, so there's a single place your key lives.
  static String get _apiKey {
    final key = dotenv.env['PLANT_API_KEY'];
    if (key == null || key.isEmpty) {
      throw PlantIdException(
        'API key not found. Make sure your .env file exists and '
        'dotenv.load() ran before this call.',
      );
    }
    return key;
  }

  Future<PlantIdentification> identify(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'details': _details.join(','),
    });

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': _apiKey,
        },
        body: jsonEncode({
          'images': [base64Image],
          'similar_images': true,
        }),
      );
    } on SocketException {
      throw PlantIdException(
          'No internet connection. Please check your network and try again.');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        final Map<String, dynamic> body = jsonDecode(response.body);
        return PlantIdentification.fromApiResponse(body);
      case 400:
        throw PlantIdException(
            'The image could not be processed. Please try a clearer photo.');
      case 401:
        throw PlantIdException(
            'Invalid API key. Please check your Plant.id API key.');
      case 429:
        throw PlantIdException(
            'Identification credits exhausted. Please try again later.');
      default:
        throw PlantIdException(
            'Something went wrong (code ${response.statusCode}). Please try again.');
    }
  }

  /// Re-fetches a past identification by its access_token, using
  /// Kindwise's "Retrieve identification" GET endpoint. Results stay
  /// available for 6 months after the original scan.
  Future<PlantIdentification> retrieveIdentification(
    String accessToken, {
    List<String>? details,
  }) async {
    final uri = Uri.parse('$_baseUrl/$accessToken').replace(
      queryParameters: {
        'details': (details ?? _details).join(','),
      },
    );

    http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': _apiKey,
        },
      );
    } on SocketException {
      throw PlantIdException(
          'No internet connection. Please check your network and try again.');
    }

    switch (response.statusCode) {
      case 200:
        final Map<String, dynamic> body = jsonDecode(response.body);
        return PlantIdentification.fromApiResponse(body);
      case 404:
        throw PlantIdException(
            'This scan is no longer available (results expire after 6 months).');
      case 401:
        throw PlantIdException(
            'Invalid API key. Please check your Plant.id API key.');
      default:
        throw PlantIdException(
            'Something went wrong (code ${response.statusCode}). Please try again.');
    }
  }
}