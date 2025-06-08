import 'package:flutter/material.dart';
import '../models/fruit_model.dart';
import '../services/favorite_service.dart';
import 'fruit_detail_page.dart';

class FavoritePage extends StatefulWidget {
  final List<FruitModel> allFruits;

  const FavoritePage({
    Key? key,
    required this.allFruits,
  }) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<FruitModel> _favoriteFruits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favoriteIds = await FavoriteService.getFavoriteIds();
      final favoriteFruits = FavoriteService.getFavoriteFruits(
        widget.allFruits,
        favoriteIds,
      );

      setState(() {
        _favoriteFruits = favoriteFruits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(FruitModel fruit) async {
    final success = await FavoriteService.removeFavorite(fruit.id);
    if (success) {
      setState(() {
        _favoriteFruits.removeWhere((f) => f.id == fruit.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${fruit.name} dihapus dari favorit'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Favorit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteFruits.isEmpty
              ? _buildEmptyState()
              : _buildFavoriteList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 80,
            color: Colors.lightBlue[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada favorit buah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.lightBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai tambah buah yang kamu sukai',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteFruits.length,
      itemBuilder: (context, index) {
        final fruit = _favoriteFruits[index];
        return _buildFavoriteCard(fruit);
      },
    );
  }

  Widget _buildFavoriteCard(FruitModel fruit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.apple,
                  color: Colors.lightBlue[300],
                  size: 30,
                ),
                Text(
                  fruit.family.length > 8 
                    ? '${fruit.family.substring(0, 8)}...' 
                    : fruit.family,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        title: Text(
          fruit.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${fruit.nutritions.calories} cal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              'Family: ${fruit.family}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.favorite,
            color: Colors.white,
          ),
          onPressed: () => _removeFavorite(fruit),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FruitDetailPage(
                fruit: fruit,
                onFavoriteChanged: _loadFavorites,
              ),
            ),
          );
        },
      ),
    );
  }
}
