import '../models/fruit_model.dart';

class FavoriteService {
  // Menggunakan static list untuk menyimpan favorit selama session
  // Dalam implementasi nyata, Anda bisa menggunakan SharedPreferences atau database
  static final List<Fruit> _favorites = [];

  // Mendapatkan semua buah favorit
  static List<Fruit> getFavorites() {
    return List<Fruit>.from(_favorites);
  }

  // Menambah buah ke favorit
  static void addFavorite(Fruit fruit) {
    // Cek apakah buah sudah ada di favorit
    if (!_favorites.any((f) => f.id == fruit.id)) {
      _favorites.add(fruit);
    }
  }

  // Menghapus buah dari favorit
  static void removeFavorite(int fruitId) {
    _favorites.removeWhere((fruit) => fruit.id == fruitId);
  }

  // Mengecek apakah buah sudah difavoritkan
  static bool isFavorite(int fruitId) {
    return _favorites.any((fruit) => fruit.id == fruitId);
  }

  // Mendapatkan jumlah buah favorit
  static int getFavoriteCount() {
    return _favorites.length;
  }

  // Menghapus semua favorit
  static void clearFavorites() {
    _favorites.clear();
  }

  // Toggle favorit - menambah jika belum ada, menghapus jika sudah ada
  static bool toggleFavorite(Fruit fruit) {
    if (isFavorite(fruit.id)) {
      removeFavorite(fruit.id);
      return false; // Tidak favorit lagi
    } else {
      addFavorite(fruit);
      return true; // Menjadi favorit
    }
  }

  // Mencari buah favorit berdasarkan nama
  static List<Fruit> searchFavorites(String query) {
    if (query.isEmpty) return getFavorites();
    
    return _favorites.where((fruit) =>
      fruit.name.toLowerCase().contains(query.toLowerCase()) ||
      fruit.family.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}