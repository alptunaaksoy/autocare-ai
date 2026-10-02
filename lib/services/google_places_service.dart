import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_keys.dart';

class GooglePlacesService {
  Future<List<dynamic>> getNearbyServices({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        'https://places.googleapis.com/v1/places:searchNearby',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': ApiKeys.googleMapsApiKey,
          'X-Goog-FieldMask':
              'places.displayName,places.formattedAddress,places.rating',
        },
        body: jsonEncode({
          'includedTypes': ['car_repair'],
          'maxResultCount': 10,
          'locationRestriction': {
            'circle': {
              'center': {
                'latitude': latitude,
                'longitude': longitude,
              },
              'radius': 5000.0,
            },
          },
        }),
      );

      final data = jsonDecode(response.body);
      print('GOOGLE PLACES RESPONSE: $data');

      if (response.statusCode == 200) {
        return data['places'] ?? [];
      }

      return [];
    } catch (e) {
      print('GOOGLE PLACES ERROR: $e');
      return [];
    }
  }
}