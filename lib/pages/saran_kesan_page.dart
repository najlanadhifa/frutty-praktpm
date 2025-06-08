import 'package:flutter/material.dart';
import '../models/saran_kesan_model.dart';
import '../services/saran_kesan_service.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'konversi_waktu_uang_page.dart';
import 'profile_page.dart';
import '../widgets/logout.dart';

class SaranKesanPage extends StatefulWidget {
  const SaranKesanPage({Key? key}) : super(key: key);

  @override
  State<SaranKesanPage> createState() => _SaranKesanPageState();
}

class _SaranKesanPageState extends State<SaranKesanPage> {
  final SaranKesanService _saranKesanService = SaranKesanService();
  List<SaranKesanModel> _saranKesanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaranKesan();
  }

  Future<void> _loadSaranKesan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final saranKesanList = await _saranKesanService.getAllSaranKesan();
      setState(() {
        _saranKesanList = saranKesanList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showAddEditDialog({SaranKesanModel? item}) async {
    final isEditing = item != null;
    final saranController = TextEditingController(text: isEditing ? item.saran : '');
    final kesanController = TextEditingController(text: isEditing ? item.kesan : '');

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Saran dan Kesan' : 'Tambah Saran dan Kesan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Saran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: saranController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Masukkan saran Anda',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kesan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: kesanController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kesan Anda',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final saran = saranController.text.trim();
                        final kesan = kesanController.text.trim();

                        if (saran.isEmpty || kesan.isEmpty) {
                          _showErrorSnackBar('Saran dan kesan tidak boleh kosong');
                          return;
                        }

                        Navigator.of(context).pop();

                        try {
                          if (isEditing) {
                            await _saranKesanService.updateSaranKesan(
                              item.id,
                              saran,
                              kesan,
                            );
                            _showSuccessSnackBar('Saran dan kesan berhasil diperbarui');
                          } else {
                            await _saranKesanService.addSaranKesan(saran, kesan);
                            _showSuccessSnackBar('Saran dan kesan berhasil ditambahkan');
                          }
                          _loadSaranKesan();
                        } catch (e) {
                          _showErrorSnackBar('Terjadi kesalahan: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Simpan Perubahan' : 'Simpan',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(SaranKesanModel item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus saran dan kesan ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _saranKesanService.deleteSaranKesan(item.id);
                  _showSuccessSnackBar('Saran dan kesan berhasil dihapus');
                  _loadSaranKesan();
                } catch (e) {
                  _showErrorSnackBar('Gagal menghapus: $e');
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context, SaranKesanModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEditDialog(item: item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(item);
                },
              ),
            ],
          ),
        );
      },
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
        title: const Text(
          'Saran dan Kesan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _saranKesanList.isEmpty
              ? _buildEmptyState()
              : _buildSaranKesanList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.lightBlue[300],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 40,
              color: Colors.lightBlue[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada Saran dan Kesan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.lightBlue[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaranKesanList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _saranKesanList.length,
      itemBuilder: (context, index) {
        final item = _saranKesanList[index];
        return _buildSaranKesanCard(item);
      },
    );
  }

  Widget _buildSaranKesanCard(SaranKesanModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  onPressed: () => _showOptionsMenu(context, item),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.saran,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kesan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.kesan,
                style: const TextStyle(fontSize: 14),
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
          _buildNavItem(Icons.home, 'Beranda', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }),
          _buildNavItem(Icons.sync, 'Konversi', false, onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const KonversiWaktuUangPage()),
            );
          }),
          _buildNavItem(Icons.description, 'S&K', true),
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
