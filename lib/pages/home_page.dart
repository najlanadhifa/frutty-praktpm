import 'package:flutter/material.dart';
import '../models/fruit_model.dart';
import '../services/fruit_api_service.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart';
import '../widgets/logout.dart';
import 'favorite_fruit_page.dart';
import 'fruit_detail_page.dart';
import 'login_page.dart';
import 'konversi_waktu_uang_page.dart';
import 'saran_kesan_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FruitModel> _allFruits = [];
  List<FruitModel> _filteredFruits = [];
  List<String> _favoriteIds = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOrder = 'A-Z';
  String _currentUser = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current user
      final user = await AuthService.getCurrentUser();

      // Load fruits and favorites
      final fruitService = FruitService();
      final fruits = await fruitService.getAllFruits();
      final favoriteIds = await FavoriteService.getFavoriteIds();

      setState(() {
        _currentUser = user ?? 'User';
        _allFruits = fruits;
        _filteredFruits = fruits;
        _favoriteIds = favoriteIds;
        _isLoading = false;
      });

      // Tampilkan status cache
      final cacheStatus = await fruitService.getCacheStatus();
      if (cacheStatus['hasCache'] && !cacheStatus['isValid']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menggunakan data cache (mungkin tidak terbaru)'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _allFruits = [];
        _filteredFruits = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _loadData,
          ),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final fruitService = FruitService();
      final fruits = await fruitService.forceRefreshFromAPI();
      final favoriteIds = await FavoriteService.getFavoriteIds();

      setState(() {
        _allFruits = fruits;
        _filteredFruits = fruits;
        _favoriteIds = favoriteIds;
        _isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui dari server'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      _filterFruits();
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });

      String errorMessage = e.toString();
      if (errorMessage.contains('ClientException') || errorMessage.contains('Failed to fetch')) {
        errorMessage = 'Tidak dapat terhubung ke internet. Periksa koneksi Anda.';
      } else if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _refreshData,
          ),
        ),
      );
    }
  }

  void _filterFruits() {
    List<FruitModel> filtered = _allFruits;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((fruit) =>
          fruit.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_sortOrder == 'A-Z') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else {
      filtered.sort((a, b) => b.name.compareTo(a.name));
    }

    setState(() {
      _filteredFruits = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterFruits();
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Urutkan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('A-Z'),
              leading: Radio<String>(
                value: 'A-Z',
                groupValue: _sortOrder,
                onChanged: (value) {
                  setState(() {
                    _sortOrder = value!;
                  });
                  _filterFruits();
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Z-A'),
              leading: Radio<String>(
                value: 'Z-A',
                groupValue: _sortOrder,
                onChanged: (value) {
                  setState(() {
                    _sortOrder = value!;
                  });
                  _filterFruits();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Selamat datang, $_currentUser!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_isRefreshing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshData,
                tooltip: 'Perbarui data',
              ),
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onPressed: () {
                // Location feature - not implemented yet
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      allFruits: _allFruits,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.lightBlue[300],
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Cari buah...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterMenu,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fruit List Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Daftar buah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredFruits.length,
                          itemBuilder: (context, index) {
                            final fruit = _filteredFruits[index];
                            return _buildFruitCard(fruit);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildFruitCard(FruitModel fruit) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FruitDetailPage(
              fruit: fruit,
              onFavoriteChanged: () {
                _loadData();
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
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
                        size: 50,
                        color: Colors.lightBlue[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fruit.family,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      fruit.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${fruit.nutritions.calories} cal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.lightBlue[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Beranda', true),
          _buildNavItem(Icons.sync, 'Konversi', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const KonversiWaktuUangPage()),
            );
          }),
          _buildNavItem(Icons.description, 'S&K', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SaranKesanPage()),
            );
          }),
          _buildNavItem(Icons.person, 'Profil', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }),
          _buildNavItem(Icons.logout, 'Keluar', false, onTap: () {
            LogoutConfirmationDialog.show(context);
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
