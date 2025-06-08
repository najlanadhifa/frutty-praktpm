import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/fruit_model.dart';

class FruitService {
  static const String apiUrl = 'https://www.fruityvice.com/api/fruit/all';
  static const String fruitsBoxName = 'fruits_cache';
  static const String lastUpdateKey = 'last_update';
  
  // Cache duration - 24 jam
  static const Duration cacheValidDuration = Duration(hours: 24);
  
  // Timeout untuk request API
  final Duration timeout = const Duration(seconds: 10);

  // Method untuk mendapatkan semua buah
  Future<List<FruitModel>> getAllFruits() async {
    try {
      // Buka box untuk cache buah
      final fruitsBox = await Hive.openBox(fruitsBoxName);
      
      // Cek apakah cache masih valid
      final lastUpdate = fruitsBox.get(lastUpdateKey);
      final now = DateTime.now();
      
      bool shouldFetchFromAPI = true;
      
      if (lastUpdate != null) {
        final lastUpdateTime = DateTime.parse(lastUpdate);
        final timeDifference = now.difference(lastUpdateTime);
        
        if (timeDifference < cacheValidDuration) {
          shouldFetchFromAPI = false;
          print('Menggunakan cache buah (masih valid)');
        }
      }
      
      // Jika cache tidak valid atau tidak ada, coba ambil dari API
      if (shouldFetchFromAPI) {
        try {
          print('Mengambil data buah dari API...');
          final response = await http.get(Uri.parse(apiUrl)).timeout(timeout);
          
          if (response.statusCode == 200) {
            final List<dynamic> fruitsJson = json.decode(response.body);
            
            // Convert JSON ke list FruitModel
            List<FruitModel> fruits = fruitsJson.map((json) => FruitModel.fromJson(json)).toList();
            
            // Simpan ke cache
            await _saveFruitsToCache(fruits, fruitsBox);
            
            print('Data buah berhasil diambil dari API dan disimpan ke cache');
            return fruits;
          } else {
            print('API error: ${response.statusCode}');
            // Gunakan cache jika ada
            return await _loadFruitsFromCache(fruitsBox);
          }
        } catch (e) {
          print('Exception saat mengambil data dari API: $e');
          // Gunakan cache jika ada
          return await _loadFruitsFromCache(fruitsBox);
        }
      } else {
        // Gunakan cache yang masih valid
        return await _loadFruitsFromCache(fruitsBox);
      }
    } catch (e) {
      print('Exception di getAllFruits: $e');
      return [];
    }
  }

  // Method untuk menyimpan buah ke cache
  Future<void> _saveFruitsToCache(List<FruitModel> fruits, Box fruitsBox) async {
    try {
      // Hapus data lama
      await fruitsBox.clear();
      
      // Simpan setiap buah dengan key berdasarkan ID
      for (final fruit in fruits) {
        await fruitsBox.put('fruit_${fruit.id}', fruit);
      }
      
      // Simpan timestamp update terakhir
      await fruitsBox.put(lastUpdateKey, DateTime.now().toIso8601String());
      
      print('${fruits.length} buah berhasil disimpan ke cache');
    } catch (e) {
      print('Error menyimpan buah ke cache: $e');
    }
  }

  // Method untuk memuat buah dari cache
  Future<List<FruitModel>> _loadFruitsFromCache(Box fruitsBox) async {
    try {
      final List<FruitModel> cachedFruits = [];
      
      // Ambil semua data buah dari cache
      for (final key in fruitsBox.keys) {
        if (key.toString().startsWith('fruit_')) {
          final fruit = fruitsBox.get(key);
          if (fruit is FruitModel) {
            cachedFruits.add(fruit);
          }
        }
      }
      
      if (cachedFruits.isNotEmpty) {
        print('${cachedFruits.length} buah dimuat dari cache');
        // Urutkan berdasarkan ID
        cachedFruits.sort((a, b) => a.id.compareTo(b.id));
        return cachedFruits;
      } else {
        print('Cache kosong, mengembalikan list kosong');
        return [];
      }
    } catch (e) {
      print('Error memuat buah dari cache: $e');
      return [];
    }
  }

