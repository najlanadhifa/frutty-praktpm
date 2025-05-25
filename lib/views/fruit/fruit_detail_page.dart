import 'package:flutter/material.dart';
import 'fruit_list_page.dart'; // untuk kelas Fruit

class FruitDetailPage extends StatelessWidget {
  final Fruit fruit;

  const FruitDetailPage({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fruit.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                fruit.image,
                height: 150,
                errorBuilder: (_, __, ___) => const Icon(Icons.local_florist, size: 100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nama: ${fruit.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Family: ${fruit.family}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Genus: ${fruit.genus}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Order: ${fruit.order}', style: const TextStyle(fontSize: 16)),
            // Bisa ditambah field lain sesuai data API
          ],
        ),
      ),
    );
  }
}
