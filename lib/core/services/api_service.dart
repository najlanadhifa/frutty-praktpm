import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../views/fruit/fruit_list_page.dart'; // import model Fruit

class ApiService {
  static const String baseUrl = 'https://www.fruityvice.com/api/fruit';

  // Ambil daftar semua buah
  Future<List<Fruit>> fetchAllFruits() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Fruit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load fruits');
    }
  }
}
