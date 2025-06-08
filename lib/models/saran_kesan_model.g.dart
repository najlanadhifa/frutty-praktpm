// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saran_kesan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaranKesanModelAdapter extends TypeAdapter<SaranKesanModel> {
  @override
  final int typeId = 3;

  @override
  SaranKesanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaranKesanModel(
      id: fields[0] as String,
      saran: fields[1] as String,
      kesan: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SaranKesanModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.saran)
      ..writeByte(2)
      ..write(obj.kesan)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaranKesanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
