// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovementHistoryAdapter extends TypeAdapter<MovementHistory> {
  @override
  final int typeId = 1;

  @override
  MovementHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovementHistory(
      timestamp: fields[0] as String,
      lat: fields[1] as double,
      lng: fields[2] as double,
      status: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MovementHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.lat)
      ..writeByte(2)
      ..write(obj.lng)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
