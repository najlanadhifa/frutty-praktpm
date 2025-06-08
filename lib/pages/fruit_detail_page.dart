import 'package:flutter/material.dart';
import '../models/fruit_model.dart';
import '../services/favorite_service.dart';

class FruitDetailPage extends StatefulWidget {
  final FruitModel fruit;
  final VoidCallback? onFavoriteChanged;

  const FruitDetailPage({
    Key? key,
    required this.fruit,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<FruitDetailPage> createState() => _FruitDetailPageState();
}

class _FruitDetailPageState extends State<FruitDetailPage> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoriteService.isFavorite(widget.fruit.id);
    setState(() {
      _isFavorite = isFavorite;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await FavoriteService.toggleFavorite(widget.fruit);
    setState(() {
      _isFavorite = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? '${widget.fruit.name} ditambahkan ke favorit'
              : '${widget.fruit.name} dihapus dari favorit',
        ),
        backgroundColor: newStatus ? Colors.green : Colors.orange,
      ),
    );

    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
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
        title: Text(
          'Detail ${widget.fruit.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fruit Icon
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apple,
                      size: 120,
                      color: Colors.lightBlue[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.fruit.family,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Fruit Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.fruit.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Taxonomic Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family: ${widget.fruit.family}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Order: ${widget.fruit.order}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Genus: ${widget.fruit.genus}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nutrition Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildNutritionTag('Kalori', '${widget.fruit.nutritions.calories}'),
                  _buildNutritionTag('Lemak', '${widget.fruit.nutritions.fat.toStringAsFixed(1)}g'),
                  _buildNutritionTag('Gula', '${widget.fruit.nutritions.sugar.toStringAsFixed(1)}g'),
                  _buildNutritionTag('Protein', '${widget.fruit.nutritions.protein.toStringAsFixed(1)}g'),
                  _buildNutritionTag('Karbo', '${widget.fruit.nutritions.carbohydrates.toStringAsFixed(1)}g'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nutrition Details
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Informasi Nutrisi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNutritionRow('Kalori', '${widget.fruit.nutritions.calories}'),
                    _buildNutritionRow('Lemak', '${widget.fruit.nutritions.fat.toStringAsFixed(1)}g'),
                    _buildNutritionRow('Gula', '${widget.fruit.nutritions.sugar.toStringAsFixed(1)}g'),
                    _buildNutritionRow('Karbohidrat', '${widget.fruit.nutritions.carbohydrates.toStringAsFixed(1)}g'),
                    _buildNutritionRow('Protein', '${widget.fruit.nutritions.protein.toStringAsFixed(1)}g'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
