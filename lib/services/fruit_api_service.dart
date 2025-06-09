// API READ
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Gunakan CORS proxy untuk Flutter Web
  static const String baseUrl =
      kIsWeb
          ? 'https://api.allorigins.win/get?url=https://www.fruityvice.com/api/fruit'
          : 'https://www.fruityvice.com/api/fruit';

  static const Duration timeoutDuration = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'Flutter Fruit App v1.0',
  };

  /// Mengambil semua data buah dengan CORS proxy untuk web
  Future<List<dynamic>> fetchFruits() async {
    try {
      debugPrint('🍎 Starting to fetch fruits from API...');
      debugPrint('🌐 Platform: ${kIsWeb ? "Web" : "Mobile"}');

      final String url;
      if (kIsWeb) {
        // Gunakan CORS proxy untuk web
        url =
            'https://api.allorigins.win/get?url=${Uri.encodeComponent('https://www.fruityvice.com/api/fruit/all')}';
      } else {
        url = '$baseUrl/all';
      }

      debugPrint('📡 API URL: $url');

      final client = http.Client();

      try {
        final response = await client
            .get(Uri.parse(url), headers: _headers)
            .timeout(timeoutDuration);

        debugPrint('📊 Response Status: ${response.statusCode}');
        debugPrint(
          '📦 Response Body Length: ${response.body.length} characters',
        );

        if (response.statusCode == 200) {
          if (response.body.isEmpty) {
            throw const FormatException('Empty response from server');
          }

          dynamic jsonData;

          if (kIsWeb) {
            // Parse response dari CORS proxy
            final proxyResponse = json.decode(response.body);
            if (proxyResponse['status']['http_code'] == 200) {
              jsonData = json.decode(proxyResponse['contents']);
            } else {
              throw HttpException(
                'Proxy error: ${proxyResponse['status']['http_code']}',
              );
            }
          } else {
            jsonData = json.decode(response.body);
          }

          if (jsonData is! List) {
            throw FormatException(
              'Expected List but got ${jsonData.runtimeType}',
            );
          }

          final List<dynamic> fruits = jsonData;
          debugPrint('✅ Successfully fetched ${fruits.length} fruits');

          if (fruits.isEmpty) {
            throw Exception('No fruits data received from API');
          }

          if (fruits.isNotEmpty) {
            debugPrint('📋 Sample fruit data: ${fruits.first}');
          }

          return fruits;
        } else {
          debugPrint('❌ Server error: ${response.statusCode}');
          debugPrint('📄 Error response: ${response.body}');
          throw HttpException(
            'Server returned status ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
      } finally {
        client.close();
      }
    } on SocketException catch (e) {
      debugPrint('🔌 Network error: $e');
      throw SocketException(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } on TimeoutException catch (e) {
      debugPrint('⏰ Timeout error: $e');
      throw TimeoutException(
        'Koneksi timeout. Server mungkin sibuk, coba lagi.',
        timeoutDuration,
      );
    } on FormatException catch (e) {
      debugPrint('📋 Format error: $e');
      throw FormatException(
        'Format data dari server tidak valid: ${e.message}',
      );
    } on HttpException catch (e) {
      debugPrint('🌐 HTTP error: $e');
      rethrow;
    } catch (e) {
      debugPrint('💥 Unexpected error: $e');
      throw Exception('Gagal memuat data buah: $e');
    }
  }

  /// Test koneksi dengan fallback ke data dummy jika gagal
  Future<bool> testConnection() async {
    try {
      debugPrint('🔗 Testing API connection...');

      final String testUrl;
      if (kIsWeb) {
        testUrl =
            'https://api.allorigins.win/get?url=${Uri.encodeComponent('https://www.fruityvice.com/api/fruit/banana')}';
      } else {
        testUrl = '$baseUrl/banana';
      }

      final client = http.Client();

      try {
        final response = await client
            .get(Uri.parse(testUrl), headers: _headers)
            .timeout(const Duration(seconds: 10));

        bool isConnected = false;

        if (kIsWeb) {
          if (response.statusCode == 200) {
            final proxyResponse = json.decode(response.body);
            isConnected = proxyResponse['status']['http_code'] == 200;
          }
        } else {
          isConnected = response.statusCode == 200;
        }

        debugPrint(
          '🔗 Connection test result: ${isConnected ? "SUCCESS" : "FAILED"} (${response.statusCode})',
        );
        return isConnected;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('🔗 Connection test failed: $e');
      return false;
    }
  }

  /// Fallback data jika API tidak tersedia
  Future<List<dynamic>> getFallbackData() async {
    debugPrint('📦 Using fallback fruit data...');

    return [
      {
        "name": "Apple",
        "id": 6,
        "family": "Rosaceae",
        "order": "Rosales",
        "genus": "Malus",
        "nutritions": {
          "calories": 52,
          "fat": 0.4,
          "sugar": 10.3,
          "carbohydrates": 11.4,
          "protein": 0.3,
        },
      },
      {
        "name": "Banana",
        "id": 1,
        "family": "Musaceae",
        "order": "Zingiberales",
        "genus": "Musa",
        "nutritions": {
          "calories": 96,
          "fat": 0.2,
          "sugar": 17.2,
          "carbohydrates": 22.0,
          "protein": 1.0,
        },
      },
      {
        "name": "Orange",
        "id": 2,
        "family": "Rutaceae",
        "order": "Sapindales",
        "genus": "Citrus",
        "nutritions": {
          "calories": 43,
          "fat": 0.2,
          "sugar": 8.2,
          "carbohydrates": 8.3,
          "protein": 1.0,
        },
      },
      {
        "name": "Strawberry",
        "id": 3,
        "family": "Rosaceae",
        "order": "Rosales",
        "genus": "Fragaria",
        "nutritions": {
          "calories": 29,
          "fat": 0.4,
          "sugar": 5.4,
          "carbohydrates": 5.5,
          "protein": 0.8,
        },
      },
      {
        "name": "Grape",
        "id": 81,
        "family": "Vitaceae",
        "order": "Vitales",
        "genus": "Vitis",
        "nutritions": {
          "calories": 69,
          "fat": 0.16,
          "sugar": 16.0,
          "carbohydrates": 18.1,
          "protein": 0.72,
        },
      },
      {
        "name": "Mango",
        "id": 27,
        "family": "Anacardiaceae",
        "order": "Sapindales",
        "genus": "Mangifera",
        "nutritions": {
          "calories": 60,
          "fat": 0.38,
          "sugar": 13.7,
          "carbohydrates": 15.0,
          "protein": 0.82,
        },
      },
      {
        "name": "Pineapple",
        "id": 10,
        "family": "Bromeliaceae",
        "order": "Poales",
        "genus": "Ananas",
        "nutritions": {
          "calories": 50,
          "fat": 0.12,
          "sugar": 9.85,
          "carbohydrates": 13.12,
          "protein": 0.54,
        },
      },
      {
        "name": "Watermelon",
        "id": 25,
        "family": "Cucurbitaceae",
        "order": "Cucurbitales",
        "genus": "Citrullus",
        "nutritions": {
          "calories": 30,
          "fat": 0.2,
          "sugar": 6.0,
          "carbohydrates": 8.0,
          "protein": 0.6,
        },
      },
    ];
  }

  /// Method dengan retry dan fallback
  Future<List<dynamic>> fetchFruitsWithFallback({int maxRetries = 2}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        debugPrint('🔄 Attempt $attempts of $maxRetries');

        final result = await fetchFruits();
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('❌ Attempt $attempts failed: $e');

        if (attempts < maxRetries) {
          final waitTime = Duration(seconds: attempts * 2);
          debugPrint('⏳ Waiting ${waitTime.inSeconds} seconds before retry...');
          await Future.delayed(waitTime);
        }
      }
    }

    // Jika semua attempt gagal, gunakan fallback data
    debugPrint('🔄 All API attempts failed, using fallback data...');
    return await getFallbackData();
  }

  /// Method untuk debugging
  Future<Map<String, dynamic>> checkApiStatus() async {
    final Map<String, dynamic> status = {
      'isAvailable': false,
      'responseTime': 0,
      'error': null,
      'sampleData': null,
      'statusCode': null,
      'platform': kIsWeb ? 'Web' : 'Mobile',
      'usingProxy': kIsWeb,
    };

    try {
      final stopwatch = Stopwatch()..start();

      final String testUrl;
      if (kIsWeb) {
        testUrl =
            'https://api.allorigins.win/get?url=${Uri.encodeComponent('https://www.fruityvice.com/api/fruit/all')}';
      } else {
        testUrl = '$baseUrl/all';
      }

      final client = http.Client();

      try {
        final response = await client
            .get(Uri.parse(testUrl), headers: _headers)
            .timeout(const Duration(seconds: 15));

        stopwatch.stop();

        status['responseTime'] = stopwatch.elapsedMilliseconds;
        status['statusCode'] = response.statusCode;

        if (kIsWeb) {
          if (response.statusCode == 200) {
            final proxyResponse = json.decode(response.body);
            final proxyStatusCode = proxyResponse['status']['http_code'];
            status['proxyStatusCode'] = proxyStatusCode;
            status['isAvailable'] = proxyStatusCode == 200;

            if (proxyStatusCode == 200) {
              final jsonData = json.decode(proxyResponse['contents']);
              status['sampleData'] =
                  jsonData is List && jsonData.isNotEmpty
                      ? jsonData.first
                      : null;
              status['dataCount'] = jsonData is List ? jsonData.length : 0;
            } else {
              status['error'] = 'Proxy HTTP $proxyStatusCode';
            }
          } else {
            status['error'] =
                'HTTP ${response.statusCode}: ${response.reasonPhrase}';
          }
        } else {
          status['isAvailable'] = response.statusCode == 200;
          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            status['sampleData'] =
                jsonData is List && jsonData.isNotEmpty ? jsonData.first : null;
            status['dataCount'] = jsonData is List ? jsonData.length : 0;
          } else {
            status['error'] =
                'HTTP ${response.statusCode}: ${response.reasonPhrase}';
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      status['error'] = e.toString();
    }

    return status;
  }
}
