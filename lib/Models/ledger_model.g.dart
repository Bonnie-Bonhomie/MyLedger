// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LedgerModelAdapter extends TypeAdapter<LedgerModel> {
  @override
  final int typeId = 3;

  @override
  LedgerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LedgerModel(
      id: fields[0] as String?,
      allocationId: fields[1] as String,
      categoryId: fields[2] as String,
      description: fields[3] as String,
      amount: fields[4] as double,
      date: fields[5] as DateTime?,
      inputMethod: fields[6] as String,
      imagePath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LedgerModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.allocationId)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.inputMethod)
      ..writeByte(7)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LedgerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
