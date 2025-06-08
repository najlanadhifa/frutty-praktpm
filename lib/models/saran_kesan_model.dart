import 'package:hive/hive.dart';

part 'saran_kesan_model.g.dart';

@HiveType(typeId: 3)
class SaranKesanModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String saran;
  
  @HiveField(2)
  String kesan;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  DateTime updatedAt;

  SaranKesanModel({
    required this.id,
    required this.saran,
    required this.kesan,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory untuk membuat instance baru
  factory SaranKesanModel.create({
    required String saran,
    required String kesan,
  }) {
    final now = DateTime.now();
    return SaranKesanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      saran: saran,
      kesan: kesan,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Method untuk update data
  void update({
    String? saran,
    String? kesan,
  }) {
    if (saran != null) this.saran = saran;
    if (kesan != null) this.kesan = kesan;
    this.updatedAt = DateTime.now();
  }

  // Convert ke Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saran': saran,
      'kesan': kesan,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create dari Map
  factory SaranKesanModel.fromJson(Map<String, dynamic> json) {
    return SaranKesanModel(
      id: json['id'],
      saran: json['saran'],
      kesan: json['kesan'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
