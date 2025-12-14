import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/location_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://nominatim.openstreetmap.org';
  final Map<String, String> _headers = {'User-Agent': 'com.koskita.app/1.0'};

  ApiService() {
    _dio.interceptors.add(LogInterceptor(
      responseBody: true,
      logPrint: (obj) => print("[Dio Log] $obj"),
    ));
  }

  Future<List<Location>> searchHttp(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '10',
      'countrycodes': 'id',
    });

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Location.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mencari (HTTP). Kode: ${response.statusCode}');
    }
  }

  Future<List<Location>> searchDio(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 10,
          'countrycodes': 'id',
        },
        options: Options(headers: _headers),
      );

      List<dynamic> body = response.data;
      return body.map((dynamic item) => Location.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('Kesalahan jaringan (Dio): ${e.message}');
    }
  }

  Future<List<Location>> searchFirstLocation(String query) async {
    return searchDio(query);
  }

  Future<String> reverseGeocode(String lat, String lon) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
          'accept-language': 'id',
        },
        options: Options(headers: _headers),
      );
      return response.data['display_name'] ?? 'Detail alamat tidak ditemukan';
    } on DioException catch (e) {
      throw Exception('Gagal reverse geocode (Dio): ${e.message}');
    }
  }
}
