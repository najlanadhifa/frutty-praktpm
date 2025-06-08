import 'package:hive/hive.dart';
import '../models/saran_kesan_model.dart';

class SaranKesanService {
  static const String _boxName = 'saran_kesan_box';

  // Mendapatkan semua saran dan kesan
  Future<List<SaranKesanModel>> getAllSaranKesan() async {
    final box = await Hive.openBox<SaranKesanModel>(_boxName);
    return box.values.toList();
  }

  // Menambahkan saran dan kesan baru
  Future<SaranKesanModel> addSaranKesan(String saran, String kesan) async {
    final box = await Hive.openBox<SaranKesanModel>(_boxName);
    final newItem = SaranKesanModel.create(
      saran: saran,
      kesan: kesan,
    );
    
    await box.put(newItem.id, newItem);
    return newItem;
  }

  // Mendapatkan saran dan kesan berdasarkan ID
  Future<SaranKesanModel?> getSaranKesanById(String id) async {
    final box = await Hive.openBox<SaranKesanModel>(_boxName);
    return box.get(id);
  }

  // Mengupdate saran dan kesan
  Future<SaranKesanModel?> updateSaranKesan(String id, String saran, String kesan) async {
    final box = await Hive.openBox<SaranKesanModel>(_boxName);
    final item = box.get(id);
    
    if (item != null) {
      item.update(
        saran: saran,
        kesan: kesan,
      );
      
      await box.put(id, item);
      return item;
    }
    
    return null;
  }

  // Menghapus saran dan kesan
  Future<bool> deleteSaranKesan(String id) async {
    final box = await Hive.openBox<SaranKesanModel>(_boxName);
    
    if (box.containsKey(id)) {
      await box.delete(id);
      return true;
    }
    
    return false;
  }

  // Menghapus semua saran dan kesan
  Future<void> deleteAllSaranKesan() async {
    final box = await Hive.openBox<SaranKesanModel>(_boxName);
    await box.clear();
  }
}