  // Method untuk mendapatkan buah berdasarkan ID
  Future<FruitModel?> getFruitById(int id) async {
    try {
      final fruitsBox = await Hive.openBox(fruitsBoxName);
      final fruit = fruitsBox.get('fruit_$id');
      
      if (fruit is FruitModel) {
        return fruit;
      }
      
      // Jika tidak ada di cache, coba ambil semua buah dan cari
      final allFruits = await getAllFruits();
      return allFruits.firstWhere(
        (fruit) => fruit.id == id,
        orElse: () => throw Exception('Fruit not found'),
      );
    } catch (e) {
      print('Exception saat mengambil buah dengan id $id: $e');
      return null;
    }
  }

  // Method untuk mencari buah berdasarkan nama
  Future<List<FruitModel>> searchFruits(String query) async {
    try {
      final allFruits = await getAllFruits();
      if (query.isEmpty) return allFruits;
      
      return allFruits.where((fruit) => 
        fruit.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Exception saat mencari buah: $e');
      return [];
    }
  }

  // Method untuk force refresh dari API
  Future<List<FruitModel>> forceRefreshFromAPI() async {
    try {
      final fruitsBox = await Hive.openBox(fruitsBoxName);
    
      print('Force refresh: Mengambil data dari API...');
      final response = await http.get(Uri.parse(apiUrl)).timeout(timeout);
    
      if (response.statusCode == 200) {
        final List<dynamic> fruitsJson = json.decode(response.body);
      
        // Convert JSON ke list FruitModel
        List<FruitModel> fruits = fruitsJson.map((json) => FruitModel.fromJson(json)).toList();
      
        // Simpan ke cache
        await _saveFruitsToCache(fruits, fruitsBox);
      
        print('Force refresh berhasil');
        return fruits;
      } else {
        throw Exception('Server tidak dapat diakses (${response.statusCode})');
      }
    } catch (e) {
      print('Exception saat force refresh: $e');
      // Jika gagal refresh, kembalikan data cache yang ada
      final fruitsBox = await Hive.openBox(fruitsBoxName);
      final cachedFruits = await _loadFruitsFromCache(fruitsBox);
    
      if (cachedFruits.isNotEmpty) {
        throw Exception('Tidak dapat terhubung ke server. Menggunakan data cache.');
      } else {
        throw Exception('Tidak dapat terhubung ke server dan tidak ada data cache.');
      }
    }
  }

  // Method untuk menghapus cache
  Future<void> clearCache() async {
    try {
      final fruitsBox = await Hive.openBox(fruitsBoxName);
      await fruitsBox.clear();
      print('Cache buah berhasil dihapus');
    } catch (e) {
      print('Error menghapus cache: $e');
    }
  }

  // Method untuk mengecek status cache
  Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      final fruitsBox = await Hive.openBox(fruitsBoxName);
      final lastUpdate = fruitsBox.get(lastUpdateKey);
      
      if (lastUpdate != null) {
        final lastUpdateTime = DateTime.parse(lastUpdate);
        final now = DateTime.now();
        final timeDifference = now.difference(lastUpdateTime);
        final isValid = timeDifference < cacheValidDuration;
        
        return {
          'hasCache': true,
          'lastUpdate': lastUpdateTime,
          'isValid': isValid,
          'timeUntilExpiry': isValid ? cacheValidDuration - timeDifference : Duration.zero,
          'fruitsCount': fruitsBox.keys.where((key) => key.toString().startsWith('fruit_')).length,
        };
      } else {
        return {
          'hasCache': false,
          'lastUpdate': null,
          'isValid': false,
          'timeUntilExpiry': Duration.zero,
          'fruitsCount': 0,
        };
      }
    } catch (e) {
      print('Error mengecek status cache: $e');
      return {
        'hasCache': false,
        'lastUpdate': null,
        'isValid': false,
        'timeUntilExpiry': Duration.zero,
        'fruitsCount': 0,
      };
    }
  }
}
