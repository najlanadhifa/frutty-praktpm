import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FruitListPage extends StatefulWidget {
  const FruitListPage({super.key});

  @override
  State<FruitListPage> createState() => _FruitListPageState();
}

class _FruitListPageState extends State<FruitListPage> {
  late Future<List<Fruit>> fruitsFuture;

  @override
  void initState() {
    super.initState();
    fruitsFuture = fetchFruits();
  }

  Future<List<Fruit>> fetchFruits() async {
    final response = await http.get(
      Uri.parse('https://www.fruityvice.com/api/fruit/all'),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Fruit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load fruits');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buah'),
      ),
      body: FutureBuilder<List<Fruit>>(
        future: fruitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data buah'));
          }

          final fruits = snapshot.data!;
          return ListView.separated(
            itemCount: fruits.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final fruit = fruits[index];
              return ListTile(
                leading: Image.network(
                  fruit.image,
                  width: 50,
                  height: 50,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.local_florist, size: 40),
                ),
                title: Text(fruit.name),
                subtitle: Text('Family: ${fruit.family}'),
                onTap: () {
                  // nanti bisa tambah navigasi ke detail page
                },
              );
            },
          );
        },
      ),
    );
  }
}

class Fruit {
  final String name;
  final String family;
  final String genus;
  final String order;
  final String image;

  Fruit({
    required this.name,
    required this.family,
    required this.genus,
    required this.order,
    required this.image,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      name: json['name'] ?? 'Unknown',
      family: json['family'] ?? 'Unknown',
      genus: json['genus'] ?? 'Unknown',
      order: json['order'] ?? 'Unknown',
      image: json['image'] ??
          'https://via.placeholder.com/50x50.png?text=No+Image', // fallback image
    );
  }
}
