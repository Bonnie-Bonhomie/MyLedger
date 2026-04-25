// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllocationModelAdapter extends TypeAdapter<AllocationModel> {
  @override
  final int typeId = 1;

  @override
  AllocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllocationModel(
      id: fields[0] as String?,
      categoryId: fields[1] as String,
      name: fields[2] as String,
      spendLimit: fields[3] as double,
      totalSpent: fields[4] as double,
      isRecurring: fields[5] as bool,
      recurringType: fields[6] as String,
      notificationsEnabled: fields[7] as bool,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AllocationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.spendLimit)
      ..writeByte(4)
      ..write(obj.totalSpent)
      ..writeByte(5)
      ..write(obj.isRecurring)
      ..writeByte(6)
      ..write(obj.recurringType)
      ..writeByte(7)
      ..write(obj.notificationsEnabled)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
