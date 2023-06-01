// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirmModelAdapter extends TypeAdapter<FirmModel> {
  @override
  final int typeId = 1;

  @override
  FirmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FirmModel(
      id: fields[0] as int,
      name: fields[1] as String,
      api: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FirmModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.api);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
