import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fruit_model.dart';

const String baseUrl = "https://www.fruityvice.com/api/fruit/all";

class ApiService {
  // Map untuk menyimpan harga buah yang Anda tentukan sendiri
  static final Map<String, int> _fruitPrices = {
    'Apple': 8000,
    'Apricot': 15000,
    'Avocado': 12000,
    'Banana': 5000,
    'Blackberry': 25000,
    'Blueberry': 30000,
    'Cherry': 20000,
    'Coconut': 10000,
    'Cranberry': 18000,
    'Cucumber': 7000,
    'Currant': 22000,
    'Dragon Fruit': 35000,
    'Durian': 40000,
    'Elderberry': 28000,
    'Feijoa': 16000,
    'Fig': 14000,
    'Gooseberry': 19000,
    'Grape': 13000,
    'GreenApple': 9000,
    'Guava': 11000,
    'Kiwi': 17000,
    'Lemon': 6000,
    'Lime': 7500,
    'Lychee': 24000,
    'Mango': 12000,
    'Melon': 8500,
    'Orange': 9500,
    'Papaya': 10500,
    'Passion Fruit': 32000,
    'Peach': 15500,
    'Pear': 11500,
    'Persimmon': 21000,
    'Pineapple': 13500,
    'Plum': 16500,
    'Pomegranate': 26000,
    'Raspberry': 27000,
    'Strawberry': 18500,
    'Tangerine': 10000,
    'Tomato': 5500,
    'Watermelon': 6500,
  };

  // Map untuk URL gambar buah yang lebih reliable
  static final Map<String, String> _fruitImages = {
    'Apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=400&fit=crop',
    'Apricot': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Avocado': 'https://images.unsplash.com/photo-1583171542089-0160647b2fe9?w=400&h=400&fit=crop',
    'Banana': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Blackberry': 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=400&h=400&fit=crop',
    'Blueberry': 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=400&h=400&fit=crop',
    'Cherry': 'https://images.unsplash.com/photo-1528821128474-27f963b062bf?w=400&h=400&fit=crop',
    'Coconut': 'https://images.unsplash.com/photo-1520637836862-4d197d17c60a?w=400&h=400&fit=crop',
    'Cranberry': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Cucumber': 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=400&h=400&fit=crop',
    'Dragon Fruit': 'https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=400&h=400&fit=crop',
    'Durian': 'https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=400&h=400&fit=crop',
    'Fig': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Grape': 'https://images.unsplash.com/photo-1537640538966-79f369143ea8?w=400&h=400&fit=crop',
    'GreenApple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=400&fit=crop',
    'Guava': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Kiwi': 'https://images.unsplash.com/photo-1585059895524-72359e06133a?w=400&h=400&fit=crop',
    'Lemon': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
    'Lime': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
    'Lychee': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Mango': 'https://images.unsplash.com/photo-1553279293-d726e752fc7e?w=400&h=400&fit=crop',
    'Melon': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Orange': 'https://images.unsplash.com/photo-1580052614034-c55d20bfee3b?w=400&h=400&fit=crop',
    'Papaya': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Passion Fruit': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Peach': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Pear': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Persimmon': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Pineapple': 'https://images.unsplash.com/photo-1550828520-4cb496926fc8?w=400&h=400&fit=crop',
    'Plum': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Pomegranate': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    'Raspberry': 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=400&h=400&fit=crop',
    'Strawberry': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400&h=400&fit=crop',
    'Tangerine': 'https://images.unsplash.com/photo-1580052614034-c55d20bfee3b?w=400&h=400&fit=crop',
    'Tomato': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&h=400&fit=crop',
    'Watermelon': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
  };

  static Future<List<Fruit>> fetchFruits() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        return jsonResponse.map((item) {
          Map<String, dynamic> modifiedItem = Map<String, dynamic>.from(item);
          
          String fruitName = item['name'] as String;
          
          // Set harga berdasarkan map yang sudah ditentukan
          modifiedItem['harga'] = _fruitPrices[fruitName] ?? 10000;
          
          // Set gambar berdasarkan map yang sudah ditentukan
          modifiedItem['gambar'] = _fruitImages[fruitName] ?? 
              'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop';
          
          return Fruit.fromJson(modifiedItem);
        }).toList();
      } else {
        throw Exception('Gagal mengunggah buah: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fruits: $e');
    }
  }

  // Method untuk update harga buah secara manual jika diperlukan
  static void updateFruitPrice(String fruitName, int newPrice) {
    _fruitPrices[fruitName] = newPrice;
  }

  // Method untuk update gambar buah secara manual jika diperlukan  
  static void updateFruitImage(String fruitName, String newImageUrl) {
    _fruitImages[fruitName] = newImageUrl;
  }

  // Method untuk mendapatkan semua harga
  static Map<String, int> getAllPrices() {
    return Map<String, int>.from(_fruitPrices);
  }

  // Method untuk format harga dalam Rupiah dengan titik sebagai pemisah ribuan
  static String formatRupiah(int harga) {
    String hargaStr = harga.toString();
    String formatted = '';
    
    for (int i = 0; i < hargaStr.length; i++) {
      if (i > 0 && (hargaStr.length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += hargaStr[i];
    }
    
    return 'Rp $formatted';
  }

  // Method untuk mendapatkan harga buah tertentu
  static int getFruitPrice(String fruitName) {
    return _fruitPrices[fruitName] ?? 10000;
  }

  // Method untuk validasi harga (minimal 1000, maksimal 100000)
  static bool isValidPrice(int price) {
    return price >= 1000 && price <= 100000;
  }

  // Method untuk update harga dengan validasi
  static bool updateFruitPriceWithValidation(String fruitName, int newPrice) {
    if (isValidPrice(newPrice)) {
      _fruitPrices[fruitName] = newPrice;
      return true;
    }
    return false;
  }

  // Method untuk mendapatkan daftar nama buah yang tersedia
  static List<String> getAvailableFruits() {
    return _fruitPrices.keys.toList();
  }
}