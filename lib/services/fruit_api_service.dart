import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fruit_model.dart';

const String baseUrl = "https://www.fruityvice.com/api/fruit/all"; // Pastikan URL ini benar

class ApiService {
  static Future<List<FruitModel>> fetchData(String brand) async {
    // Membuat URL dengan parameter 'brand'
    final response = await http.get(Uri.parse('$baseUrl?brand=$brand'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);

      // Mengonversi JSON menjadi list objek ContentModel
      return jsonResponse.map((item) => FruitModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
