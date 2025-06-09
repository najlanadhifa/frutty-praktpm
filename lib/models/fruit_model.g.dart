// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fruit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FruitModelAdapter extends TypeAdapter<FruitModel> {
  @override
  final int typeId = 1;

  @override
  FruitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FruitModel(
      name: fields[1] as String,
      id: fields[2] as int,
      family: fields[3] as String,
      order: fields[4] as String,
      genus: fields[5] as String,
      nutritions: fields[6] as Nutritions,
    );
  }

  @override
  void write(BinaryWriter writer, FruitModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.family)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.genus)
      ..writeByte(6)
      ..write(obj.nutritions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FruitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionsAdapter extends TypeAdapter<Nutritions> {
  @override
  final int typeId = 2;

  @override
  Nutritions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nutritions(
      calories: fields[1] as double,
      fat: fields[2] as double,
      sugar: fields[3] as double,
      carbohydrates: fields[4] as double,
      protein: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Nutritions obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.fat)
      ..writeByte(3)
      ..write(obj.sugar)
      ..writeByte(4)
      ..write(obj.carbohydrates)
      ..writeByte(5)
      ..write(obj.protein);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
