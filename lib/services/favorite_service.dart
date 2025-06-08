import 'package:shared_preferences/shared_preferences.dart';
import '../models/fruit_model.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_fruits';

  // Mendapatkan list ID favorit
  static Future<List<String>> getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  // Menambah buah ke favorit
  static Future<bool> addFavorite(FruitModel fruit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      
      if (!favoriteIds.contains(fruit.id.toString())) {
        favoriteIds.add(fruit.id.toString());
        await prefs.setStringList(_favoritesKey, favoriteIds);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Menghapus buah dari favorit
  static Future<bool> removeFavorite(int fruitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      
      if (favoriteIds.remove(fruitId.toString())) {
        await prefs.setStringList(_favoritesKey, favoriteIds);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Mengecek apakah buah sudah difavoritkan
  static Future<bool> isFavorite(int fruitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      return favoriteIds.contains(fruitId.toString());
    } catch (e) {
      return false;
    }
  }

  // Toggle favorit - menambah jika belum ada, menghapus jika sudah ada
  static Future<bool> toggleFavorite(FruitModel fruit) async {
    try {
      final isCurrentlyFavorite = await isFavorite(fruit.id);
      
      if (isCurrentlyFavorite) {
        await removeFavorite(fruit.id);
        return false; // Tidak favorit lagi
      } else {
        await addFavorite(fruit);
        return true; // Menjadi favorit
      }
    } catch (e) {
      return false;
    }
  }

  // Mendapatkan buah favorit dari list buah
  static List<FruitModel> getFavoriteFruits(List<FruitModel> allFruits, List<String> favoriteIds) {
    return allFruits.where((fruit) => 
      favoriteIds.contains(fruit.id.toString())
    ).toList();
  }

  // Mendapatkan jumlah buah favorit
  static Future<int> getFavoriteCount() async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.length;
    } catch (e) {
      return 0;
    }
  }

  // Menghapus semua favorit
  static Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}
