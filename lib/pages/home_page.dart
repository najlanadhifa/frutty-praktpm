import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  String? _errorMessage;
  bool _usingFallbackData = false;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _usingFallbackData = false;
    });

    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user ?? 'User';
      });

      await _loadFruitsData();
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data awal: ${e.toString()}';
      });
    }
  }

  Future<void> _loadFruitsData() async {
    try {
      debugPrint('Starting to load fruits data...');
      debugPrint('Platform: ${kIsWeb ? "Web (using CORS proxy)" : "Mobile"}');

      // Langsung coba fetch dengan fallback
      final fruitsData = await _apiService.fetchFruitsWithFallback(
        maxRetries: 2,
      );
      debugPrint('Received ${fruitsData.length} fruits');

      if (fruitsData.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tidak ada data buah yang diterima';
        });
        return;
      }

      // Parse fruits data
      debugPrint('Parsing fruits data...');
      final List<FruitModel> fruits = FruitModel.fromJsonList(fruitsData);
      debugPrint('Successfully parsed ${fruits.length} fruits');

      if (fruits.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memproses data buah';
        });
        return;
      }

      // Load favorites
      final favoriteIds = await FavoriteService.getFavoriteIds();
      debugPrint('Loaded ${favoriteIds.length} favorite IDs');

      // Check if we're using fallback data
      final isUsingFallback =
          fruitsData.length <= 8; // Fallback data has 8 items

      // Update state
      setState(() {
        _allFruits = fruits;
        _filteredFruits = fruits;
        _favoriteIds = favoriteIds;
        _isLoading = false;
        _errorMessage = null;
        _usingFallbackData = isUsingFallback;
      });

      debugPrint('State updated successfully with ${fruits.length} fruits');
      _applyFilters();

      // Show appropriate message
      if (mounted) {
        final message =
            isUsingFallback
                ? 'Menggunakan data offline (${fruits.length} buah)'
                : 'Berhasil memuat ${fruits.length} buah dari server';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isUsingFallback ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 3),
            action:
                isUsingFallback
                    ? SnackBarAction(
                      label: 'Coba Online',
                      textColor: Colors.white,
                      onPressed: _refreshData,
                    )
                    : null,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _loadFruitsData: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.toString());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadFruitsData,
            ),
          ),
        );
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('SocketException') ||
        error.contains('Tidak ada koneksi internet')) {
      return 'Periksa koneksi internet Anda dan coba lagi';
    } else if (error.contains('TimeoutException') ||
        error.contains('timeout')) {
      return 'Koneksi timeout. Server mungkin sibuk, coba lagi';
    } else if (error.contains('FormatException')) {
      return 'Format data dari server tidak valid';
    } else if (error.contains('HttpException')) {
      return 'Server bermasalah. Coba lagi nanti';
    } else if (error.contains('ClientException')) {
      return kIsWeb
          ? 'Masalah CORS - menggunakan proxy untuk mengatasi'
          : 'Masalah koneksi client';
    }
    return 'Gagal memuat data: ${error.length > 100 ? error.substring(0, 100) + '...' : error}';
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _loadFruitsData();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _applyFilters() {
    List<FruitModel> filtered = List.from(_allFruits);

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (fruit) =>
                    fruit.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    fruit.family.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    if (_sortOrder == 'A-Z') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortOrder == 'Z-A') {
      filtered.sort((a, b) => b.name.compareTo(a.name));
    }

    setState(() {
      _filteredFruits = filtered;
    });

    debugPrint('Filters applied: ${filtered.length} fruits after filtering');
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Urutkan Buah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSortOption('A-Z', 'Nama A ke Z'),
                _buildSortOption('Z-A', 'Nama Z ke A'),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildSortOption(String value, String title) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: _sortOrder,
        activeColor: Colors.lightBlue,
        onChanged: (selectedValue) {
          setState(() {
            _sortOrder = selectedValue!;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _sortOrder = value;
        });
        _applyFilters();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.lightBlue[400],
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue[400]!, Colors.lightBlue[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _currentUser,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Indicator untuk fallback data
          if (_usingFallbackData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'OFFLINE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
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
            icon: Stack(
              children: [
                const Icon(Icons.favorite, color: Colors.white),
                if (_favoriteIds.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_favoriteIds.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritePage(allFruits: _allFruits),
                ),
              ).then((_) {
                _loadFavorites();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadFavorites() async {
    final favoriteIds = await FavoriteService.getFavoriteIds();
    setState(() {
      _favoriteIds = favoriteIds;
    });
  }

  Widget _buildBody() {
    return Column(
      children: [_buildSearchSection(), Expanded(child: _buildContent())],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue[400]!, Colors.lightBlue[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari buah atau keluarga...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showSortMenu,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.sort, color: Colors.black87),
                      SizedBox(width: 4),
                      Text(
                        'Urutkan',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_allFruits.isEmpty) {
      return _buildEmptyState();
    }

    if (_filteredFruits.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoResultsState();
    }

    return _buildFruitsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.lightBlue),
          const SizedBox(height: 16),
          const Text(
            'Memuat daftar buah...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            kIsWeb ? 'Menggunakan CORS proxy untuk web' : 'Tunggu sebentar',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.orange[400]),
            const SizedBox(height: 20),
            Text(
              'Oops! Ada Masalah',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadFruitsData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final status = await _apiService.checkApiStatus();
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Status API'),
                              content: SingleChildScrollView(
                                child: Text(
                                  'Platform: ${status['platform']}\n'
                                  'Using Proxy: ${status['usingProxy']}\n'
                                  'Available: ${status['isAvailable']}\n'
                                  'Response Time: ${status['responseTime']}ms\n'
                                  'Status Code: ${status['statusCode']}\n'
                                  'Proxy Status: ${status['proxyStatusCode'] ?? 'N/A'}\n'
                                  'Error: ${status['error'] ?? 'None'}\n'
                                  'Data Count: ${status['dataCount'] ?? 'N/A'}',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Tidak Ada Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada data buah yang tersedia',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadFruitsData,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Tidak Ditemukan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada buah yang cocok dengan pencarian "${_searchQuery}"',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
            },
            icon: const Icon(Icons.clear),
            label: const Text('Hapus Pencarian'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Buah (${_filteredFruits.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pencarian: "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.lightBlue[700],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Banner untuk fallback data
        if (_usingFallbackData)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.offline_bolt, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menampilkan data offline. Tekan refresh untuk coba koneksi online.',
                    style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredFruits.length,
            itemBuilder: (context, index) {
              return _buildFruitCard(_filteredFruits[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFruitCard(FruitModel fruit) {
    final isFavorite = _favoriteIds.contains(fruit.id.toString());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FruitDetailPage(
                  fruit: fruit,
                  onFavoriteChanged: _loadFavorites,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.lightBlue[100]!, Colors.lightBlue[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Icon(
                      _getFruitIcon(fruit.name),
                      size: 40,
                      color: Colors.lightBlue[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fruit.family,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${fruit.nutritions.calories.toInt()} cal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.lightBlue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getFruitIcon(String fruitName) {
    final name = fruitName.toLowerCase();
    if (name.contains('apple')) return Icons.apple;
    if (name.contains('banana')) return Icons.sports_volleyball;
    if (name.contains('orange') || name.contains('lemon')) return Icons.circle;
    if (name.contains('grape')) return Icons.scatter_plot;
    if (name.contains('cherry')) return Icons.circle_outlined;
    if (name.contains('strawberry')) return Icons.favorite;
    if (name.contains('mango')) return Icons.egg;
    if (name.contains('pineapple')) return Icons.park;
    if (name.contains('watermelon')) return Icons.circle;
    return Icons.eco;
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue[400]!, Colors.lightBlue[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Beranda', true),
          _buildNavItem(
            Icons.sync,
            'Konversi',
            false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const KonversiWaktuUangPage(),
                ),
              );
            },
          ),
          _buildNavItem(
            Icons.description,
            'S&K',
            false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SaranKesanPage()),
              );
            },
          ),
          _buildNavItem(
            Icons.person,
            'Profil',
            false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          _buildNavItem(
            Icons.logout,
            'Keluar',
            false,
            onTap: () {
              LogoutConfirmationDialog.show(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 24),
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
